import 'package:equatable/equatable.dart';

class NutritionResult extends Equatable {
  final String id;
  final String userId;
  final DateTime timestamp;

  // Basic Nutrition
  final Map<String, double> nutritionValues;

  // Health Score
  final int healthScore;
  final String healthScoreReason;
  final String confidenceLevel; // High, Medium, Low

  // Detailed Analysis
  final List<String> positives;
  final List<String> negatives;
  final List<String> warnings; // High Sugar, etc.

  // Child Suitability
  final bool suitableForChildren;
  final String childAgeRange;

  // Medical & Advice
  final String medicalAdvice;
  final String explanation; // Kept for backward compatibility
  final bool isApproximate;

  // New Fields for Enhanced Experience
  final List<String> healthyAlternatives;
  final String system5210Impact;
  final String heroMessage;

  const NutritionResult({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.nutritionValues,
    required this.healthScore,
    this.healthScoreReason = '',
    required this.confidenceLevel,
    this.positives = const [],
    this.negatives = const [],
    this.warnings = const [],
    this.suitableForChildren = true,
    this.childAgeRange = '',
    this.medicalAdvice = '',
    required this.explanation,
    this.isApproximate = false,
    this.healthyAlternatives = const [],
    this.system5210Impact = '',
    this.heroMessage = '',
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    timestamp,
    nutritionValues,
    healthScore,
    confidenceLevel,
    healthScoreReason,
    positives,
    negatives,
    warnings,
    suitableForChildren,
    childAgeRange,
    medicalAdvice,
    explanation,
    isApproximate,
    healthyAlternatives,
    system5210Impact,
    heroMessage,
  ];
}
