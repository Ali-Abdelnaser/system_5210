import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/local_storage_service.dart';
import 'package:system_5210/features/game_center/data/models/user_points_model.dart';

abstract class UserPointsState extends Equatable {
  const UserPointsState();
  @override
  List<Object?> get props => [];
}

class UserPointsInitial extends UserPointsState {}

class UserPointsLoading extends UserPointsState {}

class UserPointsLoaded extends UserPointsState {
  final UserPointsModel points;
  final List<LeaderboardEntry> topPlayers;
  final int userRank;
  final LeaderboardEntry? nextPlayer;

  const UserPointsLoaded({
    required this.points,
    this.topPlayers = const [],
    this.userRank = 0,
    this.nextPlayer,
  });

  UserPointsLoaded copyWith({
    UserPointsModel? points,
    List<LeaderboardEntry>? topPlayers,
    int? userRank,
    LeaderboardEntry? nextPlayer,
  }) {
    return UserPointsLoaded(
      points: points ?? this.points,
      topPlayers: topPlayers ?? this.topPlayers,
      userRank: userRank ?? this.userRank,
      nextPlayer: nextPlayer ?? this.nextPlayer,
    );
  }

  @override
  List<Object?> get props => [points, topPlayers, userRank, nextPlayer];
}

class UserPointsError extends UserPointsState {
  final String message;
  const UserPointsError(this.message);
}

class UserPointsCubit extends Cubit<UserPointsState> {
  final LocalStorageService _storageService;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String _boxName = 'user_points_box';
  String _getPointsKey(String uid) => 'points_data_$uid';

  String? _userName;
  String? _userPhoto;
  StreamSubscription? _authSubscription;

  UserPointsCubit(this._storageService, this._firestore, this._auth)
    : super(UserPointsInitial()) {
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user != null) {
        init();
      } else {
        _userName = null;
        _userPhoto = null;
        emit(UserPointsInitial());
      }
    });
  }

  bool _isAdminAuthenticatedExternally = false;
  void setAdminAuthenticated(bool value) =>
      _isAdminAuthenticatedExternally = value;

  bool get isAdmin =>
      _isAdminAuthenticatedExternally ||
      _auth.currentUser?.email == 'ali.abdelnaser.77@gmail.com' ||
      _auth.currentUser?.email == 'admin@system5210.com';

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  Future<void> init() async {
    emit(UserPointsLoading());
    try {
      final user = _auth.currentUser;

      if (user == null) {
        emit(UserPointsLoaded(points: UserPointsModel(), topPlayers: const []));
        return;
      }

      // 1. Load Local (User Specific)
      final localData = await _storageService.get(
        _boxName,
        _getPointsKey(user.uid),
      );
      UserPointsModel points = localData != null
          ? UserPointsModel.fromMap(localData)
          : UserPointsModel();

      emit(UserPointsLoaded(points: points, topPlayers: const []));

      if (user != null) {
        // Fetch User Info for Leaderboard
        final userDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        final data = userDoc.data();
        _userName = data?['displayName'] ?? 'لاعب مجهول';
        _userPhoto = data?['photoUrl'];

        // 2. Load Remote (Background Sync)
        await _syncWithRemote(user.uid);
      }

      // 3. Load Top 3
      await fetchLeaderboard();
    } catch (e) {
      emit(UserPointsError(e.toString()));
    }
  }

  Future<void> _syncWithRemote(String uid) async {
    try {
      final doc = await _firestore.collection('user_points').doc(uid).get();
      if (doc.exists) {
        final remotePoints = UserPointsModel.fromMap(doc.data()!);
        final currentState = state;
        if (currentState is UserPointsLoaded) {
          // New Logic: Prioritize the latest timestamp
          // If remote is newer (e.g. Admin Reset), we take it even if points are 0
          UserPointsModel finalPoints;

          if (remotePoints.lastUpdatedAt.isAfter(
            currentState.points.lastUpdatedAt,
          )) {
            debugPrint("Sync: Taking Remote Data (Newer Timestamp)");
            finalPoints = remotePoints;
          } else if (currentState.points.lastUpdatedAt.isAfter(
            remotePoints.lastUpdatedAt,
          )) {
            debugPrint("Sync: Pushing Local Data (Newer Timestamp)");
            finalPoints = currentState.points;
            _updateRemote(finalPoints); // Push local to remote
          } else {
            // Equal timestamps: fallback to legacy highest-points merge
            finalPoints = UserPointsModel(
              balancedPlatePoints:
                  remotePoints.balancedPlatePoints >
                      currentState.points.balancedPlatePoints
                  ? remotePoints.balancedPlatePoints
                  : currentState.points.balancedPlatePoints,
              foodMatchingPoints:
                  remotePoints.foodMatchingPoints >
                      currentState.points.foodMatchingPoints
                  ? remotePoints.foodMatchingPoints
                  : currentState.points.foodMatchingPoints,
              quizPoints:
                  remotePoints.quizPoints > currentState.points.quizPoints
                  ? remotePoints.quizPoints
                  : currentState.points.quizPoints,
              bondingGamePoints:
                  remotePoints.bondingGamePoints >
                      currentState.points.bondingGamePoints
                  ? remotePoints.bondingGamePoints
                  : currentState.points.bondingGamePoints,
              dailyJourneyPoints:
                  remotePoints.dailyJourneyPoints >
                      currentState.points.dailyJourneyPoints
                  ? remotePoints.dailyJourneyPoints
                  : currentState.points.dailyJourneyPoints,
              lastUpdatedAt: remotePoints.lastUpdatedAt,
            );
          }

          await _storageService.save(
            _boxName,
            _getPointsKey(uid),
            finalPoints.toMap(),
          );
          emit(currentState.copyWith(points: finalPoints));
        }
      }
    } catch (e) {
      debugPrint("Points Sync Error: $e");
    }
  }

  void addPoints(String gameId, int points) async {
    final currentState = state;
    if (currentState is UserPointsLoaded) {
      final updated = currentState.points.copyWith(
        balancedPlatePoints: gameId == 'balanced_plate'
            ? currentState.points.balancedPlatePoints + points
            : currentState.points.balancedPlatePoints,
        foodMatchingPoints: gameId == 'food_matching'
            ? currentState.points.foodMatchingPoints + points
            : currentState.points.foodMatchingPoints,
        quizPoints: gameId == 'quiz'
            ? currentState.points.quizPoints + points
            : currentState.points.quizPoints,
        bondingGamePoints: gameId == 'bonding'
            ? currentState.points.bondingGamePoints + points
            : currentState.points.bondingGamePoints,
        dailyJourneyPoints: gameId == 'daily_journey'
            ? currentState.points.dailyJourneyPoints + points
            : currentState.points.dailyJourneyPoints,
        lastUpdatedAt: DateTime.now(),
      );

      emit(currentState.copyWith(points: updated));

      // Save Local (User Specific)
      final user = _auth.currentUser;
      if (user != null) {
        await _storageService.save(
          _boxName,
          _getPointsKey(user.uid),
          updated.toMap(),
        );
      }

      // Save Remote (Background)
      _updateRemote(updated);

      // Refresh Leaderboard
      await fetchLeaderboard();
    }
  }

  void _updateRemote(UserPointsModel points) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('user_points').doc(user.uid).set({
          ...points.toMap(),
          'userName': _userName ?? 'لاعب مجهول',
          'userPhoto': _userPhoto,
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint("Points Remote Update Error: $e");
      }
    }
  }

  Future<void> fetchLeaderboard() async {
    try {
      final snapshot = await _firestore
          .collection('user_points')
          .orderBy('totalPoints', descending: true)
          .get(); // Get ALL for rank calculation, limit locally for top 3

      final allPlayers = <LeaderboardEntry>[];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        String name = data['userName'] ?? 'لاعب';
        String? photo = data['userPhoto'];

        allPlayers.add(
          LeaderboardEntry(
            uid: doc.id,
            name: name,
            photoUrl: photo,
            points: data['totalPoints'] ?? 0,
          ),
        );
      }

      final top3 = allPlayers.take(3).toList();
      final userUid = _auth.currentUser?.uid;
      int rank = 0;
      LeaderboardEntry? nextP;

      if (userUid != null) {
        rank = allPlayers.indexWhere((p) => p.uid == userUid) + 1;
        if (rank > 1) {
          nextP = allPlayers[rank - 2]; // The player immediately above the user
        }
      }

      final currentState = state;
      if (currentState is UserPointsLoaded) {
        emit(
          currentState.copyWith(
            topPlayers: top3,
            userRank: rank,
            nextPlayer: nextP,
          ),
        );
      }
    } catch (e) {
      debugPrint("Leaderboard Fetch Error: $e");
    }
  }

  Future<void> resetSpecificGameProgress(String gameId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final currentState = state;
    if (currentState is! UserPointsLoaded) return;

    try {
      // 1. Reset points for this specific game
      final updatedPoints = currentState.points.copyWith(
        balancedPlatePoints: gameId == 'balanced_plate'
            ? 0
            : currentState.points.balancedPlatePoints,
        foodMatchingPoints: gameId == 'food_matching'
            ? 0
            : currentState.points.foodMatchingPoints,
        quizPoints: gameId == 'quiz' ? 0 : currentState.points.quizPoints,
        bondingGamePoints: gameId == 'bonding'
            ? 0
            : currentState.points.bondingGamePoints,
        dailyJourneyPoints: gameId == 'daily_journey'
            ? 0
            : currentState.points.dailyJourneyPoints,
        lastUpdatedAt: DateTime.now(),
      );

      // Save Local
      await _storageService.save(
        _boxName,
        _getPointsKey(user.uid),
        updatedPoints.toMap(),
      );

      // Save Remote
      await _firestore.collection('user_points').doc(user.uid).set({
        ...updatedPoints.toMap(),
        'userName': _userName,
        'userPhoto': _userPhoto,
      }, SetOptions(merge: true));

      // 2. Wipe Firestore Game Docs
      final gameDoc = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('games')
          .doc(gameId);

      final history = await gameDoc.collection('history').get();
      for (var doc in history.docs) {
        await doc.reference.delete();
      }
      await gameDoc.delete();

      // Legacy support for 'game1' if resetting balanced_plate
      if (gameId == 'balanced_plate') {
        final legacyDoc = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('games')
            .doc('game1');
        final legacyHistory = await legacyDoc.collection('history').get();
        for (var doc in legacyHistory.docs) {
          await doc.reference.delete();
        }
        await legacyDoc.delete();
      }

      // Special handling for Quiz local box
      if (gameId == 'quiz') {
        await _storageService.save('quiz_box', 'quiz_progress', {
          'last_unlocked_level': 1,
          'stars': {},
          'scores': {},
          'bonuses': {},
        });
      }

      // Special handling for Daily Tasks local box
      if (gameId == 'daily_journey') {
        // We'll let the DailyTasksCubit handle its own reset if needed,
        // but here we at least clear the points.
      }

      emit(currentState.copyWith(points: updatedPoints));
      await fetchLeaderboard();
    } catch (e) {
      debugPrint("Reset Specific Game Error: $e");
    }
  }

  // --- User-Facing Controls ---
  Future<void> wipeCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    emit(UserPointsLoading());
    try {
      // Direct call to admin-style wipe but for current user
      final gameIds = [
        'balanced_plate',
        'game1', // Legacy support
        'food_matching',
        'quiz',
        'bonding',
        'daily_journey',
      ];

      for (final gid in gameIds) {
        await resetSpecificGameProgress(gid);
      }

      init();
    } catch (e) {
      debugPrint("Wipe Progress Error: $e");
    }
  }

  // --- Admin Controls ---
  Future<String?> adminResetUser(String uid) async {
    if (!isAdmin) {
      return "عذراً، لا تملك صلاحية المشرف";
    }
    try {
      debugPrint("Admin Reset Points for: $uid");
      final emptyPoints = UserPointsModel(
        balancedPlatePoints: 0,
        foodMatchingPoints: 0,
        quizPoints: 0,
        bondingGamePoints: 0,
        dailyJourneyPoints: 0,
        lastUpdatedAt: DateTime.now(),
      );

      await _firestore
          .collection('user_points')
          .doc(uid)
          .set(emptyPoints.toMap(), SetOptions(merge: true));

      await fetchLeaderboard();
      return null; // Success
    } catch (e) {
      debugPrint("Admin Reset Error: $e");
      return e.toString();
    }
  }

  Future<String?> adminWipeUserProgress(String uid) async {
    if (!isAdmin) {
      return "عذراً، لا تملك صلاحية المشرف";
    }
    try {
      debugPrint("Admin Full Wipe for: $uid");

      // 1. Wipe points
      await adminResetUser(uid);

      // 2. Wipe all game stats in Firestore
      final gameIds = [
        'balanced_plate',
        'game1', // Legacy support
        'food_matching',
        'quiz',
        'bonding',
        'daily_journey',
      ];

      for (final gid in gameIds) {
        final gameDoc = _firestore
            .collection('users')
            .doc(uid)
            .collection('games')
            .doc(gid);

        // Delete history subcollection documents (limiting to 20 for safety/speed)
        final history = await gameDoc.collection('history').get();
        for (var doc in history.docs) {
          await doc.reference.delete();
        }

        // Delete the main game doc
        await gameDoc.delete();
      }

      await fetchLeaderboard();
      return null; // Success
    } catch (e) {
      debugPrint("Admin Wipe Error: $e");
      return e.toString();
    }
  }

  Future<void> adminUpdatePoints(
    String uid,
    String gameId,
    int newPoints,
  ) async {
    if (!isAdmin) return;
    try {
      final doc = await _firestore.collection('user_points').doc(uid).get();
      if (doc.exists) {
        final current = UserPointsModel.fromMap(doc.data()!);
        final updated = current.copyWith(
          balancedPlatePoints: gameId == 'balanced_plate'
              ? newPoints
              : current.balancedPlatePoints,
          foodMatchingPoints: gameId == 'food_matching'
              ? newPoints
              : current.foodMatchingPoints,
          quizPoints: gameId == 'quiz' ? newPoints : current.quizPoints,
          bondingGamePoints: gameId == 'bonding'
              ? newPoints
              : current.bondingGamePoints,
          dailyJourneyPoints: gameId == 'daily_journey'
              ? newPoints
              : current.dailyJourneyPoints,
          lastUpdatedAt: DateTime.now(),
        );
        await _firestore
            .collection('user_points')
            .doc(uid)
            .set(updated.toMap(), SetOptions(merge: true));
        await fetchLeaderboard();
      }
    } catch (e) {
      debugPrint("Admin Update Points Error: $e");
    }
  }
}
