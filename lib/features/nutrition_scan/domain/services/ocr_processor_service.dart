import 'package:flutter/foundation.dart';

class OCRProcessorService {
  // Definitions for Keywords and Harmful Ingredients
  static final Map<String, List<String>> _keywords = {
    'calories': [
      'calories',
      'energy',
      'kcal',
      'cal',
      'kj',
      'الطاقة',
      'السعرات',
      'الحرارية',
    ],
    'total_fat': ['total fat', 'fat', 'الدهون', 'إجمالي الدهون', 'lipides'],
    'saturated_fat': [
      'saturated fat',
      'saturated',
      'sat fat',
      'الدهون المشبعة',
      'مشبعة',
    ],
    'trans_fat': ['trans fat', 'trans', 'الدهون المتحولة', 'متحولة'],
    'cholesterol': ['cholesterol', 'choles', 'كوليسترول'],
    'sodium': ['sodium', 'salt', 'الصوديوم', 'ملح', 'sel'],
    'carbohydrates': [
      'total carbohydrate',
      'carbohydrate',
      'carbs',
      'carb',
      'الكربوهيدرات',
      'كربوهيدرات',
      'glucides',
    ],
    'fiber': ['dietary fiber', 'fiber', 'fibre', 'الألياف', 'ألياف'],
    'sugar': ['total sugars', 'sugars', 'sugar', 'السكر', 'سكريات', 'sucre'],
    'added_sugar': ['added sugars', 'added sugar', 'سكر مضاف'],
    'protein': ['protein', 'pro', 'البروتين', 'بروتين', 'protéines'],
  };

  static final Map<String, _IngredientRisk> _harmfulIngredients = {
    'hydrogenated': _IngredientRisk('زيوت مهدرجة', 5),
    'partially hydrogenated': _IngredientRisk('زيوت مهدرجة جزئياً', 5),
    'aspartame': _IngredientRisk('أسبارتام (محلي صناعي)', 4),
    'high fructose': _IngredientRisk('شراب الذرة عالي الفركتوز', 5),
    'palm oil': _IngredientRisk('زيت النخيل', 3),
    'palm olein': _IngredientRisk('أولين النخيل', 3),
    'artificial flavor': _IngredientRisk('نكهات صناعية', 3),
    'artificial color': _IngredientRisk('ألوان صناعية', 3),
    'msg': _IngredientRisk('غلوتامات أحادية الصوديوم', 4),
    'nitrite': _IngredientRisk('نيتريت الصوديوم', 5),
    'benzoate': _IngredientRisk('بنزوات الصوديوم', 4),
    'tbhq': _IngredientRisk('TBHQ (مادة حافظة)', 4),
    'bha': _IngredientRisk('BHA (مادة حافظة)', 4),
    'bht': _IngredientRisk('BHT (مادة حافظة)', 4),
    'fructose syrup': _IngredientRisk('شراب الفركتوز', 4),
  };

  /// Main method to process raw OCR text
  static Map<String, dynamic> processRawText(String rawText) {
    debugPrint("=== START OCR PROCESSING ===");
    debugPrint("Raw Text Length: ${rawText.length}");

    final List<String> lines = rawText.toLowerCase().split('\n');
    final Map<String, List<_NutrientCandidate>> candidates = {};

    // --- STAGE 1: OCR Extraction & Candidate Collection ---
    debugPrint("--- Stage 1: Extraction ---");
    for (var entry in _keywords.entries) {
      String nutrientKey = entry.key;
      for (var keyword in entry.value) {
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (line.contains(keyword)) {
            // Check current line
            final val1 = _extractValueFromLine(line, keyword);
            if (val1 != null) {
              _addCandidate(
                candidates,
                nutrientKey,
                val1
                  ..lineIndex = i
                  ..sourceLine = line,
              );
            }

            // Check next line (Scanning below)
            if (i + 1 < lines.length) {
              final nextLine = lines[i + 1];
              // Less strict extraction for next line (don't require keyword)
              final val2 = _extractSimpleNumber(nextLine);
              if (val2 != null) {
                // Lower confidence for next-line matches unless they have units
                val2.confidence *= 0.8;
                _addCandidate(
                  candidates,
                  nutrientKey,
                  val2
                    ..lineIndex = i + 1
                    ..sourceLine = nextLine,
                );
              }
            }
          }
        }
      }
    }

    // --- STAGE 2: Normalization & Confidence Scoring ---
    debugPrint("--- Stage 2: Normalization & Scoring ---");
    final Map<String, _NutrientCandidate> bestMatches = {};
    final Map<String, double> finalNutritionMap =
        {}; // For backward compatibility

    candidates.forEach((key, list) {
      // Sort by confidence (descending)
      list.sort((a, b) => b.confidence.compareTo(a.confidence));

      // Pick best
      if (list.isNotEmpty) {
        var best = list.first;
        debugPrint(
          "Best candidate for $key: ${best.value} (conf: ${best.confidence})",
        );

        // Normalize Unit
        _normalizeUnit(key, best);

        bestMatches[key] = best;
        finalNutritionMap[key] = best.normalizedValue;
      }
    });

    // --- STAGE 3: Harmful Ingredient Detection ---
    debugPrint("--- Stage 3: Harmful Ingredients ---");
    final List<String> detectedHarmfulList =
        []; // Simple list for backward compatibility
    final List<Map<String, dynamic>> detectedHarmfulDetailed = [];

    final cleanText = rawText.toLowerCase();
    _harmfulIngredients.forEach((key, riskInfo) {
      if (cleanText.contains(key)) {
        debugPrint(
          "DETECTED HARMFUL: $key (${riskInfo.name}) - Level ${riskInfo.level}",
        );
        detectedHarmfulList.add(riskInfo.name);
        detectedHarmfulDetailed.add({
          'keyword': key,
          'name': riskInfo.name,
          'risk_level': riskInfo.level,
        });
      }
    });

    // --- STAGE 4: Validation & Alerts ---
    debugPrint("--- Stage 4: Validation ---");
    final List<String> alerts = [];

    // Sugar Check
    if (finalNutritionMap.containsKey('sugar') &&
        finalNutritionMap['sugar']! > 50) {
      alerts.add("⚠️ محتوى سكري مرتفع جداً (> 50 جم)");
    }
    // Sodium Check
    if (finalNutritionMap.containsKey('sodium') &&
        finalNutritionMap['sodium']! > 1000) {
      alerts.add("⚠️ محتوى صوديوم خطير (> 1000 ملجم)");
    }
    // Fiber Check
    if (finalNutritionMap.containsKey('fiber') &&
        finalNutritionMap['fiber']! < 1) {
      alerts.add("ℹ️ فقير جداً بالألياف");
    }

    debugPrint("=== END OCR PROCESSING ===");

    return {
      'nutrition': finalNutritionMap, // Simple map (compat)
      'detailed_nutrition': bestMatches.map(
        (k, v) => MapEntry(k, v.toMap()),
      ), // Structured
      'harmful_ingredients': detectedHarmfulList, // Simple list (compat)
      'harmful_ingredients_detailed': detectedHarmfulDetailed, // Structured
      'alerts': alerts,
    };
  }

  static void _addCandidate(
    Map<String, List<_NutrientCandidate>> map,
    String key,
    _NutrientCandidate candidate,
  ) {
    if (!map.containsKey(key)) map[key] = [];
    map[key]!.add(candidate);
  }

  static _NutrientCandidate? _extractValueFromLine(
    String line,
    String keyword,
  ) {
    // Remove keyword from search area to avoid matching numbers inside keyword (e.g. E123)
    int idx = line.indexOf(keyword);
    String searchArea = line;
    if (idx != -1) {
      searchArea = line.substring(idx + keyword.length);
    }

    // Regex: Matches number (float/int) followed optionally by unit.
    // Negative lookahead (?!\s*%) prevents matching percentages.
    final regex = RegExp(
      r'(\d+(?:\.\d+)?)\s*(g|mg|kcal|cal|kj|mcg|µg)?(?!\s*%)',
    );
    final match = regex.firstMatch(searchArea);

    if (match != null) {
      final rawVal = double.parse(match.group(1)!);
      final unit = match.group(2);

      double confidence = 0.5;
      if (unit != null) confidence += 0.4; // Has unit = strong confidence
      // If found immediately after keyword (short distance)
      if (match.start < 5) confidence += 0.1;

      return _NutrientCandidate(rawVal, unit, confidence);
    }
    return null;
  }

  static _NutrientCandidate? _extractSimpleNumber(String line) {
    final regex = RegExp(
      r'^(\d+(?:\.\d+)?)\s*(g|mg|kcal|cal|kj|mcg|µg)?(?!\s*%)',
    );
    final match = regex.firstMatch(line.trim());
    if (match != null) {
      final rawVal = double.parse(match.group(1)!);
      final unit = match.group(2);
      double confidence = 0.3; // Base confidence for next-line match
      if (unit != null) confidence += 0.4;

      return _NutrientCandidate(rawVal, unit, confidence);
    }
    return null;
  }

  static void _normalizeUnit(String key, _NutrientCandidate match) {
    match.normalizedValue = match.value;

    // --- Energy ---
    if (key == 'calories') {
      // kJ to kcal conversion
      if (match.unit == 'kj' || (match.sourceLine!.contains('kj'))) {
        debugPrint("Converting ${match.value} kJ to kcal");
        match.normalizedValue = match.value * 0.239;
        match.unit = 'kcal';
      }
    }

    // --- Sodium ---
    if (key == 'sodium') {
      // If explicit grams
      if (match.unit == 'g') {
        debugPrint("Converting ${match.value} g Salt/Sodium to mg");
        match.normalizedValue = match.value * 1000;
        match.unit = 'mg';
      }
      // Heuristic: If small value (< 10) and no unit, usually means Salt in grams
      else if (match.unit == null && match.value < 10) {
        debugPrint(
          "Inferred Salt (g) from ${match.value} -> converting to Sodium (mg)",
        );
        // 1g Salt ≈ 393mg Sodium (User suggests 387, we'll use ~400 standard or 387)
        match.normalizedValue = match.value * 387;
        match.unit = 'mg';
        match.confidence *= 0.8; // Reduce confidence slightly for inference
      }
    }
  }
}

// --- Helper Data Classes ---

class _NutrientCandidate {
  final double value;
  String? unit;
  double confidence;

  // For context
  int lineIndex = -1;
  String? sourceLine;

  // Output
  double normalizedValue = 0.0;

  _NutrientCandidate(this.value, this.unit, this.confidence) {
    normalizedValue = value;
  }

  Map<String, dynamic> toMap() => {
    'value': value,
    'unit': unit,
    'normalized_value': normalizedValue,
    'confidence': confidence,
    'source_line': sourceLine,
  };
}

class _IngredientRisk {
  final String name;
  final int level; // 1 (Low) to 5 (High)
  const _IngredientRisk(this.name, this.level);
}
