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
      // 1. Get local level immediately
      final localLevel = await localDataSource.getLastUnlockedLevel();

      // 2. Start sync in background (non-blocking)
      _syncWithRemote(localLevel);

      return Right(localLevel);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<void> _syncWithRemote(int localLevel) async {
    try {
      final remoteLevel = await remoteDataSource.getLastUnlockedLevel();
      if (remoteLevel > localLevel) {
        await localDataSource.unlockLevel(remoteLevel);
      } else if (localLevel > remoteLevel) {
        await remoteDataSource.unlockLevel(localLevel);
      }

      final remoteStars = await remoteDataSource.getAllLevelStars();
      if (remoteStars.isNotEmpty) {
        for (var entry in remoteStars.entries) {
          final localStar = await localDataSource.getLevelStars(entry.key);
          if (entry.value > localStar) {
            await localDataSource.saveLevelStars(entry.key, entry.value);
          }
        }
      }

      final remoteScores = await remoteDataSource.getAllLevelScores();
      if (remoteScores.isNotEmpty) {
        for (var entry in remoteScores.entries) {
          final localScore = await localDataSource.getLevelScore(entry.key);
          if (entry.value > localScore) {
            await localDataSource.saveLevelScore(entry.key, entry.value);
          }
        }
      }
      final remoteBonuses = await remoteDataSource.getAllLevelBonuses();
      if (remoteBonuses.isNotEmpty) {
        for (var entry in remoteBonuses.entries) {
          final localBonus = await localDataSource.getLevelBonus(entry.key);
          if (entry.value > localBonus) {
            await localDataSource.saveLevelBonus(entry.key, entry.value);
          }
        }
      }
    } catch (_) {
      // Ignore background sync errors
    }
  }

  @override
  Future<Either<String, void>> unlockLevel(int level) async {
    try {
      await localDataSource.unlockLevel(level);
      // Fire and forget remote update to avoid blocking UI?
      // Or await it to ensure consistency? Await is safer for now.
      try {
        await remoteDataSource.unlockLevel(level);
      } catch (_) {
        // Prepare for offline sync later? For now just ignore if it fails
      }
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, void>> saveLevelStars(int level, int stars) async {
    try {
      await localDataSource.saveLevelStars(level, stars);
      try {
        await remoteDataSource.saveLevelStars(level, stars);
      } catch (_) {
        // Ignore remote error
      }
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
      try {
        await remoteDataSource.saveLevelScore(level, score);
      } catch (_) {}
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
      try {
        await remoteDataSource.saveLevelBonus(level, bonus);
      } catch (_) {}
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
}
