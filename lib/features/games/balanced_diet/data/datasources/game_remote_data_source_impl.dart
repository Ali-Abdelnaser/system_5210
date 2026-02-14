import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/game_result_model.dart';
import '../models/game_stats_model.dart';
import 'game_remote_data_source.dart';

class GameRemoteDataSourceImpl implements GameRemoteDataSource {
  final FirebaseFirestore firestore;

  GameRemoteDataSourceImpl({required this.firestore});

  @override
  Future<void> saveGameResult(String uid, GameResultModel result) async {
    try {
      final gameDoc = firestore
          .collection('users')
          .doc(uid)
          .collection('games')
          .doc(result.gameId);

      // Update summary stats
      await gameDoc.set({
        'totalPlays': FieldValue.increment(1),
        'balancedPlays': FieldValue.increment(result.isBalanced ? 1 : 0),
        'unbalancedPlays': FieldValue.increment(result.isBalanced ? 0 : 1),
        'lastPlayedAt': Timestamp.fromDate(result.playedAt),
        // Track 3-star performances
        'stars3Count': FieldValue.increment(result.stars == 3 ? 1 : 0),
      }, SetOptions(merge: true));

      // Organized path for history: users/{uid}/games/{gameId}/history
      await gameDoc.collection('history').add(result.toJson());
    } catch (e) {
      throw Exception("Failed to save game result: $e");
    }
  }

  @override
  Future<List<GameResultModel>> getGameHistory(
    String uid, {
    String? gameId,
  }) async {
    try {
      final snapshot = await firestore
          .collection('users')
          .doc(uid)
          .collection('games')
          .doc(gameId ?? 'game1') // Default to game1 for legacy
          .collection('history')
          .orderBy('playedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => GameResultModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception("Failed to fetch game history: $e");
    }
  }

  @override
  Future<GameStatsModel> getGameStats(String uid, {String? gameId}) async {
    try {
      final doc = await firestore
          .collection('users')
          .doc(uid)
          .collection('games')
          .doc(gameId ?? 'game1')
          .get();

      if (doc.exists) {
        return GameStatsModel.fromJson(doc.data()!);
      } else {
        return GameStatsModel(
          totalPlays: 0,
          balancedPlays: 0,
          unbalancedPlays: 0,
        );
      }
    } catch (e) {
      throw Exception("Failed to fetch game stats: $e");
    }
  }
}
