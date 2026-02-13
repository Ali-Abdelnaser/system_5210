import 'package:equatable/equatable.dart';
import 'package:system_5210/features/nutrition_scan/domain/entities/nutrition_result.dart';

abstract class NutritionScanState extends Equatable {
  const NutritionScanState();

  @override
  List<Object?> get props => [];
}

class NutritionScanInitial extends NutritionScanState {}

class NutritionScanLoading extends NutritionScanState {}

class NutritionScanProcessed extends NutritionScanState {
  final Map<String, double> nutritionValues;
  final int healthScore;
  final String confidence;
  final String explanation;
  final List<Map<String, dynamic>> breakdown;
  final List<String> detectedIngredients;

  // Advanced AI Fields
  final bool suitableForChildren;
  final String childAgeRange;
  final String medicalAdvice;
  final List<String> positives;
  final List<String> negatives;
  final List<String> warnings;

  final List<String> healthyAlternatives;
  final String system5210Impact;
  final String heroMessage;

  final bool isFromCache;

  const NutritionScanProcessed({
    required this.nutritionValues,
    required this.healthScore,
    required this.confidence,
    required this.explanation,
    this.breakdown = const [],
    this.detectedIngredients = const [],
    this.suitableForChildren = true,
    this.childAgeRange = '',
    this.medicalAdvice = '',
    this.positives = const [],
    this.negatives = const [],
    this.warnings = const [],
    this.healthyAlternatives = const [],
    this.system5210Impact = '',
    this.heroMessage = '',
    this.isFromCache = false,
  });

  @override
  List<Object> get props => [
    nutritionValues,
    healthScore,
    confidence,
    explanation,
    breakdown,
    detectedIngredients,
    suitableForChildren,
    childAgeRange,
    medicalAdvice,
    positives,
    negatives,
    warnings,
    healthyAlternatives,
    system5210Impact,
    heroMessage,
  ];
}

class RecentScansLoaded extends NutritionScanState {
  final List<NutritionResult> scans;
  const RecentScansLoaded(this.scans);

  @override
  List<Object> get props => [scans];
}

class NutritionScanError extends NutritionScanState {
  final String message;
  const NutritionScanError(this.message);

  @override
  List<Object> get props => [message];
}

class NutritionScanSuccess extends NutritionScanState {}
