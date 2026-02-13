import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:system_5210/features/nutrition_scan/data/models/nutrition_result_model.dart';
import 'package:system_5210/features/nutrition_scan/domain/entities/nutrition_result.dart';
import 'package:system_5210/features/nutrition_scan/domain/repositories/nutrition_repository.dart';
import 'package:system_5210/features/nutrition_scan/domain/services/gemini_analysis_service.dart';
import 'package:system_5210/core/services/local_storage_service.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'nutrition_scans';
  final GeminiAnalysisService _geminiService = GeminiAnalysisService();
  final LocalStorageService _localStorage;
  final String _cacheBox = 'scans_cache';

  NutritionRepositoryImpl(this._localStorage);

  @override
  Future<void> saveScanResult(NutritionResult result) async {
    final model = NutritionResultModel.fromEntity(result);

    // 1. Always save to Local History first
    await _localStorage.save(
      'scan_history',
      result.timestamp.toIso8601String(),
      model.toJson(forRemote: false),
    );

    // 2. Try saving to Cloud
    try {
      await _firestore
          .collection(_collection)
          .add(model.toJson(forRemote: true));
    } catch (e) {
      debugPrint("Cloud save failed, saved locally only: $e");
      // We don't throw here so the UI can proceed as if saved (it IS saved locally)
    }
  }

  @override
  Future<List<NutritionResult>> getRecentScans(String userId) async {
    List<NutritionResult> uniqueScans = [];

    // 1. Load Local first (Quickest)
    try {
      final localData = await _localStorage.getAll('scan_history');
      final validLocalScans = <NutritionResult>[];

      for (var item in localData) {
        try {
          // Robust parsing
          if (item is Map) {
            final scan = NutritionResultModel.fromJson(
              Map<String, dynamic>.from(item),
              'local',
            );
            if (scan.userId == userId) {
              validLocalScans.add(scan);
            }
          }
        } catch (e) {
          debugPrint("Repository: Error parsing a local scan: $e");
        }
      }

      uniqueScans = validLocalScans;
      debugPrint(
        "Repository: Loaded ${uniqueScans.length} valid scans from local.",
      );
    } catch (e) {
      debugPrint("Repository: Error loading local scans: $e");
    }

    // 2. Try fetching from Remote and Sync
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      final remoteScans = querySnapshot.docs.map((doc) {
        return NutritionResultModel.fromJson(doc.data(), doc.id);
      }).toList();

      debugPrint(
        "Repository: Fetched ${remoteScans.length} scans from Firestore.",
      );

      if (remoteScans.isNotEmpty) {
        // Prepare a map for merging (Timestamp -> Result)
        // Using timestamp as key because our local keys are timestamps
        final Map<String, NutritionResult> mergedMap = {};

        // Add local first
        for (var s in uniqueScans) {
          mergedMap[s.timestamp.toIso8601String()] = s;
        }

        // Apply remotes (overwrite local if exists) and Sync to Local Storage
        for (var scan in remoteScans) {
          final key = scan.timestamp.toIso8601String();
          mergedMap[key] = scan;

          final model = NutritionResultModel.fromEntity(scan);
          await _localStorage.save(
            'scan_history',
            key,
            model.toJson(forRemote: false),
          );
        }

        uniqueScans = mergedMap.values.toList();
      }
    } catch (e) {
      debugPrint("Repository: Firestore fetch/sync failed: $e");
    }

    // 3. Sort by timestamp descending
    uniqueScans.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return uniqueScans;
  }

  @override
  Future<Map<String, dynamic>> analyzeImage(
    String imagePath,
    String languageCode,
  ) async {
    // 1. Generate Hash (including languageCode to cache per language)
    final file = File(imagePath);
    if (!await file.exists()) throw Exception("File not found");
    final bytes = await file.readAsBytes();
    final hash = md5.convert([
      ...bytes,
      ...utf8.encode(languageCode),
    ]).toString();

    // 2. Check Cache
    final cached = await _localStorage.get(_cacheBox, hash);
    if (cached != null) {
      debugPrint("Returning cached analysis for $languageCode");
      cached['_isFromCache'] = true;
      return cached;
    }

    // 3. Local OCR Check (Security/Cost optimization)
    debugPrint("Performing Local OCR Check...");
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer();
    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      // If text count is extremely low, it's likely not a label or very blurry
      if (recognizedText.text.trim().length < 15) {
        throw Exception(
          languageCode == 'ar'
              ? "الصورة غير واضحة أو لا تحتوي على نص كافٍ. يرجى المحاولة مرة أخرى."
              : "The image is blurry or doesn't contain enough text. Please try again.",
        );
      }
      debugPrint(
        "Local OCR passed. Text length: ${recognizedText.text.length}",
      );
    } finally {
      textRecognizer.close();
    }

    // 4. Call Gemini
    final result = await _geminiService.analyzeImage(imagePath, languageCode);

    // 5. Save to Cache
    await _localStorage.save(_cacheBox, hash, result);

    return result;
  }

  @override
  Future<void> deleteScanResult(String userId, DateTime timestamp) async {
    final key = timestamp.toIso8601String();

    // 1. Delete from Local Storage
    await _localStorage.delete('scan_history', key);

    // 2. Delete from Remote (Firestore)
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('timestamp', isEqualTo: Timestamp.fromDate(timestamp))
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint("Repository: Error deleting remote scan: $e");
    }
  }
}
