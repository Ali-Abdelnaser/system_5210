import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:five2ten/features/nutrition_scan/domain/repositories/nutrition_repository.dart';
import 'nutrition_scan_state.dart';
import 'package:five2ten/features/nutrition_scan/domain/entities/nutrition_result.dart';

class NutritionScanCubit extends Cubit<NutritionScanState> {
  final NutritionRepository repository;
  static const int maxDailyScans = 5;

  NutritionScanCubit({required this.repository})
    : super(NutritionScanInitial());

  Future<void> analyzeImage(
    String imagePath,
    String languageCode,
    String userId,
  ) async {
    debugPrint(
      "Cubit: Starting Gemini Analysis for $imagePath in $languageCode for user $userId",
    );
    emit(NutritionScanLoading());

    try {
      // 1. Check Daily Limit
      final currentScans = await repository.getDailyScanCount(userId);
      if (currentScans >= maxDailyScans) {
        emit(NutritionScanLimitReached());
        return;
      }

      final data = await repository.analyzeImage(imagePath, languageCode);
      debugPrint("Cubit: Gemini Analysis Complete: $data");

      // Daily count is incremented when [ScanResultPage] opens (new scan only),
      // so cached analyses still consume a slot and the UI counter stays in sync.

      final bool isFromCache = data['_isFromCache'] as bool? ?? false;

      // Extract and Safely Cast Data
      final Map<String, double> nutrition = {};
      if (data['nutrition'] != null) {
        (data['nutrition'] as Map).forEach((k, v) {
          nutrition[k.toString()] = (v is num) ? v.toDouble() : 0.0;
        });
      }

      final int score = (data['health_score'] as num?)?.toInt() ?? 0;
      final String reason = data['health_reason']?.toString() ?? "";
      final List<String> harmful =
          (data['harmful_ingredients'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      final List<String> positives =
          (data['positives'] as List?)?.map((e) => e.toString()).toList() ?? [];
      final List<String> negatives =
          (data['negatives'] as List?)?.map((e) => e.toString()).toList() ?? [];
      final bool suitable = data['child_suitability'] as bool? ?? false;
      final String ageRange = data['child_age_range']?.toString() ?? "";
      final String medical = data['medical_advice']?.toString() ?? "";
      final String confidence = data['confidence']?.toString() ?? "Medium";
      final List<String> alternatives =
          (data['healthy_alternatives'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      final String impact = data['system_5210_impact']?.toString() ?? "";
      final String heroMsg = data['hero_message']?.toString() ?? "";

      // Create Breakdown List for UI (from positives/negatives)
      final List<Map<String, dynamic>> breakdown = [];
      for (var p in positives) {
        breakdown.add({'label': p, 'score': 5}); // Dummy score visual
      }
      for (var n in negatives) {
        breakdown.add({'label': n, 'score': -5});
      }

      emit(
        NutritionScanProcessed(
          nutritionValues: nutrition,
          healthScore: score,
          confidence: confidence,
          explanation: reason,
          breakdown: breakdown,
          detectedIngredients: harmful,
          suitableForChildren: suitable,
          childAgeRange: ageRange,
          medicalAdvice: medical,
          positives: positives,
          negatives: negatives,
          warnings: negatives, // Use negatives as warnings for now
          healthyAlternatives: alternatives,
          system5210Impact: impact,
          heroMessage: heroMsg,
          isFromCache: isFromCache,
        ),
      );
    } catch (e, stack) {
      debugPrint("Cubit ERROR: $e");
      debugPrint("Cubit STACK: $stack");
      // Show actual error for debugging
      emit(NutritionScanError("فشل في تحليل الصورة: ${e.toString()}"));
    }
  }

  Future<void> saveScanResult(NutritionResult result) async {
    // Avoid emitting [NutritionScanLoading]: it forces full-screen loaders on
    // Recent Scans (still in the stack) and feels like the app "reset".
    try {
      await repository.saveScanResult(result);
      emit(NutritionScanSuccess());
    } catch (e) {
      emit(const NutritionScanError("Failed to save scan result."));
    }
  }

  Future<void> loadRecentScans(String userId) async {
    emit(NutritionScanLoading());
    try {
      final scans = await repository.getRecentScans(userId);
      emit(RecentScansLoaded(scans));
    } catch (e) {
      emit(const NutritionScanError("Failed to load recent scans."));
    }
  }

  Future<void> deleteScanResult(String userId, DateTime timestamp) async {
    emit(NutritionScanLoading());
    try {
      await repository.deleteScanResult(userId, timestamp);
      await loadRecentScans(userId);
    } catch (e) {
      emit(const NutritionScanError("Failed to delete scan result."));
    }
  }

  Future<bool> validateImageText(String imagePath) async {
    return await repository.validateImageText(imagePath);
  }

  Future<bool> hasReachedLimit(String userId) async {
    final count = await repository.getDailyScanCount(userId);
    return count >= maxDailyScans;
  }

  Future<void> updateDailyScanCount(String userId) async {
    try {
      final count = await repository.getDailyScanCount(userId);
      emit(DailyScanCountLoaded(count));
    } catch (_) {}
  }

  /// Call when the user sees a new scan result (not history). Updates quota + intro counter.
  Future<void> recordScanCompletion(String userId) async {
    try {
      await repository.incrementDailyScanCount(userId);
      await updateDailyScanCount(userId);
    } catch (_) {}
  }

  void resetScanState() {
    emit(NutritionScanInitial());
  }
}
