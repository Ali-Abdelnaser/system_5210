import 'package:dartz/dartz.dart';
import '../../data/models/game_stats_model.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/game_remote_data_source.dart';
import '../models/game_result_model.dart';

class GameRepositoryImpl implements GameRepository {
  final GameRemoteDataSource remoteDataSource;

  GameRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<String, void>> saveGameResult(
    String uid,
    GameResultModel result,
  ) async {
    try {
      await remoteDataSource.saveGameResult(uid, result);
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<GameResultModel>>> getGameHistory(
    String uid,
  ) async {
    try {
      final history = await remoteDataSource.getGameHistory(uid);
      return Right(history);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, GameStatsModel>> getGameStats(String uid) async {
    try {
      final stats = await remoteDataSource.getGameStats(uid);
      return Right(stats);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
