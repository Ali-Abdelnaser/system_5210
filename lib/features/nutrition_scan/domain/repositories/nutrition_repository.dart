import 'package:five2ten/features/nutrition_scan/domain/entities/nutrition_result.dart';

abstract class NutritionRepository {
  Future<void> saveScanResult(NutritionResult result);
  Future<List<NutritionResult>> getRecentScans(String userId);
  Future<Map<String, dynamic>> analyzeImage(
    String imagePath,
    String languageCode,
  );
  Future<void> deleteScanResult(String userId, DateTime timestamp);
  Future<int> getDailyScanCount(String userId);
  Future<void> incrementDailyScanCount(String userId);
  Future<bool> validateImageText(String imagePath);
}
