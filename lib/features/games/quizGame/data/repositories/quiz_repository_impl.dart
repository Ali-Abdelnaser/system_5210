import 'package:dartz/dartz.dart';
import '../datasources/quiz_local_data_source.dart';
import '../datasources/quiz_remote_data_source.dart';
import '../models/quiz_question_model.dart';

abstract class QuizRepository {
  Future<Either<String, List<QuizQuestionModel>>> getQuestions();
  Future<Either<String, int>> getLastUnlockedLevel();
  Future<Either<String, void>> unlockLevel(int level);
  Future<Either<String, void>> saveLevelStars(int level, int stars);
  Future<Either<String, int>> getLevelStars(int level);
  Future<Either<String, void>> saveLevelScore(int level, int score);
  Future<Either<String, int>> getLevelScore(int level);
  Future<Either<String, void>> saveLevelBonus(int level, int bonus);
  Future<Either<String, int>> getLevelBonus(int level);
}

class QuizRepositoryImpl implements QuizRepository {
  final QuizLocalDataSource localDataSource;
  final QuizRemoteDataSource remoteDataSource;

  QuizRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<String, List<QuizQuestionModel>>> getQuestions() async {
    try {
      final questions = await localDataSource.getQuestions();
      return Right(questions);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, int>> getLastUnlockedLevel() async {
    try {
      final localLevel = await localDataSource.getLastUnlockedLevel();
      return Right(localLevel);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> unlockLevel(int level) async {
    try {
      await localDataSource.unlockLevel(level);
      // Run remote update in background
      _updateRemote((remote) => remote.unlockLevel(level));
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> saveLevelStars(int level, int stars) async {
    try {
      await localDataSource.saveLevelStars(level, stars);
      // Run remote update in background
      _updateRemote((remote) => remote.saveLevelStars(level, stars));
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, int>> getLevelStars(int level) async {
    try {
      final stars = await localDataSource.getLevelStars(level);
      return Right(stars);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> saveLevelScore(int level, int score) async {
    try {
      await localDataSource.saveLevelScore(level, score);
      // Run remote update in background
      _updateRemote((remote) => remote.saveLevelScore(level, score));
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, int>> getLevelScore(int level) async {
    try {
      final score = await localDataSource.getLevelScore(level);
      return Right(score);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> saveLevelBonus(int level, int bonus) async {
    try {
      await localDataSource.saveLevelBonus(level, bonus);
      // Run remote update in background
      _updateRemote((remote) => remote.saveLevelBonus(level, bonus));
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, int>> getLevelBonus(int level) async {
    try {
      final bonus = await localDataSource.getLevelBonus(level);
      return Right(bonus);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // Helper for background remote updates
  void _updateRemote(
    Future<void> Function(QuizRemoteDataSource remote) action,
  ) {
    action(remoteDataSource).catchError((_) {
      // Background remote update failed (e.g., offline)
      // For now we just ignore it as the primary data is local
    });
  }
}
