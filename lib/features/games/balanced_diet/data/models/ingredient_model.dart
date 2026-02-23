import '../../domain/entities/ingredient_entity.dart';

class IngredientModel extends IngredientEntity {
  const IngredientModel({
    required super.id,
    required super.name,
    required super.imagePath,
    required super.benefit,
    required super.isHealthy,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      id: json['id'],
      name: json['name'],
      imagePath: json['imagePath'],
      benefit: json['benefit'] ?? '',
      isHealthy: json['isHealthy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'benefit': benefit,
      'isHealthy': isHealthy,
    };
  }
}
