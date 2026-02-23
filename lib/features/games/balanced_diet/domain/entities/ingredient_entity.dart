import 'package:equatable/equatable.dart';

class IngredientEntity extends Equatable {
  final String id;
  final String name;
  final String imagePath;
  final String benefit;
  final bool isHealthy;

  const IngredientEntity({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.benefit,
    required this.isHealthy,
  });

  @override
  List<Object?> get props => [id, name, imagePath, isHealthy];
}
