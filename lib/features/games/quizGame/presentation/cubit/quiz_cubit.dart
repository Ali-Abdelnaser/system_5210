import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_5210/features/game_center/presentation/manager/user_points_cubit.dart';
import '../../data/repositories/quiz_repository_impl.dart';
import 'quiz_state.dart';

class QuizCubit extends Cubit<QuizState> {
  final QuizRepositoryImpl repository;
  final UserPointsCubit pointsCubit;
  Timer? _timer;
  static const int questionDuration = 20;

  // Cache current progress
  int _lastUnlockedLevel = 1;
  Map<int, int> _levelStars = {};
  Map<int, int> _levelScores = {};
  Map<int, int> _levelBonuses = {};

  QuizCubit({required this.repository, required this.pointsCubit})
    : super(QuizInitial());

  Future<void> loadLevels() async {
    emit(
      QuizLoading(
        lastUnlockedLevel: _lastUnlockedLevel,
        levelStars: _levelStars,
        levelScores: _levelScores,
        levelBonuses: _levelBonuses,
      ),
    );

    await repository.syncProgress();
    final unlockedResult = await repository.getLastUnlockedLevel();

    unlockedResult.fold((error) => emit(QuizError(message: error)), (
      lastUnlocked,
    ) async {
      _lastUnlockedLevel = lastUnlocked;

      // Load all stars, scores, and bonuses in parallel
      final starFutures = List.generate(
        14, // Assuming 14 levels
        (i) => repository.getLevelStars(i + 1),
      );
      final scoreFutures = List.generate(
        14,
        (i) => repository.getLevelScore(i + 1),
      );
      final bonusFutures = List.generate(
        14,
        (i) => repository.getLevelBonus(i + 1),
      );

      final starResults = await Future.wait(starFutures);
      final scoreResults = await Future.wait(scoreFutures);
      final bonusResults = await Future.wait(bonusFutures);

      Map<int, int> levelStars = {};
      Map<int, int> levelScores = {};
      Map<int, int> levelBonuses = {};

      for (int i = 0; i < starResults.length; i++) {
        starResults[i].fold((_) => null, (stars) => levelStars[i + 1] = stars);
        scoreResults[i].fold(
          (_) => null,
          (score) => levelScores[i + 1] = score,
        );
        bonusResults[i].fold(
          (_) => null,
          (bonus) => levelBonuses[i + 1] = bonus,
        );
      }

      _levelStars = levelStars;
      _levelScores = levelScores;
      _levelBonuses = levelBonuses;

      emit(
        QuizLevelsLoaded(
          lastUnlockedLevel: _lastUnlockedLevel,
          levelStars: _levelStars,
          levelScores: _levelScores,
          levelBonuses: _levelBonuses,
        ),
      );
    });
  }

  Future<void> startLevel(int level) async {
    emit(
      QuizLoading(
        lastUnlockedLevel: _lastUnlockedLevel,
        levelStars: _levelStars,
        levelScores: _levelScores,
        levelBonuses: _levelBonuses,
      ),
    );
    final questionsResult = await repository.getQuestions();

    questionsResult.fold(
      (error) => emit(
        QuizError(
          message: error,
          lastUnlockedLevel: _lastUnlockedLevel,
          levelStars: _levelStars,
          levelScores: _levelScores,
          levelBonuses: _levelBonuses,
        ),
      ),
      (allQuestions) async {
        final levelQuestions = allQuestions
            .where((q) => q.level == level)
            .toList();

        if (levelQuestions.isEmpty) {
          emit(
            QuizError(
              message: 'No questions found for this level',
              lastUnlockedLevel: _lastUnlockedLevel,
              levelStars: _levelStars,
              levelScores: _levelScores,
              levelBonuses: _levelBonuses,
            ),
          );
          return;
        }

        emit(
          QuizGameInProgress(
            questions: levelQuestions,
            currentQuestionIndex: 0,
            score: 0,
            bonusScore: 0,
            streakCount: 0,
            isAidsUsed: false,
            level: level,
            timerSeconds: questionDuration,
            lastUnlockedLevel: _lastUnlockedLevel,
            levelStars: _levelStars,
            levelScores: _levelScores,
            levelBonuses: _levelBonuses,
          ),
        );
        _startTimer();
      },
    );
  }

  void dismissTutorial() {
    final currentState = state;
    if (currentState is QuizGameInProgress) {
      emit(currentState.copyWith(isTutorialVisible: false));
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentState = state;
      if (currentState is QuizGameInProgress) {
        if (currentState.isTimeStopped || currentState.isTutorialVisible) {
          return;
        }

        if (currentState.timerSeconds > 0) {
          emit(
            currentState.copyWith(timerSeconds: currentState.timerSeconds - 1),
          );
        } else {
          answerQuestion(-1); // Time's up
        }
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> answerQuestion(int selectedIndex) async {
    final currentState = state;
    if (currentState is QuizGameInProgress) {
      _timer?.cancel();
      final currentQuestion =
          currentState.questions[currentState.currentQuestionIndex];
      final isCorrect = selectedIndex == currentQuestion.correctIndex;

      int speedBonus = 0;
      int streakBonus = 0;
      int newBonusScore = currentState.bonusScore;
      int newStreakCount = isCorrect ? currentState.streakCount + 1 : 0;

      if (isCorrect) {
        // Speed Bonus Logic
        if (currentState.timerSeconds >= 17) {
          speedBonus = 150;
        } else if (currentState.timerSeconds >= 10) {
          speedBonus = 50;
        }

        // Streak Bonus Logic
        if (newStreakCount == 3) {
          streakBonus = 200;
        } else if (newStreakCount >= 5) {
          streakBonus = 500;
        }

        newBonusScore += speedBonus + streakBonus;
      }

      final newScore = isCorrect ? currentState.score + 1 : currentState.score;

      emit(
        currentState.copyWith(
          score: newScore,
          bonusScore: newBonusScore,
          streakCount: newStreakCount,
          isLastAnswerCorrect: isCorrect,
          selectedOptionIndex: selectedIndex,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 1000));
      _nextQuestion(newScore, newBonusScore, newStreakCount);
    }
  }

  void _nextQuestion(int score, int bonusScore, int streakCount) {
    if (state is QuizGameInProgress) {
      final currentProgress = state as QuizGameInProgress;

      if (currentProgress.currentQuestionIndex <
          currentProgress.questions.length - 1) {
        emit(
          currentProgress.copyWith(
            currentQuestionIndex: currentProgress.currentQuestionIndex + 1,
            timerSeconds: questionDuration,
            isLastAnswerCorrect: null,
            selectedOptionIndex: null,
            isTimeStopped: false,
            currentRemovedOptions: [],
            showCurrentHint: false,
            score: score,
            bonusScore: bonusScore,
            streakCount: streakCount,
          ),
        );
        _startTimer();
      } else {
        final totalQuestions = currentProgress.questions.length;

        // Final Bonus: No Aids used
        int noAidsBonus = currentProgress.isAidsUsed ? 0 : 500;
        int finalBonusScore = bonusScore + noAidsBonus;

        // Stars logic
        int stars = 0;
        if (score == totalQuestions) {
          stars = 3;
        } else if (score >= totalQuestions * 0.7) {
          stars = 2;
        } else if (score >= totalQuestions * 0.4) {
          stars = 1;
        }

        bool isNewLevelUnlocked = false;
        if (stars >= 1) {
          if (currentProgress.level == _lastUnlockedLevel) {
            _lastUnlockedLevel = currentProgress.level + 1;
            repository.unlockLevel(_lastUnlockedLevel);
            isNewLevelUnlocked = true;
          }
        }

        // Total Final Score (Base + Bonus)
        int totalFinalScore = (score * 100) + finalBonusScore;

        // Update stars if current score is better
        final currentStars = _levelStars[currentProgress.level] ?? 0;
        if (stars > currentStars) {
          _levelStars[currentProgress.level] = stars;
          repository.saveLevelStars(currentProgress.level, stars);
        }

        // Update high score
        final currentHighScore = _levelScores[currentProgress.level] ?? 0;
        if (totalFinalScore > currentHighScore) {
          _levelScores[currentProgress.level] = totalFinalScore;
          repository.saveLevelScore(currentProgress.level, totalFinalScore);
        }

        // Update High Bonus
        final currentHighBonus = _levelBonuses[currentProgress.level] ?? 0;
        if (finalBonusScore > currentHighBonus) {
          _levelBonuses[currentProgress.level] = finalBonusScore;
          repository.saveLevelBonus(currentProgress.level, finalBonusScore);
        }

        // Update centralized points system
        pointsCubit.addPoints('quiz', totalFinalScore);

        emit(
          QuizGameFinished(
            score: score,
            bonusScore: finalBonusScore,
            speedBonus: 0,
            streakBonus: 0,
            noAidsBonus: noAidsBonus,
            totalQuestions: totalQuestions,
            stars: stars,
            level: currentProgress.level,
            isNewLevelUnlocked: isNewLevelUnlocked,
            lastUnlockedLevel: _lastUnlockedLevel,
            levelStars: _levelStars,
            levelScores: _levelScores,
            levelBonuses: _levelBonuses,
          ),
        );
      }
    }
  }

  void exitGame() {
    _timer?.cancel();
    emit(
      QuizLevelsLoaded(
        lastUnlockedLevel: _lastUnlockedLevel,
        levelStars: _levelStars,
        levelScores: _levelScores,
        levelBonuses: _levelBonuses,
      ),
    );
  }

  void pauseTimer() {
    final currentState = state;
    if (currentState is QuizGameInProgress) {
      emit(currentState.copyWith(isTimeStopped: true));
    }
  }

  void resumeTimer() {
    final currentState = state;
    if (currentState is QuizGameInProgress) {
      emit(currentState.copyWith(isTimeStopped: false));
    }
  }

  void useStopTime() {
    final currentState = state;
    if (currentState is QuizGameInProgress && !currentState.isTimeStoppedUsed) {
      _timer?.cancel();
      emit(
        currentState.copyWith(
          isTimeStopped: true,
          isTimeStoppedUsed: true,
          isAidsUsed: true,
        ),
      );
    }
  }

  void useSkipQuestion() {
    final currentState = state;
    if (currentState is QuizGameInProgress && !currentState.isSkipUsed) {
      _timer?.cancel();
      final newScore = currentState.score + 1;
      emit(
        currentState.copyWith(
          isSkipUsed: true,
          score: newScore,
          isAidsUsed: true,
          streakCount: 0,
        ),
      );
      _nextQuestion(newScore, currentState.bonusScore, 0);
    }
  }

  void useFiftyFifty() {
    final currentState = state;
    if (currentState is QuizGameInProgress && !currentState.isFiftyFiftyUsed) {
      final currentQ =
          currentState.questions[currentState.currentQuestionIndex];
      final correctIdx = currentQ.correctIndex;

      List<int> incorrectIndices = [];
      for (int i = 0; i < currentQ.options.length; i++) {
        if (i != correctIdx) incorrectIndices.add(i);
      }
      incorrectIndices.shuffle();
      final removed = incorrectIndices.take(2).toList();

      emit(
        currentState.copyWith(
          isFiftyFiftyUsed: true,
          isAidsUsed: true,
          currentRemovedOptions: removed,
        ),
      );
    }
  }

  void useHint() {
    final currentState = state;
    if (currentState is QuizGameInProgress && !currentState.isHintUsed) {
      emit(
        currentState.copyWith(
          isHintUsed: true,
          showCurrentHint: true,
          isAidsUsed: true,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
