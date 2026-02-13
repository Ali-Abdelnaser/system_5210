import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/features/specialists/data/models/doctor_model.dart';
import 'package:system_5210/features/healthy_recipes/data/models/recipe_model.dart';
import 'package:system_5210/core/widgets/app_loading_indicator.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';

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
      nameEn: 'Dr. Ahmed Mansour',
      nameAr: 'د. أحمد منصور',
      specialtyEn: 'Pediatric Specialist',
      specialtyAr: 'أخصائي طب الأطفال',
      aboutEn:
          'Expert pediatrician with over 15 years of experience in child healthcare and nutrition.',
      aboutAr:
          'طبيب أطفال خبير يتمتع بخبرة تزيد عن 15 عاماً في برامج رعاية صحة الطفل والتغذية.',
      imageUrl:
          'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=800&q=80',
      clinicLocation: 'Maadi, Cairo',
      allowsOnlineConsultation: true,
      contactNumber: '01001234567',
      whatsappNumber: '01001234567',
      experienceYears: 15,
      workingDaysEn: ['Sat', 'Mon', 'Wed'],
      workingDaysAr: ['السبت', 'الاثنين', 'الأربعاء'],
      workingHoursEn: '06:00 PM - 10:00 PM',
      workingHoursAr: '06:00 م - 10:00 م',
      certificates: [],
    ),
    const DoctorModel(
      id: '',
      nameEn: 'Dr. Mona Hassan',
      nameAr: 'د. منى حسن',
      specialtyEn: 'Clinical Nutritionist',
      specialtyAr: 'أخصائية تغذية علاجية',
      aboutEn:
          'Specialist in clinical nutrition and metabolic health, focused on sustainable family wellness.',
      aboutAr:
          'أخصائية في التغذية العلاجية والصحة الأيضية، تركز على العافية الأسرية المستدامة.',
      imageUrl:
          'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=800&q=80',
      clinicLocation: 'Sheikh Zayed, Giza',
      allowsOnlineConsultation: true,
      contactNumber: '01112223333',
      whatsappNumber: '01112223333',
      experienceYears: 8,
      workingDaysEn: ['Sun', 'Tue', 'Thu'],
      workingDaysAr: ['الأحد', 'الثلاثاء', 'الخميس'],
      workingHoursEn: '10:00 AM - 04:00 PM',
      workingHoursAr: '10:00 ص - 04:00 م',
      certificates: [],
    ),
  ];

  final List<RecipeModel> premiumRecipes = [
    const RecipeModel(
      id: '',
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
      stepsEn: [
        'Place dates in warm water if they are not soft.',
        'Combine all ingredients in a food processor.',
        'Blend until completely smooth and creamy.',
        'Store in a glass jar in the refrigerator.',
      ],
      stepsAr: [
        'نحضر التمر ونضعه في ماء دافئ إذا لم يكن طرياً.',
        'نضع جميع المكونات في الكبة أو محضرة الطعام.',
        'نخلط جيداً حتى نحصل على قوام كريمي ناعم.',
        'تحفظ في برطمان زجاجي داخل الثلاجة.',
      ],
      videoUrl: 'https://www.instagram.com/hassankauod/reel/DOlhrjLDSNR/',
      imageUrl:
          'https://images.unsplash.com/photo-1523294587484-cccb444e8ec7?q=80&w=1000&auto=format&fit=crop',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Fresh Fruit Salad',
      nameAr: 'سلطة فواكه طازجة',
      ingredientsEn: ['Apple', 'Banana', 'Strawberry', 'Orange juice', 'Honey'],
      ingredientsAr: ['تفاح', 'موز', 'فراولة', 'عصير برتقال', 'عسل نحل'],
      stepsEn: ['Chop fruits', 'Mix with juice and honey'],
      stepsAr: ['قطع الفواكه', 'أضف العصير والعسل'],
      videoUrl: '',
      imageUrl:
          'https://images.unsplash.com/photo-1519996529931-28324d5a630e?q=80&w=1000&auto=format&fit=crop',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Healthy Avocado Toast',
      nameAr: 'توست الأفوكادو الصحي',
      ingredientsEn: ['Whole grain bread', 'Avocado', 'Egg', 'Black pepper'],
      ingredientsAr: ['خبز حبوب كاملة', 'أفوكادو', 'بيضة', 'فلفل أسود'],
      stepsEn: ['Toast the bread', 'Mash avocado', 'Top with boiled egg'],
      stepsAr: ['حمص الخبز', 'اهرس الأفوكادو', 'ضع البيض المسلوق في الأعلى'],
      videoUrl: '',
      imageUrl:
          'https://images.unsplash.com/photo-1525351484163-7529414344d8?q=80&w=1000&auto=format&fit=crop',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Berry Smoothie',
      nameAr: 'سموذي التوت المشكل',
      ingredientsEn: ['Blueberries', 'Raspberries', 'Milk', 'Greek yogurt'],
      ingredientsAr: ['توت أزرق', 'توت أحمر', 'حليب', 'زبادي يوناني'],
      stepsEn: ['Blend all ingredients', 'Serve cold'],
      stepsAr: ['اخلط المكونات', 'قدمها باردة'],
      videoUrl: '',
      imageUrl:
          'https://images.unsplash.com/photo-1553530245-565cb2913e61?q=80&w=1000&auto=format&fit=crop',
    ),
    const RecipeModel(
      id: '',
      nameEn: 'Veggie Rainbow Platter',
      nameAr: 'طبق الخضار المشكل',
      ingredientsEn: ['Carrots', 'Cucumber', 'Bell peppers', 'Hummus'],
      ingredientsAr: ['جزر', 'خيار', 'فلفل ألوان', 'حمص'],
      stepsEn: ['Slice vegetables', 'Serve with hummus dip'],
      stepsAr: ['قطع الخضار شرائح', 'قدمها مع غمسة الحمص'],
      videoUrl: '',
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=1000&auto=format&fit=crop',
    ),
  ];

  Future<void> _uploadDoctors() async {
    setState(() {
      _isUploading = true;
      _status = 'Uploading Specialists...';
    });
    try {
      final collection = FirebaseFirestore.instance.collection('specialists');
      final existingDocs = await collection.get();
      for (var doc in existingDocs.docs) {
        await doc.reference.delete();
      }
      for (var doctor in premiumDoctors) {
        await collection.add(doctor.toFirestore());
      }
      setState(() {
        _isUploading = false;
        _status = 'Success! Specialists data is live.';
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
      _status = 'Uploading Healthy Recipes...';
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
        await collection.add(recipe.toFirestore());
      }
      setState(() {
        _isUploading = false;
        _status = 'Success! Healthy Recipes data is live.';
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
