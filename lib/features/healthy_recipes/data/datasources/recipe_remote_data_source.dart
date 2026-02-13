import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recipe_model.dart';

abstract class RecipeRemoteDataSource {
  Future<List<RecipeModel>> getRecipes();
}

class RecipeRemoteDataSourceImpl implements RecipeRemoteDataSource {
  final FirebaseFirestore firestore;

  RecipeRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<RecipeModel>> getRecipes() async {
    try {
      final snapshot = await firestore.collection('healthy_recipes').get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => RecipeModel.fromFirestore(doc.data(), doc.id))
            .toList();
      } else {
        // Return dummy data if Firebase is empty as requested
        return _getDummyRecipes();
      }
    } catch (e) {
      // Return dummy data in case of error (e.g., collection doesn't exist yet)
      return _getDummyRecipes();
    }
  }

  List<RecipeModel> _getDummyRecipes() {
    return [
      const RecipeModel(
        id: '1',
        nameEn: 'Healthy Nutella',
        nameAr: 'نوتيلا صحية',
        ingredientsEn: [
          'Any soft dates',
          '2 tbsp coconut butter or ghee or butter',
          '1 tbsp raw sesame flour (Tahini)',
          '2 tbsp raw cocoa',
          'Stevia for sweetening (optional)',
        ],
        ingredientsAr: [
          'أي نوع تمر يكون طري',
          'ملعقتين من زبدة جوز الهند أو سمن بلدي أو زبدة',
          'ملعقه كبيره من طحين السمسم الخام',
          'ملعقتين كبار من الكاكاو الخام',
          'للتحلية ممكن نضيف سكر استيڤيا',
        ],
        stepsEn: ['Mix all components in the food processor'],
        stepsAr: ['يتم خلط جميع المكونات في الكبة'],
        videoUrl: 'https://www.instagram.com/hassankauod/reel/DOlhrjLDSNR/',
        imageUrl:
            'https://images.unsplash.com/photo-1523294587484-cccb444e8ec7?q=80&w=1000&auto=format&fit=crop',
      ),
      const RecipeModel(
        id: '2',
        nameEn: 'Oatmeal Pancakes',
        nameAr: 'بانكيك الشوفان',
        ingredientsEn: [
          '1 cup oats',
          '1 banana',
          '1 egg',
          '1/2 cup almond milk',
        ],
        ingredientsAr: ['كوب شوفان', 'حبة موز', 'بيضة', 'نصف كوب حليب لوز'],
        stepsEn: ['Blend all ingredients', 'Cook on a non-stick pan'],
        stepsAr: ['اخلط جميع المكونات', 'اطبخها في مقلاة غير لاصقة'],
        videoUrl: '',
        imageUrl:
            'https://images.unsplash.com/photo-1567620905732-2d1ec7bb7445?q=80&w=1000&auto=format&fit=crop',
      ),
      const RecipeModel(
        id: '3',
        nameEn: 'Greek Salad',
        nameAr: 'سلطة يونانية',
        ingredientsEn: [
          'Cucumber',
          'Tomato',
          'Feta cheese',
          'Olives',
          'Olive oil',
        ],
        ingredientsAr: ['خيار', 'طماطم', 'جبنة فيتا', 'زيتون', 'زيت زيتون'],
        stepsEn: ['Chop vegetables', 'Mix with cheese and oil'],
        stepsAr: ['قطع الخضار', 'اخلها مع الجبنة والزيت'],
        videoUrl: '',
        imageUrl:
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=1000&auto=format&fit=crop',
      ),
      const RecipeModel(
        id: '4',
        nameEn: 'Chicken Stir Fry',
        nameAr: 'دجاج مع الخضار',
        ingredientsEn: ['Chicken breast', 'Broccoli', 'Carrots', 'Soy sauce'],
        ingredientsAr: ['صدر دجاج', 'بروكلي', 'جزر', 'صوص صويا'],
        stepsEn: ['Sauté chicken', 'Add vegetables', 'Add sauce'],
        stepsAr: ['شوح الدجاج', 'أضف الخضار', 'أضف الصوص'],
        videoUrl: '',
        imageUrl:
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=1000&auto=format&fit=crop',
      ),
      const RecipeModel(
        id: '5',
        nameEn: 'Smoothie Bowl',
        nameAr: 'سموذي بول',
        ingredientsEn: ['Frozen berries', 'Yogurt', 'Honey', 'Granola'],
        ingredientsAr: ['توت مجمد', 'زبادي', 'عسل', 'جرانولا'],
        stepsEn: ['Blend berries and yogurt', 'Top with granola'],
        stepsAr: ['اخلط التوت والزبادي', 'ضع الجرانولا في الأعلى'],
        videoUrl: '',
        imageUrl:
            'https://images.unsplash.com/photo-1490474418585-ba9bad8fd0ea?q=80&w=1000&auto=format&fit=crop',
      ),
    ];
  }
}
