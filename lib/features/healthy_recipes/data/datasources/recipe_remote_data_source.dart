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
        id: '6',
        nameEn: 'Chicken Strips',
        nameAr: 'شرائح الدجاج',
        ingredientsEn: [
          'Chicken breast tenders',
          '1 egg',
          'Salt, Black pepper, Paprika',
          'Garlic powder, Onion powder',
          'Oat flour',
          '3 rice cakes (crushed)',
          '¼ teaspoon Vegeta seasoning',
          'Olive oil',
          'Sauce: 1 cup yogurt, 1 tbsp mustard, 1 tbsp honey',
        ],
        ingredientsAr: [
          'صدور فراخ تندر',
          'بيضة',
          'ملح، فلفل اسود، بابريكا',
          'توم بودر وبصل بودر',
          'دقيق شوفان',
          '3 رايس كيك (مطحون)',
          'ربع معلقة ڤيجيتار',
          'زيت زيتون',
          'الصوص: علبة زبادي، ملعقة مستردة، ملعقة عسل',
        ],
        stepsEn: [
          'Season chicken tenders with spices.',
          'Coat with oat flour, then egg, then crushed rice cakes and vegeta.',
          'Spray with olive oil and cook in air fryer or oven until golden.',
          'Mix yogurt, mustard, and honey for the dipping sauce.',
        ],
        stepsAr: [
          'تبلي صدور الدجاج بالتوابل المذكورة.',
          'غطي الدجاج بدقيق الشوفان، ثم البيض، ثم الرايس كيك المطحون.',
          'رشيها بزيت الزيتون واطهيها في القلاية الهوائية أو الفرن حتى تصبح ذهبية.',
          'اخلطي الزبادي والمستردة والعسل لعمل الصوص.',
        ],
        videoUrl: 'https://www.instagram.com/p/DPsVgz5DX0X/',
        imageUrl: 'assets/img/meals/Chicken_Strips.webp',
      ),
      const RecipeModel(
        id: '7',
        nameEn: 'Cold and Flu Drink',
        nameAr: 'مشروب البرد والإنفلونزا',
        ingredientsEn: [
          'Cloves',
          'Anise seeds',
          'Fresh ginger',
          'Turmeric & Black pepper',
          'Cinnamon',
          'Milk',
          '1 tbsp honey',
        ],
        ingredientsAr: [
          'قرنفل',
          'حبوب يانسون',
          'جنزبيل فريش',
          'كركم وفلفل اسود',
          'قرفة',
          'لبن',
          'ملعقة عسل للتحلية',
        ],
        stepsEn: [
          'Boil all spices with milk in a small pot.',
          'Strain the drink into a cup.',
          'Sweeten with honey while warm.',
        ],
        stepsAr: [
          'اغلي جميع التوابل مع اللبن في وعاء صغير.',
          'صفي المشروب في الكوب.',
          'حليه بالعسل وهو دافئ.',
        ],
        videoUrl: 'https://www.instagram.com/hassankauod/reel/DPbmaF2DYH-/',
        imageUrl: 'assets/img/meals/Cold_and_flu_drinks.webp',
      ),
      const RecipeModel(
        id: '8',
        nameEn: 'Sweet Potato Pancakes',
        nameAr: 'فطائر البطاطا الحلوة',
        ingredientsEn: [
          '4 sweet potatoes (mashed)',
          '2 eggs',
          'Vanilla & Cinnamon',
          '1 tbsp Stevia (optional)',
          'Nuts & Honey syrup (optional)',
        ],
        ingredientsAr: [
          '٤ بطاطات (مهروسة)',
          '٢ بيض',
          'فانيليا وقرفة',
          'ملعقة سكر ستيڤيا اختياري',
          'مكسرات وسيروم عسل اختياري',
        ],
        stepsEn: [
          'Mix mashed sweet potatoes with eggs, vanilla, and cinnamon.',
          'Add stevia if desired.',
          'Cook small portions on a non-stick pan until set on both sides.',
          'Top with nuts and honey syrup.',
        ],
        stepsAr: [
          'اخلطي البطاطا المهروسة مع البيض والفانيليا والقرفة.',
          'أضيفي الستيفيا حسب الرغبة.',
          'اطهيها كأقراص صغيرة في مقلاة غير لاصقة حتى تتماسك من الجانبين.',
          'زينيها بالمكسرات وعسل السيروم.',
        ],
        videoUrl: 'https://www.instagram.com/hassankauod/reel/DPJk2_KjcXW/',
        imageUrl: 'assets/img/meals/Sweet_potato_pancakes.webp',
      ),
      const RecipeModel(
        id: '9',
        nameEn: 'Immunity Drink',
        nameAr: 'مشروب المناعة',
        ingredientsEn: [
          'Fresh ginger (1-inch piece)',
          '2 tbsp extra virgin olive oil',
          '1 tbsp honey',
          '4 large cups water',
        ],
        ingredientsAr: [
          'جنزبيل فريش',
          'ملعقتين زيت زيتون بكر',
          'معلقة عسل',
          '٤ كوب ماية كبار',
        ],
        stepsEn: [
          'Peel and slice or grate the ginger.',
          'Add ginger to water and bring to a boil.',
          'Let it cool slightly, then stir in olive oil and honey.',
          'Drink warm throughout the day.',
        ],
        stepsAr: [
          'قشري الجنزبيل وقطعيه أو ابشريه.',
          'أضيفي الجنزبيل للماء واغليه.',
          'اتريه يهدأ قليلاً، ثم أضيفي زيت الزيتون والعسل.',
          'اشربيه دافئاً على مدار اليوم.',
        ],
        videoUrl: 'https://www.instagram.com/hassankauod/reel/DN3IkrMNPdx/',
        imageUrl: 'assets/img/meals/Immunity_drink.webp',
      ),
      const RecipeModel(
        id: '10',
        nameEn: 'Healthy Halawa',
        nameAr: 'حلاوة صحية',
        ingredientsEn: [
          '¾ cup roasted sesame seeds',
          '⅓ cup tahini',
          '⅓ cup honey',
        ],
        ingredientsAr: [
          'كوب الا ربع سمسم محمص',
          'تلت كوب طحينة',
          'تلت كوب عسل نحل',
        ],
        stepsEn: [
          'Grind the roasted sesame seeds into a fine powder.',
          'Mix with tahini and honey until a firm dough forms.',
          'Press into a mold and refrigerate for a few hours before serving.',
        ],
        stepsAr: [
          'اطحني السمسم المحمص جيداً حتى يصبح بودرة.',
          'اخلطيه مع الطحينة والعسل حتى تتشكل عجينة متماسكة.',
          'اضغطيها في قالب وضعيها في الثلاجة لبضع ساعات قبل التقديم.',
        ],
        videoUrl: 'https://www.instagram.com/hassankauod/reel/DNdbfFNtdIk/',
        imageUrl: 'assets/img/meals/Healthy_Halawa.webp',
      ),
      const RecipeModel(
        id: '11',
        nameEn: 'Pistachio Date Dessert',
        nameAr: 'حلى التمر والفستق',
        ingredientsEn: [
          '½ cup oats',
          'Dash of cinnamon',
          '12 pitted dates',
          '½ cup pistachios',
          '80g dark chocolate (with Stevia)',
          'Drop of olive oil',
        ],
        ingredientsAr: [
          'نص كوب شوفان',
          'رشة قرفة',
          '١٢ تمرة',
          'نص كوب فستق حلبي',
          '٨٠ جرام دارك تشوكليت بسكر ستيڤيا',
          'نقطة زيت زيتون',
        ],
        stepsEn: [
          'Blend dates, oats, and cinnamon until smooth.',
          'Mix in crushed pistachios.',
          'Spread on parchment paper with a drop of olive oil.',
          'Melt dark chocolate and pour over the mixture.',
          'Freeze until set, then cut into bars.',
        ],
        stepsAr: [
          'اخلطي التمر والشوفان والقرفة في الخلاط.',
          'أضيفي الفستق الحلبي المجروش.',
          'افردي الخليط على ورق زبدة مدهون بنقطة زيت.',
          'سيحي الشوكولاتة الداكنة وصبيها فوق الخليط.',
          'ضعيها في الفريزر حتى تتماسك ثم قطعيها.',
        ],
        videoUrl: 'https://www.instagram.com/hassankauod/reel/DM26X3KN9ww/',
        imageUrl: 'assets/img/meals/pistachio_dessert.webp',
      ),
      const RecipeModel(
        id: '12',
        nameEn: 'Sweet Potato Crème Brûlée',
        nameAr: 'كريم بروليه البطاطا',
        ingredientsEn: [
          '500g sweet potatoes (cooked/mashed)',
          '3 egg yolks',
          '1 cup milk',
          'Vanilla extract',
          '2 tbsp Stevia sugar',
        ],
        ingredientsAr: [
          'نص كيلو بطاطا (مسلوقة ومهروسة)',
          'صفار ٣ بيضات',
          'كوب لبن',
          'فانيليا',
          '٢ ملعقة سكر ستيڤيا',
        ],
        stepsEn: [
          'Whisk egg yolks with stevia and vanilla.',
          'Mix in mashed sweet potatoes and milk until very smooth.',
          'Pour into ramekins and bake in a water bath until set.',
          'Caramelize a little stevia on top if desired.',
        ],
        stepsAr: [
          'اخفقي صفار البيض مع الستيفيا والفانيليا.',
          'أضيفي البطاطا المهروسة واللبن وقلبي حتى ينعم الخليط تماماً.',
          'صبي الخليط في قوالب واخبزيها في حمام مائي بالفرن.',
          'يمكنك كراميلة القليل من الستيفيا على الوجه.',
        ],
        videoUrl: 'https://www.instagram.com/hassankauod/reel/DIZEbjcNv9P/',
        imageUrl: 'assets/img/meals/Crème_Brûlée.webp',
      ),
      const RecipeModel(
        id: '13',
        nameEn: 'Tahini Chocolate Dates',
        nameAr: 'تمر بالطحينة والشوكولاتة',
        ingredientsEn: [
          'Dates (pitted)',
          '1 tbsp tahini',
          '1 tbsp shredded coconut',
          'Dark chocolate',
          'Pinch of salt',
        ],
        ingredientsAr: [
          'تمر (منزوع النوى)',
          'معلقة طحينة',
          'معلقة جوز هند',
          'دارك تشوكليت',
          'شوية ملح',
        ],
        stepsEn: [
          'Stuff dates with a mix of tahini and coconut.',
          'Dip dates into melted dark chocolate.',
          'Sprinkle a tiny bit of salt on top.',
          'Refrigerate until the chocolate is firm.',
        ],
        stepsAr: [
          'احشي التمر بخليط الطحينة وجوز الهند.',
          'اغمسي التمر في الشوكولاتة الداكنة المذابة.',
          'رشي القليل من الملح على الوجه.',
          'ضعيها في الثلاجة حتى تتماسك الشوكولاتة.',
        ],
        videoUrl: 'https://www.instagram.com/hassankauod/reel/DIHDeVJowTZ/',
        imageUrl: 'assets/img/meals/Date_Desert.webp',
      ),
      const RecipeModel(
        id: '14',
        nameEn: 'Healthy Sohour Wrap',
        nameAr: 'سحور صحي',
        ingredientsEn: [
          '2 eggs',
          '1 large Greek yogurt',
          '2 tbsp almond or oat flour',
          '1 tsp baking powder',
          'Salt, pepper, olive oil',
          'Bell peppers, olives, mozzarella',
          'Za\'atar',
        ],
        ingredientsAr: [
          '٢ بيضة',
          'علبة زبادي يوناني كبيرة',
          '٢ معلقة دقيق لوز او شوفان',
          'معلقة صغيرة بيكينج بودر',
          'ملح، فلفل، زيت زيتون',
          'فلفل، زيتون، جبنة موتزاريلا',
          'رشة زعتر',
        ],
        stepsEn: [
          'Whisk eggs, yogurt, flour, and baking powder.',
          'Pour into a pan with olive oil.',
          'Top with peppers, olives, and cheese.',
          'Fold like a wrap or omelette and sprinkle with za\'atar.',
        ],
        stepsAr: [
          'اخفقي البيض والزبادي والدقيق والبيكنج بودر.',
          'صبي الخليط في مقلاة مدهونة بزيت الزيتون.',
          'أضيفي الفلفل والزيتون والجبنة على الوجه.',
          'اطويها وقدميها مع رشة زعتر.',
        ],
        videoUrl: 'https://www.instagram.com/hassankauod/reel/DHigPVKNuVC/',
        imageUrl: 'assets/img/meals/Healthy_Sohour.webp',
      ),
      const RecipeModel(
        id: '15',
        nameEn: 'Diet Basbousa',
        nameAr: 'بسبوسة صحية',
        ingredientsEn: [
          '1 egg',
          'Greek yogurt',
          '1 tsp baking powder',
          'Stevia sugar',
          '5 tbsp shredded coconut',
          '5g oil',
          'Almonds for topping',
          'Syrup (Stevia + water + lemon)',
        ],
        ingredientsAr: [
          'بيضة',
          'علبة زبادي يوناني',
          'معلقة بيكينج بودر',
          'سكر استيفيا',
          '٥ مع كبار جوز هند',
          '٥ جرام زيت',
          'لوز للتزيين',
          'شربات (ستيفيا وماء وليمون)',
        ],
        stepsEn: [
          'Mix all ingredients together.',
          'Pour into a small baking dish.',
          'Top with almonds and bake until golden.',
          'Pour cold stevia syrup over the hot basbousa.',
        ],
        stepsAr: [
          'اخلطي جميع المكونات معاً.',
          'صبي الخليط في صينية صغيرة.',
          'زينيها باللوز واخبزيها في الفرن حتى يحمر الوجه.',
          'صبي الشربات البارد فوق البسبوسة الساخنة.',
        ],
        videoUrl: 'https://www.instagram.com/hassankauod/reel/DG-gj7WNLHG/',
        imageUrl: 'assets/img/meals/Diet_Basbousa.webp',
      ),
      const RecipeModel(
        id: '16',
        nameEn: 'Cottage Cheese Protein Bar',
        nameAr: 'بروتين بار الجبنة القريش',
        ingredientsEn: [
          '250g cottage cheese',
          '1 tbsp raw cocoa',
          '1 tbsp healthy nut spread',
          'Stevia sugar',
          'Melted dark chocolate',
        ],
        ingredientsAr: [
          '٢٥٠ جرام جبنة قريش',
          'معلقة كاكاو خام',
          'معلقة هيلثي سبريد',
          'سكر ستيڤيا',
          'دارك تشوكليت مذابة',
        ],
        stepsEn: [
          'Blend cottage cheese, cocoa, stevia, and healthy spread until creamy.',
          'Shape into bars or press into a small pan.',
          'Coat with melted dark chocolate.',
          'Freeze for 1-2 hours.',
        ],
        stepsAr: [
          'اضربي الجبنة والقريش والكاكاو والستيفيا والسبريد في الكبة حتى تنعم.',
          'شكليها كأصابع أو افرديها في قالب.',
          'غطيها بالشوكولاتة الداكنة المذابة.',
          'ضعيها في الفريزر لمدة ساعة أو ساعتين.',
        ],
        videoUrl: 'https://www.instagram.com/hassankauod/reel/DFskUeftxVn/',
        imageUrl: 'assets/img/meals/Protein_Bar.webp',
      ),
      const RecipeModel(
        id: '17',
        nameEn: 'Chocolate Oat Pancakes',
        nameAr: 'بان كيك الشوفان بالشوكولاتة',
        ingredientsEn: [
          '40g oats',
          '3 eggs',
          '1 tbsp raw cocoa',
          '1 tsp baking powder',
          'Stevia sugar',
          'Olive oil',
          'Banana & Honey (topping)',
        ],
        ingredientsAr: [
          '٤٠ جرام شوفان',
          '٣ بيض',
          'معلقة كاكاو خام',
          'معلقة بيكينج بودر',
          'سكر استيفيا',
          'نقطة زيت زيتون',
          'موز وعسل للوجه',
        ],
        stepsEn: [
          'Blend oats, eggs, cocoa, baking powder, and stevia.',
          'Cook small circles on a pan with a drop of olive oil.',
          'Serve with banana slices and a drizzle of honey.',
        ],
        stepsAr: [
          'اخلطي الشوفان والبيض والكاكاو والبيكنج بودر والستيفيا في الخلاط.',
          'اطهيها كدوائر صغيرة في مقلاة مدهونة بنقطة زيت.',
          'قدميها مع قطع الموز ورشة عسل.',
        ],
        videoUrl: 'https://www.instagram.com/hassankauod/reel/DFajjPsNQ2n/',
        imageUrl: 'assets/img/meals/Oat_Pancakes.webp',
      ),
      const RecipeModel(
        id: '18',
        nameEn: 'Healthy Taameya',
        nameAr: 'طعمية صحية',
        ingredientsEn: [
          '5 tbsp Ta\'ameya paste',
          '1 egg',
          '½ tsp tahini',
          'Sesame seeds',
          'Fresh parsley',
          'Olive oil',
        ],
        ingredientsAr: [
          '٥ معالق عجينة طعمية',
          'بيضة',
          'نص معلقة طحينة',
          'سمسم',
          'رشة بقدونس',
          'رشة زيت زيتون',
        ],
        stepsEn: [
          'Mix Ta\'ameya paste with egg, tahini, and parsley.',
          'Form into patties and sprinkle with sesame seeds.',
          'Air fry or pan fry with a little olive oil until crispy.',
          'Serve with healthy whole grain bread.',
        ],
        stepsAr: [
          'اخلطي عجينة الطعمية مع البيضة والطحينة والبقدونس.',
          'شكليها كأقراص ورشي عليها السمسم.',
          'اطهيها في القلاية الهوائية أو في المقلاة مع القليل من زيت الزيتون.',
          'قدميها مع خبز الحبوب الكاملة.',
        ],
        videoUrl: 'https://www.instagram.com/hassankauod/reel/DGtVVF9tHam/',
        imageUrl: 'assets/img/meals/Healthy_Taameya.webp',
      ),
    ];
  }
}
