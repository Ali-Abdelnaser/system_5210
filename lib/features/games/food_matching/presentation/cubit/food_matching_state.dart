import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:system_5210/features/games/balanced_diet/domain/entities/ingredient_entity.dart';

abstract class FoodMatchingState extends Equatable {
  const FoodMatchingState();

  @override
  List<Object?> get props => [];
}

class FoodMatchingInitial extends FoodMatchingState {}

class FoodMatchingLoading extends FoodMatchingState {}

class FoodMatchingGameInProgress extends FoodMatchingState {
  final List<IngredientEntity> words; // Left column (shuffled)
  final List<IngredientEntity> images; // Right column (shuffled differently)
  final Map<String, String> matches; // wordId -> imageId
  final Offset? dragStart;
  final Offset? dragCurrent;
  final int? activeWordIndex;
  final int wrongAttempts;
  final DateTime startTime;

  const FoodMatchingGameInProgress({
    required this.words,
    required this.images,
    this.matches = const {},
    this.dragStart,
    this.dragCurrent,
    this.activeWordIndex,
    this.wrongAttempts = 0,
    required this.startTime,
  });

  @override
  List<Object?> get props => [
    words,
    images,
    matches,
    dragStart,
    dragCurrent,
    activeWordIndex,
    wrongAttempts,
    startTime,
  ];

  FoodMatchingGameInProgress copyWith({
    List<IngredientEntity>? words,
    List<IngredientEntity>? images,
    Map<String, String>? matches,
    Offset? dragStart,
    Offset? dragCurrent,
    int? activeWordIndex,
    bool clearDrag = false,
    int? wrongAttempts,
  }) {
    return FoodMatchingGameInProgress(
      words: words ?? this.words,
      images: images ?? this.images,
      matches: matches ?? this.matches,
      dragStart: clearDrag ? null : (dragStart ?? this.dragStart),
      dragCurrent: clearDrag ? null : (dragCurrent ?? this.dragCurrent),
      activeWordIndex: clearDrag
          ? null
          : (activeWordIndex ?? this.activeWordIndex),
      wrongAttempts: wrongAttempts ?? this.wrongAttempts,
      startTime: this.startTime,
    );
  }
}

class FoodMatchingSuccess extends FoodMatchingState {
  final int stars;
  final Duration duration;
  final int totalWrongAttempts;

  const FoodMatchingSuccess({
    required this.stars,
    required this.duration,
    required this.totalWrongAttempts,
  });

  @override
  List<Object?> get props => [stars, duration, totalWrongAttempts];
}
