import 'package:equatable/equatable.dart';
import '../../domain/entities/ingredient_entity.dart';

abstract class BalancedPlateState extends Equatable {
  const BalancedPlateState();

  @override
  List<Object?> get props => [];
}

class BalancedPlateInitial extends BalancedPlateState {}

class BalancedPlateLoading extends BalancedPlateState {}

class BalancedPlateGameInProgress extends BalancedPlateState {
  final List<IngredientEntity> allIngredients;
  final List<IngredientEntity> selectedIngredients;
  final String? feedbackMessage;
  final bool? lastAddedIsHealthy;

  const BalancedPlateGameInProgress({
    required this.allIngredients,
    required this.selectedIngredients,
    this.feedbackMessage,
    this.lastAddedIsHealthy,
  });

  @override
  List<Object?> get props => [
    allIngredients,
    selectedIngredients,
    feedbackMessage,
    lastAddedIsHealthy,
  ];
}

class BalancedPlateSuccess extends BalancedPlateState {
  final bool isBalanced;
  final List<IngredientEntity> selectedIngredients;
  final int stars;
  final String characterImagePath;

  const BalancedPlateSuccess({
    required this.isBalanced,
    required this.selectedIngredients,
    required this.stars,
    required this.characterImagePath,
  });

  @override
  List<Object?> get props => [
    isBalanced,
    selectedIngredients,
    stars,
    characterImagePath,
  ];
}

class BalancedPlateFailure extends BalancedPlateState {
  final String message;

  const BalancedPlateFailure(this.message);

  @override
  List<Object?> get props => [message];
}
