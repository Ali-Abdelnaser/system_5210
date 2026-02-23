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

  const UserPointsLoaded({required this.points, this.topPlayers = const []});

  UserPointsLoaded copyWith({
    UserPointsModel? points,
    List<LeaderboardEntry>? topPlayers,
  }) {
    return UserPointsLoaded(
      points: points ?? this.points,
      topPlayers: topPlayers ?? this.topPlayers,
    );
  }

  @override
  List<Object?> get props => [points, topPlayers];
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

        // 2. Load Remote (Background)
        await _syncWithRemote(user.uid);

        // Push correct info immediately
        final currentState = state;
        if (currentState is UserPointsLoaded) {
          _updateRemote(currentState.points);
        }
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
      if (doc.exists && doc.data() != null) {
        final remotePoints = UserPointsModel.fromMap(doc.data()!);
        final currentState = state;
        if (currentState is UserPointsLoaded) {
          // Merge logic: Take highest points for each game (simple conflict resolution)
          final merged = UserPointsModel(
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
            quizPoints: remotePoints.quizPoints > currentState.points.quizPoints
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
            lastUpdatedAt:
                remotePoints.lastUpdatedAt.isAfter(
                  currentState.points.lastUpdatedAt,
                )
                ? remotePoints.lastUpdatedAt
                : currentState.points.lastUpdatedAt,
          );

          await _storageService.save(
            _boxName,
            _getPointsKey(uid),
            merged.toMap(),
          );
          emit(currentState.copyWith(points: merged));
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
          .limit(3)
          .get();

      final leaderboardFutures = snapshot.docs.map((doc) async {
        final data = doc.data();
        String name = data['userName'] ?? 'لاعب';
        String? photo = data['userPhoto'];

        // Fallback for missing info (Migration)
        if (name == 'لاعب' || name == 'لاعب مجهول' || photo == null) {
          final userDoc = await _firestore
              .collection('users')
              .doc(doc.id)
              .get();
          if (userDoc.exists) {
            final userData = userDoc.data();
            name = userData?['displayName'] ?? name;
            photo = userData?['photoUrl'] ?? photo;
          }
        }

        return LeaderboardEntry(
          uid: doc.id,
          name: name,
          photoUrl: photo,
          points: data['totalPoints'] ?? 0,
        );
      });

      final leaderboard = await Future.wait(leaderboardFutures);

      final currentState = state;
      if (currentState is UserPointsLoaded) {
        emit(currentState.copyWith(topPlayers: leaderboard));
      }
    } catch (e) {
      debugPrint("Leaderboard Fetch Error: $e");
    }
  }
}
