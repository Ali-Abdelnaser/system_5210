import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:system_5210/core/utils/image_compressor.dart';

class GeminiAnalysisService {
  late final GenerativeModel _model;

  GeminiAnalysisService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint("CRITICAL: Gemini API Key is missing in .env!");
      throw Exception("Gemini API Key is missing. Check your .env file.");
    }
    debugPrint(
      "Gemini Service Initialized. Key found (Length: ${apiKey.length})",
    );
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.0,
        topP: 0.95,
        topK: 40,
      ),
    );

    // الموديل الاحتياطي (في حالة وصولنا للـ Limit الخاص بـ 2.0)
    _fallbackModel = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.0,
        topP: 0.95,
        topK: 40,
      ),
    );
  }

  late final GenerativeModel _fallbackModel;

  Future<Map<String, dynamic>> analyzeImage(
    String imagePath,
    String languageCode,
  ) async {
    try {
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw Exception("Image file not found");
      }

      debugPrint("Starting Image Optimization...");
      // Optimize Image using native compression
      final imageBytes = await ImageCompressor.compressBytes(
        await imageFile.readAsBytes(),
      );
      debugPrint(
        "Image Optimized. Size: ${(imageBytes.length / 1024).toStringAsFixed(2)} KB",
      );

      final prompt = TextPart(_getAnalysisPrompt(languageCode));
      final imagePart = DataPart('image/webp', imageBytes);

      GenerateContentResponse response;
      try {
        response = await _model.generateContent([
          Content.multi([prompt, imagePart]),
        ]);
      } catch (e) {
        debugPrint("Primary Model Failed, trying fallback: $e");
        // محاولة أخيرة باستخدام الموديل الاحتياطي
        response = await _fallbackModel.generateContent([
          Content.multi([prompt, imagePart]),
        ]);
      }

      debugPrint("Gemini Response: ${response.text}");

      if (response.text == null) throw Exception("Empty response from Gemini");

      return _parseResponse(response.text!);
    } catch (e) {
      debugPrint("Gemini Analysis Error: $e");
      rethrow;
    }
  }

  String _getAnalysisPrompt(String lang) {
    bool isAr = lang == 'ar';
    String langName = isAr ? "Arabic" : "English";

    return """
    You are a professional Family Nutrition Consultant assisting a mother in making healthy choices for her family's diet. 
    The app is called 'System 5210' (5 fruit/veg, 2h screen limit, 1h activity, 0 sugary drinks).

    Analyze this food label with a focus on FAMILY HEALTH and PARENTING. 

    CRITICAL ANALYSIS:
    1. EXTRACT NUTRITION: Extract macros (g) and sodium (mg) with 100% accuracy.
    2. MOTHER'S INSIGHT: Instead of just data, provide a 'Mother's Memo'. For example: "Perfect for the lunchbox", "High in hidden sugars", or "Good energy for club days".
    3. LANGUAGE: Provide ALL responses in $langName. Use a supportive, clear, and professional tone.

    JSON STRUCTURE:
    {
      "nutrition": {
        "calories": 0.0, "total_fat": 0.0, "saturated_fat": 0.0, "sugar": 0.0, "sodium": 0.0, "protein": 0.0, "fiber": 0.0, "carbohydrates": 0.0
      },
      "health_score": 85,
      "health_reason": "${isAr ? "شرح موجز جداً للأم..." : "Very brief explanation for the mother..."}",
      "harmful_ingredients": [],
      "positives": [],
      "negatives": [],
      "child_suitability": true,
      "child_age_range": "2+",
      "medical_advice": "${isAr ? "نصيحة طبية مختصرة..." : "Short medical advice..."}",
      "healthy_alternatives": [${isAr ? "\"خيار صحي 1\", \"خيار صحي 2\"" : "\"Healthy Option 1\", \"Healthy Option 2\""}],
      "system_5210_impact": "${isAr ? "تأثير نظام 5210 (مختصر)..." : "5210 impact (brief)..."}",
      "hero_message": "${isAr ? "نصيحة ذكية للأم: مثلاً 'هذا المنتج رائع للنشاط البدني لطفلك اليوم'." : "A smart tip for the mother: e.g., 'Great for your child's physical activity today'."}",
      "confidence": "High"
    }
    """;
  }

  Map<String, dynamic> _parseResponse(String text) {
    try {
      // Clean potential Markdown
      String cleanText = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      return jsonDecode(cleanText);
    } catch (e) {
      debugPrint("JSON Parse Error: $e");
      throw Exception("Failed to parse analysis results");
    }
  }
}
