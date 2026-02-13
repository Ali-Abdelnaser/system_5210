import 'package:system_5210/features/healthy_recipes/domain/entities/recipe.dart';

class RecipeModel extends Recipe {
  const RecipeModel({
    required super.id,
    required super.nameEn,
    required super.nameAr,
    required super.ingredientsEn,
    required super.ingredientsAr,
    required super.stepsEn,
    required super.stepsAr,
    required super.videoUrl,
    required super.imageUrl,
  });

  factory RecipeModel.fromFirestore(
    Map<String, dynamic> json,
    String documentId,
  ) {
    return RecipeModel(
      id: documentId,
      nameEn: json['nameEn'] ?? '',
      nameAr: json['nameAr'] ?? '',
      ingredientsEn: List<String>.from(json['ingredientsEn'] ?? []),
      ingredientsAr: List<String>.from(json['ingredientsAr'] ?? []),
      stepsEn: List<String>.from(json['stepsEn'] ?? []),
      stepsAr: List<String>.from(json['stepsAr'] ?? []),
      videoUrl: json['videoUrl'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nameEn': nameEn,
      'nameAr': nameAr,
      'ingredientsEn': ingredientsEn,
      'ingredientsAr': ingredientsAr,
      'stepsEn': stepsEn,
      'stepsAr': stepsAr,
      'videoUrl': videoUrl,
      'imageUrl': imageUrl,
    };
  }
}
