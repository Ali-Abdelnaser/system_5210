import 'package:system_5210/features/nutrition_scan/domain/entities/nutrition_result.dart';

abstract class NutritionRepository {
  Future<void> saveScanResult(NutritionResult result);
  Future<List<NutritionResult>> getRecentScans(String userId);
  Future<Map<String, dynamic>> analyzeImage(
    String imagePath,
    String languageCode,
  );
  Future<void> deleteScanResult(String userId, DateTime timestamp);
}
