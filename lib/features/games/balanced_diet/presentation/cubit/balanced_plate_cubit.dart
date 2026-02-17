import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_5210/core/utils/app_images.dart';
import '../../data/models/game_result_model.dart';
import '../../data/models/game_ingredients_data.dart';
import '../../domain/entities/ingredient_entity.dart';
import '../../domain/repositories/game_repository.dart';
import 'balanced_plate_state.dart';

class BalancedPlateCubit extends Cubit<BalancedPlateState> {
  final GameRepository repository;
  final FirebaseAuth auth;
  final AudioPlayer _audioPlayer = AudioPlayer();

  BalancedPlateCubit({required this.repository, required this.auth})
    : super(BalancedPlateInitial());

  void startGame() {
    // Pick 5 random healthy items
    final selectedHealthy = List<IngredientEntity>.from(
      GameIngredientsData.healthyPool,
    )..shuffle();
    final healthySubset = selectedHealthy.take(5).toList();

    // Pick 5 random unhealthy items
    final selectedUnhealthy = List<IngredientEntity>.from(
      GameIngredientsData.unhealthyPool,
    )..shuffle();
    final unhealthySubset = selectedUnhealthy.take(5).toList();

    // Combine and shuffle for the game board
    final gameIngredients = [...healthySubset, ...unhealthySubset]..shuffle();

    emit(
      BalancedPlateGameInProgress(
        allIngredients: gameIngredients,
        selectedIngredients: const [],
      ),
    );
  }

  void addIngredient(IngredientEntity ingredient) {
    if (state is BalancedPlateGameInProgress) {
      final currentState = state as BalancedPlateGameInProgress;
      if (currentState.selectedIngredients.contains(ingredient)) return;
      if (currentState.selectedIngredients.length >= 5) return;

      final selected = List<IngredientEntity>.from(
        currentState.selectedIngredients,
      )..add(ingredient);

      HapticFeedback.mediumImpact();
      _playSound('audio/games/game1/pop.mp3');

      // Tip based on healthiness
      final tip = ingredient.isHealthy
          ? 'اختيار ممتاز وصحي'
          : 'حاول تختار أكل صحي أكتر';

      emit(
        BalancedPlateGameInProgress(
          allIngredients: currentState.allIngredients,
          selectedIngredients: selected,
          feedbackMessage: tip,
          lastAddedIsHealthy: ingredient.isHealthy,
        ),
      );

      // Auto-dismiss feedback after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (!isClosed && state is BalancedPlateGameInProgress) {
          final nextState = state as BalancedPlateGameInProgress;
          if (nextState.feedbackMessage == tip) {
            emit(
              BalancedPlateGameInProgress(
                allIngredients: nextState.allIngredients,
                selectedIngredients: nextState.selectedIngredients,
                lastAddedIsHealthy: nextState.lastAddedIsHealthy,
                feedbackMessage: null,
              ),
            );
          }
        }
      });
    }
  }

  void removeIngredient(IngredientEntity ingredient) {
    if (state is BalancedPlateGameInProgress) {
      final currentState = state as BalancedPlateGameInProgress;
      final selected = List<IngredientEntity>.from(
        currentState.selectedIngredients,
      )..remove(ingredient);

      emit(
        BalancedPlateGameInProgress(
          allIngredients: currentState.allIngredients,
          selectedIngredients: selected,
        ),
      );
    }
  }

  Future<void> submitPlate() async {
    if (state is BalancedPlateGameInProgress) {
      final selected =
          (state as BalancedPlateGameInProgress).selectedIngredients;
      if (selected.length < 5) return;

      final healthyCount = selected.where((i) => i.isHealthy).length;
      final isBalanced = healthyCount >= 3;

      int stars = 0;
      if (healthyCount == 5)
        stars = 3;
      else if (healthyCount == 4)
        stars = 2;
      else if (healthyCount == 3)
        stars = 1;

      final charIndex = Random().nextInt(4) + 1;
      final characterPath = isBalanced
          ? _getSuccessChar(charIndex)
          : _getFailChar(charIndex);

      if (isBalanced) {
        _playSound('audio/games/game1/success.mp3');
      } else {
        _playSound('audio/games/game1/fail.mp3');
      }

      emit(BalancedPlateLoading());

      final user = auth.currentUser;
      if (user != null) {
        final result = GameResultModel(
          gameId: 'game1',
          playedAt: DateTime.now(),
          selectedIngredientsIds: selected.map((i) => i.id).toList(),
          isBalanced: isBalanced,
          healthyCount: healthyCount,
          unhealthyCount: 5 - healthyCount,
          stars: stars,
        );
        await repository.saveGameResult(user.uid, result);
      }

      emit(
        BalancedPlateSuccess(
          isBalanced: isBalanced,
          selectedIngredients: selected,
          stars: stars,
          characterImagePath: characterPath,
        ),
      );
    }
  }

  String _getSuccessChar(int index) {
    if (index == 1) return AppImages.gameSuccess1;
    if (index == 2) return AppImages.gameSuccess2;
    if (index == 3) return AppImages.gameSuccess3;
    return AppImages.gameSuccess4;
  }

  String _getFailChar(int index) {
    if (index == 1) return AppImages.gameFail1;
    if (index == 2) return AppImages.gameFail2;
    if (index == 3) return AppImages.gameFail3;
    return AppImages.gameFail4;
  }

  Future<void> _playSound(String path) async {
    try {
      await _audioPlayer.play(AssetSource(path));
    } catch (e) {
      /* ignore */
    }
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}
