import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:system_5210/core/services/local_storage_service.dart';
import 'package:system_5210/features/games/bonding_game/data/bonding_challenges_data.dart';

import '../../data/models/bonding_challenge.dart';
import '../../data/models/bonding_memory.dart';
import 'bonding_game_state.dart';

class BondingGameCubit extends Cubit<BondingGameState> {
  final LocalStorageService storageService;
  static const String _boxName = 'bonding_game_box';
  static const String _wallKey = 'bonding_wall';
  static const String _historyKey = 'turn_history';
  static const String _challengesKey = 'challenges';
  static const String _todayStateKey = 'today_state';
  static const String _streakKey = 'streak_count';
  static const String _lastStreakDateKey = 'last_streak_date';

  BondingGameCubit(this.storageService) : super(BondingGameInitial());

  Future<void> initGame() async {
    emit(BondingGameLoading());
    try {
      // 1. Load or Initialize All Challenges
      List<BondingChallenge> allChallenges = [];
      try {
        allChallenges = await _loadChallenges();
      } catch (e) {
        // If parsing fails (e.g. data schema changed), reset to initial
        debugPrint(
          "Bonding Game Migration: Resetting challenges due to schema change.",
        );
        allChallenges = [];
      }

      if (allChallenges.isEmpty) {
        allChallenges = BondingChallengesData.getInitialChallenges();
        await _saveChallenges(allChallenges);
      }

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      var lastSavedStateMap = await storageService.get(
        _boxName,
        _todayStateKey,
      );

      final wallData = await storageService.getAll(_wallKey);
      final wallMemories = wallData
          .map((e) => BondingMemory.fromMap(e))
          .toList();
      wallMemories.sort((a, b) => b.date.compareTo(a.date)); // Newest first

      // Safety check for todayStateKey parsing
      BondingGameReady? savedState;
      if (lastSavedStateMap != null && lastSavedStateMap['date'] == today) {
        try {
          final currentTurn =
              BondingRole.values[lastSavedStateMap['currentTurn']];
          final isTurnRevealed = lastSavedStateMap['isTurnRevealed'] ?? false;
          final options = (lastSavedStateMap['options'] as List)
              .map(
                (e) => BondingChallenge.fromMap(Map<String, dynamic>.from(e)),
              )
              .toList();
          final selectedChallenge =
              lastSavedStateMap['selectedChallenge'] != null
              ? BondingChallenge.fromMap(
                  Map<String, dynamic>.from(
                    lastSavedStateMap['selectedChallenge'],
                  ),
                )
              : null;
          final isContractSigned =
              lastSavedStateMap['isContractSigned'] ?? false;
          final memoryPhotoPaths = List<String>.from(
            lastSavedStateMap['memoryPhotoPaths'] ?? [],
          );
          final streakData = await storageService.get(_boxName, _streakKey);
          final streakCount = streakData != null
              ? (streakData['count'] as int)
              : 0;
          final isMissionAccomplished =
              lastSavedStateMap['isMissionAccomplished'] ?? false;

          savedState = BondingGameReady(
            currentTurn: currentTurn,
            isTurnRevealed: isTurnRevealed,
            options: options,
            selectedChallenge: selectedChallenge,
            isContractSigned: isContractSigned,
            lastTurnDate: today,
            memoryPhotoPaths: memoryPhotoPaths,
            wallMemories: wallMemories,
            streakCount: streakCount,
            isMissionAccomplished: isMissionAccomplished,
          );
        } catch (e) {
          debugPrint(
            "Bonding Game Migration: Today's state reset due to error: $e",
          );
        }
      }

      if (savedState != null) {
        emit(savedState);
      } else {
        final streakData = await storageService.get(_boxName, _streakKey);
        final streakCount = streakData != null
            ? (streakData['count'] as int)
            : 0;
        final turn = await _determineNextTurn();
        final options = _getRandomOptions(allChallenges, turn);

        final newState = BondingGameReady(
          currentTurn: turn,
          isTurnRevealed: false,
          options: options,
          lastTurnDate: today,
          wallMemories: wallMemories,
          streakCount: streakCount,
        );

        emit(newState);
        await _saveTodayState(newState);
      }
    } catch (e) {
      emit(BondingGameError("عذراً، حدث خطأ في تحميل اللعبة: $e"));
    }
  }

  Future<void> revealTurn() async {
    if (state is BondingGameReady) {
      final currentState = state as BondingGameReady;
      final newState = currentState.copyWith(isTurnRevealed: true);
      emit(newState);
      await _saveTodayState(newState);
    }
  }

  Future<void> selectChallenge(BondingChallenge challenge) async {
    if (state is BondingGameReady) {
      final currentState = state as BondingGameReady;
      final newState = currentState.copyWith(selectedChallenge: challenge);
      emit(newState);
      await _saveTodayState(newState);
    }
  }

  Future<void> signContract() async {
    if (state is BondingGameReady) {
      final currentState = state as BondingGameReady;
      final newState = currentState.copyWith(isContractSigned: true);
      emit(newState);
      await _saveTodayState(newState);
    }
  }

  Future<void> addMemoryPhoto(String path) async {
    if (state is BondingGameReady) {
      final currentState = state as BondingGameReady;
      final newPaths = List<String>.from(currentState.memoryPhotoPaths)
        ..add(path);
      final newState = currentState.copyWith(memoryPhotoPaths: newPaths);
      emit(newState);
      await _saveTodayState(newState);
    }
  }

  Future<void> completeMission() async {
    if (state is BondingGameReady) {
      final currentState = state as BondingGameReady;
      if (currentState.memoryPhotoPaths.isNotEmpty) {
        final newState = currentState.copyWith(isMissionAccomplished: true);
        emit(newState);
        await _saveTodayState(newState);
        await _saveToWall(newState);
      }
    }
  }

  Future<void> deleteMemoryPhoto(int index) async {
    if (state is BondingGameReady) {
      final currentState = state as BondingGameReady;
      final newPaths = List<String>.from(currentState.memoryPhotoPaths);
      if (index >= 0 && index < newPaths.length) {
        newPaths.removeAt(index);
        final newState = currentState.copyWith(memoryPhotoPaths: newPaths);
        emit(newState);
        await _saveTodayState(newState);

        // If it was already accomplished, update the wall
        if (newState.isMissionAccomplished &&
            newState.selectedChallenge != null) {
          await _saveToWall(newState);
        }
      }
    }
  }

  Future<void> _updateStreak() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final streakDateData = await storageService.get(
      _boxName,
      _lastStreakDateKey,
    );
    final lastDate = streakDateData != null
        ? streakDateData['date'] as String
        : null;

    final streakData = await storageService.get(_boxName, _streakKey);
    int currentStreak = streakData != null ? (streakData['count'] as int) : 0;

    if (lastDate == today) return;

    final yesterday = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now().subtract(const Duration(days: 1)));

    if (lastDate == yesterday) {
      currentStreak++;
    } else {
      currentStreak = 1;
    }

    await storageService.save(_boxName, _streakKey, {'count': currentStreak});
    await storageService.save(_boxName, _lastStreakDateKey, {'date': today});

    if (state is BondingGameReady) {
      emit((state as BondingGameReady).copyWith(streakCount: currentStreak));
    }
  }

  Future<void> _saveToWall(BondingGameReady state) async {
    if (state.selectedChallenge == null || state.memoryPhotoPaths.isEmpty) {
      // If we deleted all photos, delete the memory
      final memoryId = '${state.lastTurnDate}_${state.selectedChallenge?.id}';
      if (state.selectedChallenge != null) {
        await storageService.delete(_wallKey, memoryId);
        await _refreshWallMemories();
      }
      return;
    }

    final memory = BondingMemory(
      id: '${state.lastTurnDate}_${state.selectedChallenge!.id}',
      title: state.selectedChallenge!.title,
      date:
          state.lastTurnDate ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
      photoPaths: state.memoryPhotoPaths,
      roleName: state.currentTurn == BondingRole.parent ? "الأهل" : "الطفل",
    );

    await storageService.save(_wallKey, memory.id, memory.toMap());
    await _updateStreak(); // Update streak when a memory is saved
    await _refreshWallMemories();
  }

  Future<void> deleteMemory(String memoryId) async {
    await storageService.delete(_wallKey, memoryId);
    await _refreshWallMemories();
  }

  Future<void> _refreshWallMemories() async {
    if (state is BondingGameReady) {
      final currentState = state as BondingGameReady;
      final wallData = await storageService.getAll(_wallKey);
      final wallMemories = wallData
          .map((e) => BondingMemory.fromMap(e))
          .toList();
      wallMemories.sort((a, b) => b.date.compareTo(a.date));
      emit(currentState.copyWith(wallMemories: wallMemories));
    }
  }

  Future<void> completeChallenge() async {
    if (state is BondingGameReady) {
      final currentState = state as BondingGameReady;
      if (currentState.selectedChallenge != null) {
        List<BondingChallenge> allChallenges = await _loadChallenges();

        final index = allChallenges.indexWhere(
          (c) => c.id == currentState.selectedChallenge!.id,
        );
        if (index != -1) {
          allChallenges[index] = allChallenges[index].copyWith(
            isCompleted: true,
          );
        }

        // Logic to prevent running out of challenges
        final roleChallenges = allChallenges
            .where((c) => c.role == currentState.currentTurn && !c.isCompleted)
            .length;
        if (roleChallenges <= 2) {
          allChallenges = allChallenges
              .map((c) => c.copyWith(isCompleted: false))
              .toList();
        }

        await _saveChallenges(allChallenges);
        await _addToHistory(currentState.currentTurn);
      }
    }
  }

  void setScrollingLocked(bool locked) {
    if (state is BondingGameReady) {
      emit((state as BondingGameReady).copyWith(isScrollingLocked: locked));
    }
  }

  // --- Private Helpers ---

  Future<List<BondingChallenge>> _loadChallenges() async {
    final list = await storageService.get(_boxName, _challengesKey);
    if (list != null && list['data'] != null) {
      return (list['data'] as List)
          .map((e) => BondingChallenge.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  Future<void> _saveChallenges(List<BondingChallenge> challenges) async {
    await storageService.save(_boxName, _challengesKey, {
      'data': challenges.map((e) => e.toMap()).toList(),
    });
  }

  Future<void> _saveTodayState(BondingGameReady state) async {
    await storageService.save(_boxName, _todayStateKey, {
      'date': state.lastTurnDate,
      'currentTurn': state.currentTurn.index,
      'isTurnRevealed': state.isTurnRevealed,
      'options': state.options.map((e) => e.toMap()).toList(),
      'selectedChallenge': state.selectedChallenge?.toMap(),
      'isContractSigned': state.isContractSigned,
      'memoryPhotoPaths': state.memoryPhotoPaths,
      'isMissionAccomplished': state.isMissionAccomplished,
    });
  }

  Future<BondingRole> _determineNextTurn() async {
    final historyData = await storageService.get(_boxName, _historyKey);
    List<int> history = historyData != null
        ? List<int>.from(historyData['history'])
        : [];

    if (history.length >= 2) {
      final last = history.last;
      final secondLast = history[history.length - 2];

      if (last == secondLast) {
        return last == BondingRole.parent.index
            ? BondingRole.child
            : BondingRole.parent;
      }
    }

    return Random().nextBool() ? BondingRole.parent : BondingRole.child;
  }

  Future<void> _addToHistory(BondingRole role) async {
    final historyData = await storageService.get(_boxName, _historyKey);
    List<int> history = historyData != null
        ? List<int>.from(historyData['history'])
        : [];

    history.add(role.index);
    if (history.length > 5) history.removeAt(0);

    await storageService.save(_boxName, _historyKey, {'history': history});
  }

  List<BondingChallenge> _getRandomOptions(
    List<BondingChallenge> all,
    BondingRole role,
  ) {
    final available = all
        .where((c) => c.role == role && !c.isCompleted)
        .toList();
    if (available.isEmpty) return [];

    available.shuffle();
    return available.take(3).toList();
  }
}
