import '../models/game_result_model.dart';
import '../models/game_stats_model.dart';

abstract class GameRemoteDataSource {
  Future<void> saveGameResult(String uid, GameResultModel result);
  Future<List<GameResultModel>> getGameHistory(String uid, {String? gameId});
  Future<GameStatsModel> getGameStats(String uid, {String? gameId});
}
