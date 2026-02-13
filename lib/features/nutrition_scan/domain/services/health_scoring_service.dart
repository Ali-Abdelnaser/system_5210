class HealthScoringService {
  /// Calculates a health score (0-100) based on nutritional values per 100g.
  static Map<String, dynamic> calculateScore(Map<String, dynamic> data) {
    final Map<String, double> nutrition = Map<String, double>.from(
      data['nutrition'] ?? {},
    );
    final List<String> harmfulIngredients = List<String>.from(
      data['harmful_ingredients'] ?? [],
    );

    double score = 75.0;
    List<String> insights = [];
    List<Map<String, dynamic>> breakdown = [];

    // Extract values with defaults
    double calories = nutrition['calories'] ?? 0;
    double sugar = nutrition['sugar'] ?? 0;
    double satFat = nutrition['saturated_fat'] ?? 0;
    double sodium = nutrition['sodium'] ?? 0;
    double fiber = nutrition['fiber'] ?? 0;
    double protein = nutrition['protein'] ?? 0;

    // 1️⃣ NUTRITIONAL PENALTIES
    if (sugar > 5) {
      double penalty = (sugar - 5) * 1.0;
      score -= penalty;
      breakdown.add({'label': 'سكر مضاف', 'score': -penalty.toInt()});
      if (sugar > 15) insights.add("❌ محتوى سكري مرتفع جداً (تجاوز 15 جم).");
    }

    if (satFat > 2) {
      double penalty = (satFat - 2) * 1.5;
      score -= penalty;
      breakdown.add({'label': 'دهون مشبعة', 'score': -penalty.toInt()});
    }

    if (sodium > 200) {
      double penalty = (sodium - 200) / 45.0;
      score -= penalty;
      breakdown.add({'label': 'صوديوم مرتفع', 'score': -penalty.toInt()});
    }

    // 2️⃣ INGREDIENT ANALYSIS (Modern & Deep)
    if (harmfulIngredients.isNotEmpty) {
      double ingPenalty = harmfulIngredients.length * 8.0;
      score -= ingPenalty;
      insights.add("⚠️ تم رصد مكونات ضارة: ${harmfulIngredients.join('، ')}.");
      breakdown.add({'label': 'إضافات غير صحية', 'score': -ingPenalty.toInt()});
    }

    // 3️⃣ PROCESSED PATTERN
    if (calories > 350 && sodium > 400 && fiber < 2) {
      score -= 10;
      breakdown.add({'label': 'نمط غذاء مُصنّع', 'score': -10});
    }

    // 4️⃣ BONUSES
    if (fiber > 3 && score > 40) {
      score += 5;
      breakdown.add({'label': 'ألياف غذائية', 'score': 5});
      insights.add("✅ غني بالألياف: يدعم صحة الجهاز الهضمي.");
    }
    if (protein > 10 && score > 40) {
      score += 5;
      breakdown.add({'label': 'بروتين عالي', 'score': 5});
      insights.add("✅ محتوى بروتين جيد يدعم الجسم.");
    }

    // Hard Caps
    if ((sugar > 25 || harmfulIngredients.length >= 3) && score > 50) {
      score = 50;
    }

    // Confidence Calculation
    String confidence = "عالية";
    if (nutrition.length < 4) {
      confidence = "متوسطة";
      insights.add(
        "💡 نصيحة: بعض البيانات مفقودة، للحصول على أدق نتيجة تأكد من وضوح الجدول.",
      );
    }

    score = score.clamp(5.0, 90.0);

    return {
      'score': score.round(),
      'confidence': confidence,
      'explanation': insights.isEmpty
          ? "المنتج متوازن غذائياً."
          : insights.join("\n"),
      'breakdown': breakdown,
      'detected_ingredients': harmfulIngredients,
    };
  }
}
