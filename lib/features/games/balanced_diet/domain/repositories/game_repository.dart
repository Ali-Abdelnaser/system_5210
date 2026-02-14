import 'package:dartz/dartz.dart';
import '../../data/models/game_result_model.dart';
import '../../data/models/game_stats_model.dart';

abstract class GameRepository {
  Future<Either<String, void>> saveGameResult(
    String uid,
    GameResultModel result,
  );
  Future<Either<String, List<GameResultModel>>> getGameHistory(
    String uid, {
    String? gameId,
  });
  Future<Either<String, GameStatsModel>> getGameStats(
    String uid, {
    String? gameId,
  });
}
