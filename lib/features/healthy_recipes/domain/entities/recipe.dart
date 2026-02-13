import 'package:equatable/equatable.dart';

class Recipe extends Equatable {
  final String id;
  final String nameEn;
  final String nameAr;
  final List<String> ingredientsEn;
  final List<String> ingredientsAr;
  final List<String> stepsEn;
  final List<String> stepsAr;
  final String videoUrl;
  final String imageUrl;

  const Recipe({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.ingredientsEn,
    required this.ingredientsAr,
    required this.stepsEn,
    required this.stepsAr,
    required this.videoUrl,
    required this.imageUrl,
  });

  String getName(String languageCode) => languageCode == 'ar' ? nameAr : nameEn;
  List<String> getIngredients(String languageCode) =>
      languageCode == 'ar' ? ingredientsAr : ingredientsEn;
  List<String> getSteps(String languageCode) =>
      languageCode == 'ar' ? stepsAr : stepsEn;

  @override
  List<Object?> get props => [
    id,
    nameEn,
    nameAr,
    ingredientsEn,
    ingredientsAr,
    stepsEn,
    stepsAr,
    videoUrl,
    imageUrl,
  ];
}
