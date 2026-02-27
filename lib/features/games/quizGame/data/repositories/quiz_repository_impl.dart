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
  Future<void> syncProgress();
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

  @override
  Future<void> syncProgress() async {
    try {
      final remoteLevel = await remoteDataSource.getLastUnlockedLevel();
      final localLevel = await localDataSource.getLastUnlockedLevel();
      if (remoteLevel > localLevel) {
        await localDataSource.unlockLevel(remoteLevel);
      }

      final remoteStars = await remoteDataSource.getAllLevelStars();
      for (var entry in remoteStars.entries) {
        final localStars = await localDataSource.getLevelStars(entry.key);
        if (entry.value > localStars) {
          await localDataSource.saveLevelStars(entry.key, entry.value);
        }
      }

      final remoteScores = await remoteDataSource.getAllLevelScores();
      for (var entry in remoteScores.entries) {
        final localScore = await localDataSource.getLevelScore(entry.key);
        if (entry.value > localScore) {
          await localDataSource.saveLevelScore(entry.key, entry.value);
        }
      }
    } catch (e) {
      // ignore
    }
  }

  // Helper for background remote updates
  void _updateRemote(
    Future<void> Function(QuizRemoteDataSource remote) action,
  ) {
    action(remoteDataSource).catchError((_) {
      // Background remote update failed (e.g., offline)
    });
  }
}
