import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_5210/features/game_center/presentation/manager/user_points_cubit.dart';
import 'package:system_5210/features/games/balanced_diet/data/models/game_ingredients_data.dart';
import 'package:system_5210/features/games/balanced_diet/domain/entities/ingredient_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:system_5210/features/games/balanced_diet/data/models/game_result_model.dart';
import 'package:system_5210/features/games/balanced_diet/domain/repositories/game_repository.dart';
import 'package:system_5210/features/games/food_matching/presentation/cubit/food_matching_state.dart';

class FoodMatchingCubit extends Cubit<FoodMatchingState> {
  final GameRepository repository;
  final FirebaseAuth auth;
  final UserPointsCubit pointsCubit;

  FoodMatchingCubit({
    required this.repository,
    required this.auth,
    required this.pointsCubit,
  }) : super(FoodMatchingInitial());

  void startGame() {
    emit(FoodMatchingLoading());

    // Combine all ingredients and pick 4 unique ones
    final allPool = [
      ...GameIngredientsData.healthyPool,
      ...GameIngredientsData.unhealthyPool,
    ]..shuffle();
    final selection = allPool.take(4).toList();

    // Create shuffled lists for words and images
    final words = List<IngredientEntity>.from(selection)..shuffle();
    final images = List<IngredientEntity>.from(selection)..shuffle();

    emit(
      FoodMatchingGameInProgress(
        words: words,
        images: images,
        startTime: DateTime.now(),
      ),
    );
  }

  void updateDrag(Offset start, Offset current, int wordIndex) {
    if (state is FoodMatchingGameInProgress) {
      final currentState = state as FoodMatchingGameInProgress;
      emit(
        currentState.copyWith(
          dragStart: start,
          dragCurrent: current,
          activeWordIndex: wordIndex,
        ),
      );
    }
  }

  void onDragEnd(String wordId, String? targetImageId) {
    if (state is FoodMatchingGameInProgress) {
      final currentState = state as FoodMatchingGameInProgress;

      if (targetImageId != null && wordId == targetImageId) {
        // Correct match
        final newMatches = Map<String, String>.from(currentState.matches);
        newMatches[wordId] = targetImageId;

        if (newMatches.length == 4) {
          _completeGame(currentState, newMatches);
        } else {
          emit(currentState.copyWith(matches: newMatches, clearDrag: true));
        }
      } else {
        // Wrong match or released outside
        emit(
          currentState.copyWith(
            wrongAttempts:
                currentState.wrongAttempts + (targetImageId != null ? 1 : 0),
            clearDrag: true,
          ),
        );
      }
    }
  }

  Future<void> _completeGame(
    FoodMatchingGameInProgress currentState,
    Map<String, String> finalMatches,
  ) async {
    final duration = DateTime.now().difference(currentState.startTime);
    final wrong = currentState.wrongAttempts;

    // Star calculation logic
    int stars = 1;
    if (wrong == 0 && duration.inSeconds < 15) {
      stars = 3;
    } else if (wrong <= 2 && duration.inSeconds < 25) {
      stars = 2;
    }

    final user = auth.currentUser;
    if (user != null) {
      final result = GameResultModel(
        gameId: 'food_matching',
        playedAt: DateTime.now(),
        selectedIngredientsIds: currentState.words.map((e) => e.id).toList(),
        isBalanced: true, // Matching is always balanced if successful
        healthyCount: 0, // Not applicable for this game
        unhealthyCount: 0,
        stars: stars,
      );
      await repository.saveGameResult(user.uid, result);

      // Add points to centralized system
      if (stars > 0) {
        int points = stars == 3 ? 100 : (stars == 2 ? 75 : 50);
        pointsCubit.addPoints('food_matching', points);
      }
    }

    emit(
      FoodMatchingSuccess(
        stars: stars,
        duration: duration,
        totalWrongAttempts: wrong,
      ),
    );
  }
}
