import 'package:equatable/equatable.dart';
import '../../domain/entities/quiz_question_entity.dart';

abstract class QuizState extends Equatable {
  final int lastUnlockedLevel;
  final Map<int, int> levelStars;
  final Map<int, int> levelScores;
  final Map<int, int> levelBonuses;

  const QuizState({
    this.lastUnlockedLevel = 1,
    this.levelStars = const {},
    this.levelScores = const {},
    this.levelBonuses = const {},
  });

  @override
  List<Object?> get props => [
    lastUnlockedLevel,
    levelStars,
    levelScores,
    levelBonuses,
  ];
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {
  const QuizLoading({
    super.lastUnlockedLevel,
    super.levelStars,
    super.levelScores,
    super.levelBonuses,
  });
}

class QuizLevelsLoaded extends QuizState {
  const QuizLevelsLoaded({
    required super.lastUnlockedLevel,
    required super.levelStars,
    required super.levelScores,
    required super.levelBonuses,
  });
}

class QuizGameInProgress extends QuizState {
  final List<QuizQuestion> questions;
  final int currentQuestionIndex;
  final int score;
  final int level; // Current playing level
  final int timerSeconds;
  final bool? isLastAnswerCorrect;
  final int? selectedOptionIndex;

  // Lifelines
  final bool isTimeStopped;
  final bool isTimeStoppedUsed;
  final bool isFiftyFiftyUsed;
  final bool isSkipUsed;
  final bool isHintUsed;
  final List<int> currentRemovedOptions;
  final bool showCurrentHint;
  final bool isTutorialVisible;

  // Bonus System
  final int bonusScore;
  final int streakCount;
  final bool isAidsUsed;

  const QuizGameInProgress({
    required this.questions,
    required this.currentQuestionIndex,
    required this.score,
    required this.level,
    required this.timerSeconds,
    required super.lastUnlockedLevel,
    required super.levelStars,
    required super.levelScores,
    required super.levelBonuses,
    this.isLastAnswerCorrect,
    this.selectedOptionIndex,
    this.isTimeStopped = false,
    this.isTimeStoppedUsed = false,
    this.isFiftyFiftyUsed = false,
    this.isSkipUsed = false,
    this.isHintUsed = false,
    this.currentRemovedOptions = const [],
    this.showCurrentHint = false,
    this.isTutorialVisible = false,
    this.bonusScore = 0,
    this.streakCount = 0,
    this.isAidsUsed = false,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    questions,
    currentQuestionIndex,
    score,
    bonusScore,
    streakCount,
    isAidsUsed,
    level,
    timerSeconds,
    isLastAnswerCorrect,
    selectedOptionIndex,
    isTimeStopped,
    isTimeStoppedUsed,
    isFiftyFiftyUsed,
    isSkipUsed,
    isHintUsed,
    currentRemovedOptions,
    showCurrentHint,
    isTutorialVisible,
  ];

  QuizGameInProgress copyWith({
    List<QuizQuestion>? questions,
    int? currentQuestionIndex,
    int? score,
    int? bonusScore,
    int? streakCount,
    bool? isAidsUsed,
    int? level,
    int? timerSeconds,
    int? lastUnlockedLevel,
    Map<int, int>? levelStars,
    Map<int, int>? levelScores,
    Map<int, int>? levelBonuses,
    bool? isLastAnswerCorrect,
    int? selectedOptionIndex,
    bool? isTimeStopped,
    bool? isTimeStoppedUsed,
    bool? isFiftyFiftyUsed,
    bool? isSkipUsed,
    bool? isHintUsed,
    List<int>? currentRemovedOptions,
    bool? showCurrentHint,
    bool? isTutorialVisible,
  }) {
    return QuizGameInProgress(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      score: score ?? this.score,
      bonusScore: bonusScore ?? this.bonusScore,
      streakCount: streakCount ?? this.streakCount,
      isAidsUsed: isAidsUsed ?? this.isAidsUsed,
      level: level ?? this.level,
      timerSeconds: timerSeconds ?? this.timerSeconds,
      lastUnlockedLevel: lastUnlockedLevel ?? this.lastUnlockedLevel,
      levelStars: levelStars ?? this.levelStars,
      levelScores: levelScores ?? this.levelScores,
      levelBonuses: levelBonuses ?? this.levelBonuses,
      isLastAnswerCorrect: isLastAnswerCorrect,
      selectedOptionIndex: selectedOptionIndex,
      isTimeStopped: isTimeStopped ?? this.isTimeStopped,
      isTimeStoppedUsed: isTimeStoppedUsed ?? this.isTimeStoppedUsed,
      isFiftyFiftyUsed: isFiftyFiftyUsed ?? this.isFiftyFiftyUsed,
      isSkipUsed: isSkipUsed ?? this.isSkipUsed,
      isHintUsed: isHintUsed ?? this.isHintUsed,
      currentRemovedOptions:
          currentRemovedOptions ?? this.currentRemovedOptions,
      showCurrentHint: showCurrentHint ?? this.showCurrentHint,
      isTutorialVisible: isTutorialVisible ?? this.isTutorialVisible,
    );
  }
}

class QuizGameFinished extends QuizState {
  final int score;
  final int bonusScore;
  final int speedBonus;
  final int streakBonus;
  final int noAidsBonus;
  final int totalQuestions;
  final int stars;
  final int level;
  final bool isNewLevelUnlocked;

  const QuizGameFinished({
    required this.score,
    required this.bonusScore,
    required this.speedBonus,
    required this.streakBonus,
    required this.noAidsBonus,
    required this.totalQuestions,
    required this.stars,
    required this.level,
    required this.isNewLevelUnlocked,
    required super.lastUnlockedLevel,
    required super.levelStars,
    required super.levelScores,
    required super.levelBonuses,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    score,
    bonusScore,
    speedBonus,
    streakBonus,
    noAidsBonus,
    totalQuestions,
    stars,
    level,
    isNewLevelUnlocked,
  ];
}

class QuizError extends QuizState {
  final String message;

  const QuizError({
    required this.message,
    super.lastUnlockedLevel,
    super.levelStars,
    super.levelScores,
    super.levelBonuses,
  });

  @override
  List<Object?> get props => [...super.props, message];
}
