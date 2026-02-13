import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:system_5210/features/nutrition_scan/domain/entities/nutrition_result.dart';

class NutritionResultModel extends NutritionResult {
  const NutritionResultModel({
    required super.id,
    required super.userId,
    required super.timestamp,
    required super.nutritionValues,
    required super.healthScore,
    super.healthScoreReason = '',
    required super.confidenceLevel,
    super.positives = const [],
    super.negatives = const [],
    super.warnings = const [],
    super.suitableForChildren = true,
    super.childAgeRange = '',
    super.medicalAdvice = '',
    required super.explanation,
    super.isApproximate,
    super.healthyAlternatives = const [],
    super.system5210Impact = '',
    super.heroMessage = '',
  });

  factory NutritionResultModel.fromJson(Map<String, dynamic> json, String id) {
    DateTime timestamp;
    if (json['timestamp'] is Timestamp) {
      timestamp = (json['timestamp'] as Timestamp).toDate();
    } else if (json['timestamp'] is String) {
      timestamp = DateTime.parse(json['timestamp']);
    } else {
      timestamp = DateTime.now();
    }

    return NutritionResultModel(
      id: id,
      userId: json['userId'] ?? '',
      timestamp: timestamp,
      nutritionValues: (json['nutritionValues'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      healthScore: json['healthScore'] ?? 0,
      healthScoreReason: json['healthScoreReason'] ?? '',
      confidenceLevel: json['confidenceLevel'] ?? 'Low',
      positives: List<String>.from(json['positives'] ?? []),
      negatives: List<String>.from(json['negatives'] ?? []),
      warnings: List<String>.from(json['warnings'] ?? []),
      suitableForChildren: json['suitableForChildren'] ?? true,
      childAgeRange: json['childAgeRange'] ?? '',
      medicalAdvice: json['medicalAdvice'] ?? '',
      explanation: json['explanation'] ?? '',
      isApproximate: json['isApproximate'] ?? false,
      healthyAlternatives: List<String>.from(json['healthyAlternatives'] ?? []),
      system5210Impact: json['system5210Impact'] ?? '',
      heroMessage: json['heroMessage'] ?? '',
    );
  }

  Map<String, dynamic> toJson({bool forRemote = true}) {
    return {
      'userId': userId,
      'timestamp': forRemote
          ? Timestamp.fromDate(timestamp)
          : timestamp.toIso8601String(),
      'nutritionValues': nutritionValues,
      'healthScore': healthScore,
      'healthScoreReason': healthScoreReason,
      'confidenceLevel': confidenceLevel,
      'positives': positives,
      'negatives': negatives,
      'warnings': warnings,
      'suitableForChildren': suitableForChildren,
      'childAgeRange': childAgeRange,
      'medicalAdvice': medicalAdvice,
      'explanation': explanation,
      'isApproximate': isApproximate,
      'healthyAlternatives': healthyAlternatives,
      'system5210Impact': system5210Impact,
      'heroMessage': heroMessage,
    };
  }

  factory NutritionResultModel.fromEntity(NutritionResult entity) {
    return NutritionResultModel(
      id: entity.id,
      userId: entity.userId,
      timestamp: entity.timestamp,
      nutritionValues: entity.nutritionValues,
      healthScore: entity.healthScore,
      healthScoreReason: entity.healthScoreReason,
      confidenceLevel: entity.confidenceLevel,
      positives: entity.positives,
      negatives: entity.negatives,
      warnings: entity.warnings,
      suitableForChildren: entity.suitableForChildren,
      childAgeRange: entity.childAgeRange,
      medicalAdvice: entity.medicalAdvice,
      explanation: entity.explanation,
      isApproximate: entity.isApproximate,
      healthyAlternatives: entity.healthyAlternatives,
      system5210Impact: entity.system5210Impact,
      heroMessage: entity.heroMessage,
    );
  }
}
