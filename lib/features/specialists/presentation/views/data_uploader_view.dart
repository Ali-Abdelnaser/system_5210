import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/features/specialists/data/models/doctor_model.dart';
import 'package:system_5210/features/healthy_recipes/data/models/recipe_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:system_5210/core/widgets/app_loading_indicator.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/core/utils/image_compressor.dart';
import 'dart:typed_data';

class DataUploaderView extends StatefulWidget {
  const DataUploaderView({super.key});

  @override
  State<DataUploaderView> createState() => _DataUploaderViewState();
}

class _DataUploaderViewState extends State<DataUploaderView> {
  bool _isUploading = false;
  String _status = 'Ready to upload premium Doctors and Healthy Recipes.';

  final List<DoctorModel> premiumDoctors = [
    const DoctorModel(
      id: '',
      nameEn: 'Michael Maged',
      nameAr: 'مايكل ماجد',
      specialtyEn: 'Clinical nutritionist',
      specialtyAr: 'أخصائي تغذية علاجية',
      aboutEn:
          'A Clinical Nutrition Specialist dedicated to providing integrated, science-based nutritional solutions to help individuals achieve a healthy and balanced lifestyle.',
      aboutAr:
          'أخصائي تغذية علاجية، يعمل على تقديم حلول غذائية متكاملة مبنية على أسس علمية، لمساعدة الأفراد على الوصول إلى نمط حياة صحي ومتوازن.',
      imageUrl: 'assets/img/Doctor/Michael_Maged.jpg', // سنقوم برفعه برمجياً
      clinicLocation: 'هليوبوليس – مصر الجديدة',
      allowsOnlineConsultation: true,
      contactNumber: '01200081469',
      whatsappNumber: '01200081469',
      experienceYears: 3,
      workingDaysEn: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday'],
      workingDaysAr: ['من الأحد', 'إلى الخميس'],
      workingHoursEn: '06:00 PM - 10:00 PM',
      workingHoursAr: '06:00 م - 10:00 م',
      certificates: [],
    ),
    const DoctorModel(
      id: '',
      nameEn: 'Prof. Dr. Ahmed Abdelhalim El-Fahl',
      nameAr: 'أ.د / أحمد عبدالحليم الفحل',
      specialtyEn: 'Consultant of Clinical Nutrition',
      specialtyAr: 'استشاري التغذية العلاجية',
      aboutEn:
          'Specialized in: • Obesity & Underweight Treatment • Clinical Therapeutic Nutrition',
      aboutAr:
          'متخصص في: • علاج السمنة والنحافة • التغذية العلاجية الإكلينيكية وأستاذ بجامعة بدر.',
      imageUrl: 'assets/img/Doctor/Ahmed_Abdelhalim.jpg',
      clinicLocation: 'Shebin El-Qanater – Madinaty – New Cairo',
      allowsOnlineConsultation: false,
      contactNumber: '01013225039',
      whatsappNumber: '01001891218',
      experienceYears: 20,
      workingDaysEn: [],
      workingDaysAr: [],
      workingHoursEn: '.',
      workingHoursAr: '.',
      certificates: [],
    ),
    const DoctorModel(
      id: '',
      nameEn: 'Dr. Mohamed Ragab',
      nameAr: 'د. محمد رجب',
      specialtyEn: 'Pediatrician Specialist',
      specialtyAr: 'أخصائي طب الأطفال',
      aboutEn:
          'Pediatrician & Neonatology Specialist Master’s Degree in Pediatrics.',
      aboutAr:
          'يقدم د. محمد رجب رعاية طبية متكاملة للأطفال وحديثي الولادة، مع متابعة دقيقة للنمو والتطور، وتشخيص وعلاج أمراض الأطفال المختلفة.',
      imageUrl: 'assets/img/Doctor/Mohamed_Ragab.jpg',
      clinicLocation: 'مستشفى النزهة الدولي - مول الحرية العبور',
      allowsOnlineConsultation: false,
      contactNumber: '01027852960',
      whatsappNumber: '01027852960',
      experienceYears: 10,
      workingDaysEn: ['Daily'],
      workingDaysAr: ['يومياً'],
      workingHoursEn: 'Call for appointment',
      workingHoursAr: 'اتصل للحجز',
      certificates: [],
    ),
    const DoctorModel(
      id: '',
      nameEn: 'Dr. YOUSSEF SAAD',
      nameAr: 'د. يوسف سعد',
      specialtyEn: 'Pediatric consultant',
      specialtyAr: 'استشارى أطفال',
      aboutEn: 'Pediatrician for more than 30 years.',
      aboutAr: 'طبيب أطفال منذ أكثر من ٣٠ عاماً.',
      imageUrl: 'assets/img/Doctor/Youssef_Saad.jpg',
      clinicLocation: 'مركز الكمال الطبي',
      allowsOnlineConsultation: true,
      contactNumber: '01211544550',
      whatsappNumber: '01223102149',
      experienceYears: 40,
      workingDaysEn: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
      workingDaysAr: ['كل الأيام ماعدا الأحد'],
      workingHoursEn: 'Morning & Evening',
      workingHoursAr: 'صباحاً ومساءً',
      certificates: [],
    ),
  ];

  final List<RecipeModel> premiumRecipes = [
    const RecipeModel(
      id: '',
      nameEn: 'Chicken veggie meal',
      nameAr: 'وجبة الفراخ بالخضار',
      ingredientsEn: [
        '250g chicken breast',
        '300g potatoes',
        '200g onions',
        '200g tomatoes',
        '1 tbsp olive oil',
        'Seasoning: Himalayan salt, black pepper, garlic powder, paprika, onion powder, lemon juice',
      ],
      ingredientsAr: [
        '٢٥٠ جرام صدور فراخ',
        '٣٠٠ جرام بطاطس',
        '٢٠٠ جرام بصل',
        '٢٠٠ جرام طماطم',
        'ملعقة زيت زيتون',
        'ملح هيمالايا – فلفل أسود – بودرة ثوم – بابريكا – بودرة بصل – عصير ليمونة',
      ],
      stepsEn: [
        'Place chopped vegetables and chicken in a baking tray.',
        'Add olive oil and seasoning.',
        'Bake at 200°C until fully cooked.',
      ],
      stepsAr: [
        'نقطع الخضار ونضعهم في صينية مع الفراخ.',
        'نضيف زيت الزيتون والبهارات والليمون ونقلب جيدًا.',
        'ندخلها فرن على درجة حرارة ٢٠٠.',
      ],
      videoUrl:
          'https://www.instagram.com/reel/Cnue72_IULo/?igsh=ZGV0ejd2N2FqYmV4',
      imageUrl: 'assets/img/Meals/Chicken_veggie.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Healthy breakfast',
      nameAr: 'فطار صحي',
      ingredientsEn: ['100g meat', '5g ghee', 'Eggs', 'Salad'],
      ingredientsAr: ['١٠٠ جرام لحمه', '٥ جرام سمنه بلدي', 'بيض', 'طبق سلطه'],
      stepsEn: ['Calories: 398, Protein: 37g, Fat: 28g, Carbs: 18g'],
      stepsAr: [
        'السعرات : ٣٩٨',
        'البروتين :٣٧ جرام',
        'الدهون: ٢٨ جرام',
        'الكربوهيدرات: ١٨ جرام',
      ],
      videoUrl:
          'https://www.instagram.com/reel/C2sTM_iM1Ye/?igsh=ZmtvNm9vZjc4M25r',
      imageUrl: 'assets/img/Meals/Healthy_breakfast.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Shrimps',
      nameAr: 'جمبري',
      ingredientsEn: [
        '200g peeled shrimp',
        '150g red & yellow bell peppers',
        '35g dill',
        '3 garlic cloves',
        '5g olive oil',
        'Seasoning: salt – pepper – paprika – garlic & onion powder',
        '1 whole lemon',
      ],
      ingredientsAr: [
        '٢٠٠ جرام جمبري مخلي',
        '١٥٠ جرام فلفل ألوان أحمر وأصفر',
        '٣٥ جرام شبت',
        '٣ فصوص ثوم',
        '٥ جرام زيت زيتون',
        'بهارات: ملح – فلفل – بابريكا – توم وبصل بودر',
        'لمونة كاملة',
      ],
      stepsEn: [
        '7 minutes on each side',
        'Calories: 250, Protein: 30g, Carbs: 10g, Fat: 9g',
      ],
      stepsAr: [
        '٧ دقايق على كل جنب بس',
        'السعرات: ٢٥٠ سعر',
        'البروتين: ٣٠ جرام',
        'الكارب: ١٠, الدهون: ٩',
      ],
      videoUrl:
          'https://www.instagram.com/reel/C3iSiliMmlB/?igsh=dTJvZnZ0b2VobDE5',
      imageUrl: 'assets/img/Meals/Shrimps.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Peanut butter dessert',
      nameAr: 'حلى زبدة الفول السوداني',
      ingredientsEn: [
        'Banana',
        '1 tbsp peanut butter',
        '1 tbsp cocoa powder',
        '2 tbsp diet sugar',
      ],
      ingredientsAr: [
        'موزه',
        'ملعقه زبده فول سوداني',
        'ملعقه بودره كاكاو',
        'معلقتين سكر دايت',
      ],
      stepsEn: [
        'Mix ingredients together, place on baking paper',
        'Bake at 200°C for 12 minutes',
        'After removing from oven add Greek yogurt + strawberry pieces',
        'Calories: 380, Protein: 20g',
      ],
      stepsAr: [
        'قلب المكونات مع بعض ونجهز ورقه زبده ننزل عليها بالخليط',
        'فرن علي درجه حراره ٢٠٠ لمده ١٢ دقيقه',
        'اول ماتطلع من الفرن نضيف زبادي يوناني +قطع فراوله',
        'السعرات :٣٨٠, البروتين: ٢٠ جرام',
      ],
      videoUrl:
          'https://www.instagram.com/reel/C5GVB1wsER5/?igsh=MW1zeGw2MzB4a295dg==',
      imageUrl: 'assets/img/Meals/Peanut_butter_dessert.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Musakaa',
      nameAr: 'المسقعة',
      ingredientsEn: [
        'Potatoes',
        'Eggplant',
        'Minced meat',
        'Olive oil',
        'Sauce: Tomato sauce, half cup water, 1 garlic clove, Salt, Black pepper',
      ],
      ingredientsAr: [
        'بطاطس',
        'بتنجان',
        'لحمة مفرومة',
        'زيت زيتون',
        'الصلصة: صلصة طماطم، نصف كوب ماء، فص ثوم، ملح، فلفل أسود',
      ],
      stepsEn: [
        'Boil potatoes half boil and drain',
        'Grill eggplant with olive oil in air fryer or oven',
        'Prepare sauce by mixing tomato sauce, half cup water, garlic, salt and pepper',
        'In a baking tray layer potatoes, minced meat, half sauce, eggplant, remaining sauce',
        'Sprinkle pepper on top',
        'Bake at 250°C for 30 minutes',
      ],
      stepsAr: [
        'تتسلق البطاطس نصف سلقة فقط وتُصفّى',
        'يتشوى البتنجان بزيت الزيتون في الإير فراير أو في الفرن',
        'تُحضَّر الصلصة بخلط صلصة الطماطم ونصف كوب ماء والثوم والملح والفلفل الأسود',
        'في صينية فرن نضع طبقة بطاطس ثم طبقة لحمة مفرومة ثم نصف كمية الصلصة ثم طبقة البتنجان ثم باقي الصلصة',
        'نرش فلفل من فوق',
        'تدخل الفرن على حرارة 250 درجة لمدة نصف ساعة',
      ],
      videoUrl:
          'https://www.instagram.com/reel/C-iIjDzsrbF/?igsh=MTFndzcyN2RxM2QxeA==',
      imageUrl: 'assets/img/Meals/Musakaa.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Prophetic seasoning',
      nameAr: 'التلبينة',
      ingredientsEn: [
        'half cup barley flour',
        'one cup water',
        'milk',
        'cinnamon and dates for garnish',
      ],
      ingredientsAr: [
        'نصف كوب من دقيق الشعير',
        'كوب ماء',
        'لبن',
        'قرفة وتمر للتزيين',
      ],
      stepsEn: [
        'Put barley flour in a pot on heat.',
        'Add one cup water and stir well until dissolved without lumps.',
        'Lower heat and keep stirring until thick.',
        'Add milk and stir until desired consistency.',
        'Serve and garnish with cinnamon and dates.',
      ],
      stepsAr: [
        'نضع نصف كوب من دقيق الشعير في قدر على النار.',
        'نضيف كوب ماء ونقلب جيدًا حتى يذوب الدقيق بدون تكتلات.',
        'نهدئ النار ونستمر في التقليب حتى يثقل القوام ويتماسك الخليط.',
        'نضيف كمية مناسبة من اللبن ونقلب حتى نحصل على القوام المطلوب.',
        'يُصب في طبق التقديم، ويُزين بـ القرفة والتمر حسب الرغبة.',
      ],
      videoUrl:
          'https://www.instagram.com/reel/C_-2fx0szpy/?igsh=anRuN21iMWFxeGQ2',
      imageUrl: 'assets/img/Meals/Prophetic_seasoning.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Sweet potato pizza',
      nameAr: 'بيتزا البطاطا',
      ingredientsEn: [
        'Baked sweet potato',
        'Sauce',
        'Chicken breast',
        'Vegetables as desired',
        'Low fat cheese',
      ],
      ingredientsAr: [
        'بطاطس مشوية',
        'صلصة',
        'صدور فراخ',
        'خضار حسب الرغبة',
        'جبنة قليلة الدسم',
      ],
      stepsEn: [
        'Microwave 90 seconds',
        'Calories 200 per piece, Protein 20g, Carbs 15g, Fat 10g',
      ],
      stepsAr: [
        'مايكروويف ٩٠ ثانية',
        'السعرات ٢٠٠ كالوري للواحده, بروتين ٢٠ جرام, كارب ١٥ جرام, دهون ١٠ جرام',
      ],
      videoUrl:
          'https://www.instagram.com/reel/C7jj0eIMavU/?igsh=N3NseWx6cnBjdmF2',
      imageUrl: 'assets/img/Meals/Sweet_potato_pizza.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Sweet potato',
      nameAr: 'بطاطا',
      ingredientsEn: [
        'Baked sweet potato (Savory: butter, chickpeas, corn, mozzarella)',
        'Baked sweet potato (Sweet: peanut butter, banana, nuts)',
      ],
      ingredientsAr: [
        'بطاطا حادقة (زبدة، حمص، ذرة، موتزريلا)',
        'بطاطا حلوة (زبدة فول سوداني، موز، مكسرات)',
      ],
      stepsEn: [
        'Savory: Baked sweet potato cut in half, add 5g butter, chickpeas, corn, mozzarella, salt, pepper.',
        'Sweet: Baked sweet potato cut in half, add peanut butter, banana slices, nuts.',
      ],
      stepsAr: [
        'بطاطا حادقة: بطاطاية مشوية وافتحيها من النص، حطي حوالي 5 جرام زبدة، ضيفي حمص وذرة وجبنة موتزريلا.',
        'بطاطا حلوة: بطاطاية مشوية ومفتوحة من النص، حطي جوه شوية زبدة فول سوداني وضيفي شرائح موز ورشة مكسرات.',
      ],
      videoUrl:
          'https://www.instagram.com/reel/DBWZ2uSuTmD/?igsh=OXNyMG54bW1oZDNw',
      imageUrl: 'assets/img/Meals/Sweet_potato.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Choco rice',
      nameAr: 'رز بالشوكولاتة',
      ingredientsEn: [
        '2 tbsp boiled white rice',
        '1 tbsp healthy spread',
        'Sprinkle cocoa',
        'Coconut and nuts for topping',
      ],
      ingredientsAr: [
        'معلقتين كبار رز أبيض مسلوق',
        'معلقة من الـ Healthy spread',
        'رشة كاكاو',
        'جوز هند ومكسرات للتزيين',
      ],
      stepsEn: [
        'Blend rice, healthy spread, and cocoa in blender until smooth.',
        'Garnish with extra cocoa, coconut, and nuts.',
      ],
      stepsAr: [
        'خدي الرز وضيفي معلقة الـ Healthy spread ورشة كاكاو واضربيهم كويس في الخلاط.',
        'للتقديم: رشي كاكاو على الوش وضيفي جوز هند وأي نوع مكسرات.',
      ],
      videoUrl:
          'https://www.instagram.com/reel/DCem9NRN_Hm/?igsh=aTU1MGN3Y2tvbGk4',
      imageUrl: 'assets/img/Meals/Choco_rice.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Diet Okra',
      nameAr: 'بامية دايت',
      ingredientsEn: [
        'Olive oil spray',
        '200g lean beef cubes',
        'Grated onion',
        '2 cups water',
        'Okra',
        'Tomato juice',
        '2 garlic cloves',
        'Salt and spices',
        'Chili pepper (optional)',
      ],
      ingredientsAr: [
        'رشة زيت زيتون',
        '٢٠٠ جرام لحمة مكعبات قليلة الدسم',
        'بصلة مبشورة',
        '٢ كوب ماء',
        'بامية',
        'عصير طماطم',
        'فصين توم',
        'ملح وبهارات',
        'قرن فلفل (اختياري)',
      ],
      stepsEn: [
        'Sauté beef with olive oil spray, then add onion and stir.',
        'Add 2 cups water and cook beef.',
        'Sauté okra separately.',
        'Add tomato juice, garlic, salt, and spices to beef, then let simmer.',
        'Mix okra with beef, put in a baking dish, add chili pepper, and grill for 10 mins.',
        'Calories: < 600, Protein: ~ 45g',
      ],
      stepsAr: [
        'نشوح اللحمة مع رشة زيت، ثم ننزل بالبصلة.',
        'نضيف ٢ كوب ماء ونسيب اللحمة تستوي.',
        'نشوح البامية لوحدها شوية.',
        'نضيف عصير الطماطم والتوم والملح والبهارات على اللحمة ونسيبهم يتسبكوا.',
        'ننزل بالبامية على اللحمة، ونحط الخليط في طاجن ويدخل تحت الشواية ١٠ دقايق.',
      ],
      videoUrl:
          'https://www.instagram.com/reel/DDmtNZSNqFu/?igsh=MXVtZngwYnl0dWkxcA==',
      imageUrl: 'assets/img/Meals/Diet_Okra.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Date tart',
      nameAr: 'تارت تمر',
      ingredientsEn: [
        'Pitted dates',
        'Tahini',
        'Dark chocolate sweetened with stevia',
      ],
      ingredientsAr: [
        'تمر مخلي',
        'طحينة سمسم',
        'دارك شوكولاتة محلاة بسكر ستيفيا',
      ],
      stepsEn: [
        'Press dates together to form a firm layer.',
        'Add tahini on top.',
        'Freeze for 30 minutes.',
        'Spread melted dark chocolate on top.',
        'Freeze again until firm.',
      ],
      stepsAr: [
        'نرص التمر جنب بعض ونضغط عليهم لحد ما يبقوا كتلة واحدة متماسكة.',
        'نوزع فوقهم طبقة من طحينة السمسم.',
        'ندخلها الفريزر نص ساعة.',
        'نسيّح الدارك تشوكلت ونوزعها على الوش.',
        'نرجعها الفريزر مرة تانية لحد ما تتماسك تمامًا.',
      ],
      videoUrl:
          'https://www.instagram.com/reel/DDuZ4nrNyO2/?igsh=MWtpYjZxZmlmYzh2Mw==',
      imageUrl: 'assets/img/Meals/Date_tart.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Panne',
      nameAr: 'بانية',
      ingredientsEn: [
        'Chicken breasts',
        '2 bags of protein puffs',
        'Spices',
        'Oat flour',
        'Eggs',
      ],
      ingredientsAr: [
        'صدور دجاج',
        'كيسيين بروتين بافس',
        'بهارات',
        'دقيق الشوفان',
        'بيض',
      ],
      stepsEn: [
        'Grind protein puffs with spices in a food processor.',
        'Coat chicken in oat flour, then eggs, then the ground puffs.',
        'Bake in oven or air fryer at 200°C for 15 minutes.',
      ],
      stepsAr: [
        'نطحن البروتين بافس مع البهارات داخل الكبة.',
        'نستخدم دقيق الشوفان بدل الدقيق الابيض للفراخ.',
        'ننزل بصدور الدجاج في الشوفان ثم البيض ثم البروتين بافس.',
        'نحطهم في الفرن او الايرفراير لمدة ربع ساعة علي درجة حرارة ٢٠٠.',
      ],
      videoUrl:
          'https://www.instagram.com/reel/DAgUGWvM-Do/?igsh=MXNlNWNzbDBpazZ1ZA==',
      imageUrl: 'assets/img/Meals/Panne.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: '350 calorie breakfast',
      nameAr: 'فطار ٣٥٠ كالوري',
      ingredientsEn: [
        '150g grated potatoes',
        '100g grated carrots',
        '2 eggs',
        '50g bell pepper',
        '10g low fat mozzarella',
        'Salt & black pepper',
      ],
      ingredientsAr: [
        '١٥٠ جرام بطاطس مبشورة',
        '١٠٠ جرام جزر مبشور',
        '٢ بيضة',
        '٥٠ جرام فلفل رومي متقطع',
        '١٠ جرام جبنة موتزريلا قليلة الدسم',
        'ملح وفلفل أسود',
      ],
      stepsEn: [
        'Mix all ingredients together.',
        'Place in a baking tray with parchment paper.',
        'Bake at 180°C for 20-25 minutes.',
      ],
      stepsAr: [
        'نخلط كل المكونات مع بعض كويس.',
        'نحط الخليط في صينية أو قالب مبطن بورق زبدة.',
        'تدخل فرن مسخن على ١٨٠ درجة لمدة ٢٠–٢٥ دقيقة.',
      ],
      videoUrl:
          'https://www.instagram.com/reel/DEc4O4BNtwJ/?igsh=ZW0zNnVleWZ6bXV5',
      imageUrl: 'assets/img/Meals/350_calorie_breakfast.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Water retention drink',
      nameAr: 'مشروب صحي',
      ingredientsEn: ['Celery', 'Parsley', 'Arugula', 'Cucumber', 'Water'],
      ingredientsAr: ['كرفس', 'بقدونس', 'جرجير', 'خيار', 'مايه'],
      stepsEn: ['Put all ingredients in blender and blend well until smooth.'],
      stepsAr: [
        'نحط كل المكونات في الخلاط ونضرب كويس لحد ما الخليط يبقى ناعم.',
      ],
      videoUrl:
          'https://www.instagram.com/reel/DEkfyA9t--C/?igsh=MXB5azQ3Z3ZwZnVxcA==',
      imageUrl: 'assets/img/Meals/Water_retention_drink.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Minced meat pasta',
      nameAr: 'مكرونه باللحم المفروم',
      ingredientsEn: [
        'Lean minced meat',
        'Onion',
        'Salt, black pepper, garlic powder, onion powder, paprika',
        '1 tsp honey',
        'Oat pasta or regular pasta',
      ],
      ingredientsAr: [
        'لحمة مفرومة قليلة الدسم',
        'بصل',
        'ملح، فلفل اسود، بودره توم، بودره بصل، بابريكا',
        'ملعقه صغيره عسل',
        'مكرونة شوفان أو عادية',
      ],
      stepsEn: [
        'Sauté minced meat with onion and spices in a pan without oil.',
        'Boil pasta and add it to the meat.',
      ],
      stepsAr: [
        'نشوح اللحمة المفرومة مع بصل وملح وفلفل وبهارات وملعقة عسل في طاسة بدون دهون.',
        'نسلق المكرونه ثم نضيفها علي اللحمة.',
      ],
      videoUrl:
          'https://www.instagram.com/reel/DJOexFBKiMI/?igsh=MWd4bDk4Z2R1NjFiOQ==',
      imageUrl: 'assets/img/Meals/Minced_meat_pasta.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Zucchini Pasta',
      nameAr: 'مكرونه الكوسة',
      ingredientsEn: [
        'Zucchini',
        'Salt, black pepper, spices',
        '1 tbsp olive oil',
        'Minced garlic',
        'Tomato juice',
      ],
      ingredientsAr: [
        'كوسة',
        'ملح، فلفل اسود، بهارات',
        'ملعقة زيت زيتون',
        'توم مفروم',
        'عصير طماطم',
      ],
      stepsEn: [
        'Cut zucchini into spaghetti-like shapes.',
        'Sauté garlic and tomato juice in olive oil.',
        'Add zucchini and cook for 10 minutes.',
      ],
      stepsAr: [
        'نقطع الكوسة على شكل مكرونة اسباجتي.',
        'نشوح توم مفروم وعصير طماطم في زيت زيتون.',
        'نضيف الكوسة ونقلب لمدة ١٠ دقائق.',
      ],
      videoUrl:
          'https://www.instagram.com/reel/DJzHD8atT1g/?igsh=NHdjOGs4aW5vZnB4',
      imageUrl: 'assets/img/Meals/Zucchini_Pasta.jpg',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Pasta salad',
      nameAr: 'سلطه المكرونه',
      ingredientsEn: [
        'Cooked oat or regular pasta',
        'Tuna or grilled chicken breast',
        'Dressing: Greek yogurt, salt, pepper, garlic & onion powder, 1 tbsp mustard',
        'Bell peppers and arugula',
      ],
      ingredientsAr: [
        'مكرونة شوفان مسلوقة أو عادية',
        'تونة أو صدور فراخ مشوية',
        'الصوص: زبادي يوناني، ملح وفلفل، توم وبصل بودر، ملعقة مسطردة',
        'الخضار: فلفل الوان وجرجير',
      ],
      stepsEn: ['Mix all ingredients and dressing together.'],
      stepsAr: ['نضيف المكرونة والبروتين والضار ونخلطهم مع الصوص.'],
      videoUrl:
          'https://www.instagram.com/reel/DCwogz1N5KA/?igsh=MWl1ajMwbjFiMWZqMA==',
      imageUrl: 'assets/img/Meals/Pasta_salad.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Feteer',
      nameAr: 'فطير',
      ingredientsEn: [
        '3 pieces rice paper',
        '2-3 eggs',
        '1 tbsp milk',
        'Salt & black pepper',
        'Filling: Ground beef & low-fat mozzarella',
      ],
      ingredientsAr: [
        '٣ قطع ورق أرز',
        '٢-٣ بيضات',
        'ملعقة كبيرة حليب',
        'ملح وفلفل أسود',
        'الحشوة: لحم مفروم وجبن موزاريلا لايت',
      ],
      stepsEn: [
        'Dip rice paper in egg and milk mixture.',
        'Add filling and bake at 200°C for 15 minutes.',
      ],
      stepsAr: [
        'نضع ورق الأرز في خليط البيض والحليب والبهارات.',
        'نضيف الحشوة وتُخبز في الفرن على حرارة ٢٠٠ درجة لمدة ١٥ دقيقة.',
      ],
      videoUrl:
          'https://www.instagram.com/reel/DKXKNSfNPQz/?igsh=MTRnOTh6ZG80d2JnMw==',
      imageUrl: 'assets/img/Meals/Feteer.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Bechamel Eggplant',
      nameAr: 'باذنجان بشاميل',
      ingredientsEn: [
        '1 large eggplant',
        'Salt, black pepper, olive oil',
        'Minced meat',
        'Bechamel: 1 cup milk, 3 tbsp oat flour, salt, pepper',
        'Optional: low-fat mozzarella',
      ],
      ingredientsAr: [
        'باذنجان كبير',
        'ملح وفلفل، زيت زيتون',
        'لحم مفروم',
        'البشاميل: كوب حليب، 3 ملاعق دقيق شوفان، ملح وفلفل',
        'موتزريلا لايت',
      ],
      stepsEn: [
        'Slice eggplant, season, drizzle with olive oil, and bake for 15 mins.',
        'Make bechamel by mixing milk with oat flour and spices.',
        'Layer bechamel, eggplant, cooked minced meat, then bechamel again.',
        'Bake at 180°C for 15 minutes.',
      ],
      stepsAr: [
        'نقطع الباذنجان شرائح ونتبله ونشوية في الفرن زيت زيتون لمدة ١٥ دقيقة.',
        'نحضر البشاميل بخلط الحليب مع دقيق الشوفان والبهارات.',
        'نرص طبقة بشاميل ثم باذنجان ثم لحم مفروم ثم باقي البشاميل.',
        'تُخبز في الفرن لمدة ١٥ دقيقة على حرارة ١٨٠.',
      ],
      videoUrl:
          'https://www.instagram.com/reel/DF-qEQ6NLqZ/?igsh=MTczYXRseHBjYXY5bA==',
      imageUrl: 'assets/img/Meals/Bechamel_Eggplant.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Jelly',
      nameAr: 'چيلي',
      ingredientsEn: [
        'Sugar-free jelly powder',
        '2 cups water (1 boiling, 1 cold)',
      ],
      ingredientsAr: [
        'مسحوق جيلي خالي من السكر',
        '٢ كوب ماء (واحد مغلي وواحد عادي)',
      ],
      stepsEn: ['Mix powder with water, stir, and refrigerate until set.'],
      stepsAr: ['نضيف الماء للمسحوق ونقلب ثم نضعه في الثلاجة حتى يتماسك.'],
      videoUrl:
          'https://www.instagram.com/reel/DI6ezD3tVtN/?igsh=MW5nb2tzc2tkbTRiMg==',
      imageUrl: 'assets/img/Meals/Jelly.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Corn',
      nameAr: 'ذرة',
      ingredientsEn: [
        'Sweet corn',
        'Olive oil',
        'Spices',
        'Sauce: Greek yogurt, 1/4 cup milk, dill, 1 tbsp light mayo, salt, pepper',
      ],
      ingredientsAr: [
        'ذرة سكرية',
        'زيت زيتون',
        'بهارات',
        'الصوص: زبادي يوناني، ربع كوب لبن، شبت، ملعقة مايونيز لايت، ملح وفلفل',
      ],
      stepsEn: [
        'Parboil corn, cut, and drizzle with olive oil.',
        'Air fry or bake for 15 minutes.',
        'Mix sauce ingredients and serve with corn.',
      ],
      stepsAr: [
        'نسلق الذرة نصف سلقة، نقطعها ونضيف زيت زيتون وبهارات.',
        'تدخل الايرفراير أو الفرن لمدة ربع ساعة.',
        'نخلط مكونات الصوص وتقدم مع الذرة.',
      ],
      videoUrl:
          'https://www.instagram.com/reel/DEz8gGJtxPb/?igsh=MW9tcnhkbmVzZG9pYw==',
      imageUrl: 'assets/img/Meals/Corn.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Brownies',
      nameAr: 'براونيز',
      ingredientsEn: [
        '2.5 tbsp coconut flour',
        '4 eggs',
        '1.5 tbsp unsweetened cocoa powder',
        '3 tbsp sugar substitute',
        '15g butter',
        '6g shredded coconut',
        'Baking powder',
        '35g dark chocolate',
      ],
      ingredientsAr: [
        'ملعقتان ونصف دقيق جوز الهند',
        '٤ بيضات',
        'ملعقة ونصف كاكاو خام',
        '٣ ملاعق بديل سكر',
        '١٥ غرام زبدة',
        '٦ غرام جوز هند مبشور',
        'بيكنج باودر',
        '٣٥ غرام شوكولاتة داكنة',
      ],
      stepsEn: [
        'Pour batter into air fryer with parchment paper and cook at 170°C for 15-20 minutes.',
      ],
      stepsAr: [
        'نضع الخليط في القلاية الهوائية على ورق زبدة ونخبز على حرارة ١٧٠ لمدة ١٥-٢٠ دقيقة.',
      ],
      videoUrl:
          'https://www.instagram.com/reel/C3iSiliMmlB/?igsh=OHptcmU1enVpd2Jr',
      imageUrl: 'assets/img/Meals/Brownies.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Healthy Cake',
      nameAr: 'كيك صحي',
      ingredientsEn: [
        '1 egg',
        '4 tbsp shredded coconut',
        'Vanilla',
        '2 tbsp Greek yogurt',
        '1 tbsp butter',
        '2 tbsp oat flour',
        '1/4 tsp baking powder',
        'Stevia',
      ],
      ingredientsAr: [
        'بيضة',
        '٤ ملاعق جوز هند',
        'فانيليا',
        '٢ ملعقة زبادي يوناني',
        'ملعقة زبدة',
        'ملعقتين دقيق الشوفان',
        'ربع ملعقة بيكنج بودر',
        'سكر استيڤيا',
      ],
      stepsEn: [
        'Microwave for 1 minute.',
        'Spread with a spoonful of milk after baking.',
        'Calories: < 300, Protein: 15g',
      ],
      stepsAr: [
        'مايكروويف لمدة دقيقة.',
        'أول ما تطلع نشربها بملعقة لبن.',
        'أقل من ٣٠٠ سعر حراري و ١٥ جرام بروتين.',
      ],
      videoUrl:
          'https://www.instagram.com/reel/DMDTnMINBGH/?igsh=MXZ6Z3BudGx4eWRoeg==',
      imageUrl: 'assets/img/Meals/Healthy_Cake.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Kunafa',
      nameAr: 'كنافة',
      ingredientsEn: [
        '100g kunafa',
        '10g butter',
        '3 tbsp sugar substitute',
        'Filling: Healthy chocolate & 30g nuts',
        'Syrup: Lemon, 1/2 cup water, sugar substitute, 1 tsp honey',
      ],
      ingredientsAr: [
        '١٠٠ جرام كنافة',
        '١٠ جرام زبدة',
        '٣ ملاعق سكر دايت',
        'الحشو: شكولاتة صحية و٣٠ جرام مكسرات',
        'الشربات: لمون، نصف كوب ماء، سكر دايت، معلقة عسل',
      ],
      stepsEn: [
        'Mix kunafa with butter and sugar substitute.',
        'Add filling and bake at 200°C.',
        'Pour healthy syrup over hot kunafa.',
      ],
      stepsAr: [
        'نخلط الكنافة مع الزبدة والسكر.',
        'نضيف الحشو ونخبز في الفرن على حرارة ٢٠٠.',
        'نضيف الشربات الصحي أول ما تخرج.',
      ],
      videoUrl:
          'https://www.instagram.com/reel/C4qwTUjMl3V/?igsh=NzNqMXF1amdldGxk',
      imageUrl: 'assets/img/Meals/Kunafa.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Katayef',
      nameAr: 'قطايف',
      ingredientsEn: [
        '50g oat flour',
        '1 tbsp yeast',
        '1 tbsp honey',
        '1/2 cup water',
        'Filling: Almonds, raisins, dates, coconut, cinnamon',
        'Syrup: 50ml water, 25g diet sugar, 1 tbsp honey, half lemon',
      ],
      ingredientsAr: [
        '٥٠ غرام دقيق شوفان',
        'ملعقة كبيرة خميرة',
        'ملعقة كبيرة عسل',
        'نصف كوب ماء',
        'الحشوة: لوز، زبيب، تمر، جوز هند، قرفة',
        'الشربات: ٥٠ مل ماء، ٢٥ غرام سكر دايت، ملعقة عسل، نصف ليمونة',
      ],
      stepsEn: [
        'Blend oat flour, yeast, honey, and water.',
        'Cook on medium heat for 4-5 mins each side.',
        'Fill as desired and serve with healthy syrup.',
      ],
      stepsAr: [
        'نخلط دقيق الشوفان والخميرة والعسل والماء جيداً.',
        'نطبخ القطايف في طاسة مسح زبدة على نار متوسطة.',
        'نحشي القطايف حسب الرغبة ونغلي مكونات الشربات لمدة ٨ دقائق.',
      ],
      videoUrl:
          'https://www.instagram.com/reel/C4fzkOcMehy/?igsh=MWZ5OWp1OHp3OHV2aw==',
      imageUrl: 'assets/img/Meals/Katayef.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Ice cream',
      nameAr: 'ايس كريم',
      ingredientsEn: ['1kg cantaloupe (pulp/pulp seeds)', 'Stevia'],
      ingredientsAr: ['كيلو كانتلوب', 'سكر استيڤيا'],
      stepsEn: [
        'Blend cantaloupe pulp and stevia with hand blender.',
        'Freeze small pieces for 2 hours.',
        'Blend again in food processor then hand blender until creamy.',
      ],
      stepsAr: [
        'نضرب قلب الكانتلوب مع سكر استيفيا بالهاند بليندر.',
        'نقطع الكانتلوب مكعبات صغيرة ونتركه في الفريزر ساعتين.',
        'نضرب الخليط في الكبة ثم الهاند بليندر لقوام كريمي.',
      ],
      videoUrl:
          'https://www.instagram.com/reel/DLfQhnatEk1/?igsh=anBjbWxldmFxdGEy',
      imageUrl: 'assets/img/Meals/Ice_cream.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Pizza',
      nameAr: 'بيتزا',
      ingredientsEn: [
        '3 boiled potatoes',
        '5 tbsp oat flour',
        'Salt & black pepper',
        'Pizza sauce',
        'Toppings/Vegetables as desired',
      ],
      ingredientsAr: [
        '٣ حبات بطاطس مسلوقة',
        '٥ ملاعق دقيق شوفان',
        'ملح وفلفل أسود',
        'صلصة بيتزا',
        'خضروات وإضافات حسب الرغبة',
      ],
      stepsEn: [
        'Mash potatoes, add oat flour and spices to form dough.',
        'Place on parchment paper, add sauce and toppings.',
        'Bake at 180°C for 15 minutes.',
      ],
      stepsAr: [
        'نهرس البطاطس ونضيف دقيق الشوفان والبهارات لتكوين عجينة.',
        'نفرد العجينة على ورق زبدة ونضيف الصلصة والحشوة.',
        'تُخبز في الفرن على حرارة ١٨٠ لمدة ١٥ دقيقة.',
      ],
      videoUrl:
          'https://www.instagram.com/reel/DNvc83QI6Ad/?igsh=Ym5jbnRoOWxsMzly',
      imageUrl: 'assets/img/Meals/Pizza.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Lentil soup',
      nameAr: 'شوربه العدس',
      ingredientsEn: [
        '1 cup lentils',
        '2 carrots',
        '1 onion',
        '1 tomato',
        '2 cups water',
        'Salt, pepper, cumin',
        '5g butter',
      ],
      ingredientsAr: [
        'كوب عدس',
        '٢ جزرة',
        'بصلة واحدة',
        'طماطم واحدة',
        '٢ كوب ماء',
        'ملح وفلفل وكمون',
        '٥ غرام زبدة',
      ],
      stepsEn: [
        'Boil all ingredients together.',
        'Blend with immersion blender and add butter.',
      ],
      stepsAr: [
        'نسلق كل المكونات مع بعض.',
        'بعد الغليان، نضرب بالهاند بليندر ونضيف الزبدة.',
      ],
      videoUrl:
          'https://www.instagram.com/reel/DBG7uiosh4h/?igsh=MWsxYThnbWV5eWhreQ==',
      imageUrl: 'assets/img/Meals/Lentil_soup.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Bread',
      nameAr: 'خبز',
      ingredientsEn: [
        '2 tbsp tahini',
        '1 egg',
        '1 tsp salt',
        '1-2 tbsp water',
        'Olive oil',
        'Nigella seeds',
      ],
      ingredientsAr: [
        'ملعقتان طحينة سمسم',
        'بيضة',
        'ملعقة صغيرة ملح',
        '١-٢ ملعقة ماء',
        'زيت زيتون',
        'حبة البركة',
      ],
      stepsEn: [
        'Mix ingredients together.',
        'Cook in a pan with olive oil and sprinkle nigella seeds.',
        'Suitable for insulin resistance and PCOS.',
      ],
      stepsAr: [
        'نخلط كل المكونات جيداً.',
        'في طاسة مع زيت زيتون، نضع الخليط وحبة البركة.',
        'مناسب لمقاومة الأنسولين وتكيس المبايض.',
      ],
      videoUrl:
          'https://www.instagram.com/reel/DEh7hz5NfdL/?igsh=OXl3dmg5dmU1end1',
      imageUrl: 'assets/img/Meals/Bread.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Healthy Nutella',
      nameAr: 'نوتيلا',
      ingredientsEn: [
        'Soft dates',
        '2 tbsp coconut butter/ghee/butter',
        '1 tbsp raw tahini',
        '2 tbsp raw cocoa',
        'Optional: Stevia',
      ],
      ingredientsAr: [
        'تمر طري',
        'ملعقتين زبدة جوز هند أو زبدة',
        'ملعقة طحينة خام',
        'ملعقتين كبار كاكاو خام',
        'سكر استيڤيا اختياري',
      ],
      stepsEn: ['Mix all ingredients in a food processor until smooth.'],
      stepsAr: ['يتم خلط جميع المكونات في الكبة.'],
      videoUrl:
          'https://www.instagram.com/reel/DOlhrjLDSNR/?igsh=NzYzYmVvemZnZTRw',
      imageUrl: 'assets/img/Meals/Healthy_Nutella.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Nuggets',
      nameAr: 'ناجتس',
      ingredientsEn: [
        '200g chicken breast',
        '1 egg',
        'Low-fat mozzarella',
        'Salt, pepper, paprika',
        'Olive oil',
      ],
      ingredientsAr: [
        '٢٠٠ جرام صدور فراخ',
        'بيضة',
        'جبنة موتزريلا لايت',
        'ملح وفلفل واسود وبابريكا',
        'زيت زيتون',
      ],
      stepsEn: [
        'Blend chicken, egg, cheese, and spices in processor.',
        'Shape chicken and place on parchment paper with olive oil.',
        'Bake at 180°C for 20 minutes.',
      ],
      stepsAr: [
        'نخلط الفراخ والبيضة والجبنة والبهارات في الكبة.',
        'نشكل الفراخ على ورق زبدة مع رشة زيت زيتون.',
        'ندخل الفرن على حرارة ١٨٠ لمدة ٢٠ دقيقه.',
      ],
      videoUrl:
          'https://www.instagram.com/reel/DFAz2bHNIZO/?igsh=ODI2NmZmazRqdzBl',
      imageUrl: 'assets/img/Meals/Nuggets.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Sambousak',
      nameAr: 'سمبوسك',
      ingredientsEn: [
        'Low calorie bread',
        'Low-fat mozzarella or preferred filling',
        'Olive oil',
        'Nigella seeds',
      ],
      ingredientsAr: [
        'خبز قليل السعرات',
        'جبنة موزاريلا لايت أو أي حشوة',
        'زيت زيتون',
        'حبة البركة',
      ],
      stepsEn: [
        'Cut bread into 3 slices.',
        'Add filling and roll like sambousak.',
        'Drizzle with olive oil and nigella seeds.',
        'Bake or air fry at 180°C for 10 minutes.',
      ],
      stepsAr: [
        'نقطع الخبز ٣ شرائح ونحشيه ونلفه.',
        'نرش زيت زيتون وحبة البركة.',
        'تُخبز في الفرن أو القلاية الهوائية لمدة ١٠ دقائق على حرارة ١٨٠.',
      ],
      videoUrl:
          'https://www.instagram.com/reel/DGa8Va_NQLA/?igsh=M3QxbGFrY3EwM2R0',
      imageUrl: 'assets/img/Meals/Sambousak.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Cornflakes',
      nameAr: 'كورن فليكس',
      ingredientsEn: [
        '1 tbsp tahini',
        '1 tbsp cinnamon or cocoa',
        'Honey',
        '5 Rice cakes',
      ],
      ingredientsAr: [
        'ملعقة طحينة',
        'ملعقة قرفة أو كاكاو',
        'عسل',
        '٥ قطع رايس كيك',
      ],
      stepsEn: [
        'Break rice cakes and mix with other ingredients.',
        'Bake at 180°C for 10 minutes.',
      ],
      stepsAr: [
        'نكسر الرايس كيك ونضيفه على باقي المكونات.',
        'ندخل الايرفراير أو الفرن على حرارة ١٨٠ لمدة ١٠ دقائق.',
      ],
      videoUrl:
          'https://www.instagram.com/reel/DLxSDVYtFZy/?igsh=MTFiNjE2OWNqaWQyaA==',
      imageUrl: 'assets/img/Meals/Cornflakes.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Burger',
      nameAr: 'برجر',
      ingredientsEn: [
        'Diet tortilla or low-calorie bread',
        'Ground beef patty',
        'Salt, pepper, burger seasoning',
        'Olive oil',
      ],
      ingredientsAr: [
        'خبز تورتيلا لايت أو قليل السعرات',
        'لحمة مفرومة (برجر)',
        'ملح وفلفل وتوابل برجر',
        'زيت زيتون',
      ],
      stepsEn: [
        'Place patty on bread and press.',
        'Season and cook in a pan with a drop of olive oil.',
      ],
      stepsAr: [
        'نضع اللحم في الخبز ونضغط عليه.',
        'نتبل ونطبخ في طاسة مع نقطة زيت زيتون.',
      ],
      videoUrl:
          'https://www.instagram.com/reel/DBq_FAlNH8W/?igsh=ODFpcTZkampnemlq',
      imageUrl: 'assets/img/Meals/Burger.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Hotchocolate',
      nameAr: 'مشروب الشوكولاته',
      ingredientsEn: [
        '1 cup coconut milk (or any milk)',
        '2 tsp raw cocoa',
        'Boiled potato (for thick consistency)',
        '1-2 dark chocolate squares',
        'Stevia',
      ],
      ingredientsAr: [
        'كوب حليب جوز هند أو أي حليب',
        'ملعقتان صغيرتان كاكاو خام',
        'بطاطا مسلوقة (بدل النشا)',
        'مربع أو اثنان شوكولاتة داكنة',
        'سكر ستيفيا',
      ],
      stepsEn: ['Blend all ingredients and simmer briefly on low heat.'],
      stepsAr: ['نخلط المكونات بالهاند بليندر ونتركها على نار هادئة.'],
      videoUrl:
          'https://www.instagram.com/reel/DD4tYyHtxi6/?igsh=emJ5c2NoY3hwbWJp',
      imageUrl: 'assets/img/Meals/Hotchocolate.webp',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Croissant',
      nameAr: 'كرواسون',
      ingredientsEn: [
        '2 eggs',
        '1/4 cup milk',
        '2 tbsp butter',
        'Baking powder',
        'Pinch of cinnamon',
        'Rice paper',
      ],
      ingredientsAr: [
        'بيضتين',
        'ربع كوب لبن',
        'معلقتين زبدة',
        'بيكنج بودر',
        'رشة قرفة',
        'ورق أرز',
      ],
      stepsEn: [
        'Mix liquid ingredients together.',
        'Dip rice paper in mixture for 3 seconds to soften.',
        'Roll into croissant shape and bake at 180°C for 15 minutes.',
      ],
      stepsAr: [
        'نخلط البيض واللبن والزبدة والبودر والقرفة.',
        'نغمس ورق الأرز في الخليط لمدة ٣ ثواني حتى يطرى.',
        'نلف على شكل كرواسون ونخبز في الفرن على حرارة ١٨٠ لمدة ١٥ دقيقة.',
      ],
      videoUrl:
          'https://www.instagram.com/reel/DFS1eGtNKBy/?igsh=bDF2dTlib29rY3Vy',
      imageUrl: 'assets/img/Meals/Croissant.webp',
    ),
  ];

  // دالة لرفع أيقونة أو صورة من الـ Assets إلى Firebase Storage
  Future<String> _uploadAssetToStorage(String assetPath, String folder) async {
    try {
      final fileName = assetPath.split('/').last.split('.').first;
      final ref = FirebaseStorage.instance.ref().child(
        '$folder/$fileName.webp',
      );

      final byteData = await DefaultAssetBundle.of(context).load(assetPath);
      Uint8List bytes = byteData.buffer.asUint8List();

      // Compress and convert to WebP
      bytes = await ImageCompressor.compressBytes(bytes);

      await ref.putData(bytes, SettableMetadata(contentType: 'image/webp'));
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading $assetPath: $e');
      return '';
    }
  }

  Future<void> _uploadDoctors() async {
    setState(() {
      _isUploading = true;
      _status = 'Uploading Specialists & Images...';
    });
    try {
      final collection = FirebaseFirestore.instance.collection('specialists');

      final existingDocs = await collection.get();
      for (var doc in existingDocs.docs) {
        await doc.reference.delete();
      }

      for (var doctor in premiumDoctors) {
        String finalImageUrl = doctor.imageUrl;

        if (doctor.imageUrl.startsWith('assets/')) {
          finalImageUrl = await _uploadAssetToStorage(
            doctor.imageUrl,
            'doctors',
          );
        }

        final data = doctor.toFirestore();
        data['imageUrl'] = finalImageUrl;

        await collection.add(data);
      }

      setState(() {
        _isUploading = false;
        _status = 'Success! All doctors uploaded with their official images.';
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
        _status = 'Error: $e';
      });
    }
  }

  Future<void> _uploadRecipes() async {
    setState(() {
      _isUploading = true;
      _status = 'Uploading Healthy Recipes & Images...';
    });
    try {
      final collection = FirebaseFirestore.instance.collection(
        'healthy_recipes',
      );
      final existingDocs = await collection.get();
      for (var doc in existingDocs.docs) {
        await doc.reference.delete();
      }

      for (var recipe in premiumRecipes) {
        String finalImageUrl = recipe.imageUrl;

        if (recipe.imageUrl.startsWith('assets/')) {
          finalImageUrl = await _uploadAssetToStorage(
            recipe.imageUrl,
            'recipes',
          );
        }

        final data = recipe.toFirestore();
        data['imageUrl'] = finalImageUrl;

        await collection.add(data);
      }

      setState(() {
        _isUploading = false;
        _status = 'Success! Healthy Recipes and their images are live.';
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
        _status = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        title: const Text('Premium Uploader'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const AppBackButton(),
        foregroundColor: const Color(0xFF2D3142),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stars_rounded, size: 80, color: Colors.orange),
              const SizedBox(height: 24),
              Text(
                'Data Setup Center',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 40),
              if (_isUploading)
                const AppLoadingIndicator(size: 80)
              else ...[
                _buildUploadButton(
                  title: 'Upload Specialists',
                  icon: Icons.local_hospital_rounded,
                  onPressed: _uploadDoctors,
                ),
                const SizedBox(height: 16),
                _buildUploadButton(
                  title: 'Upload Healthy Recipes',
                  icon: Icons.restaurant_menu_rounded,
                  onPressed: _uploadRecipes,
                  color: Colors.green,
                ),
              ],
              const SizedBox(height: 40),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
    Color color = AppTheme.appBlue,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(title, style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
