import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/features/daily_tasks_game/presentation/widgets/glass_card.dart';
import 'package:system_5210/features/profile/presentation/manager/profile_cubit.dart';
import 'package:system_5210/features/profile/presentation/manager/profile_state.dart';

class HeroLabView extends StatefulWidget {
  const HeroLabView({super.key});

  @override
  State<HeroLabView> createState() => _HeroLabViewState();
}

class _HeroLabViewState extends State<HeroLabView> {
  double _weight = 25.0;
  double _height = 120.0;
  int _age = 8;
  final int _selectedCharacter = 1;

  @override
  void initState() {
    super.initState();
    final profileState = context.read<ProfileCubit>().state;
    if (profileState is ProfileLoaded) {
      final quiz = profileState.profile.quizAnswers;
      if (quiz['weight'] != null) {
        _weight = double.tryParse(quiz['weight'].toString()) ?? 25.0;
      }
      if (quiz['height'] != null) {
        _height = double.tryParse(quiz['height'].toString()) ?? 120.0;
      }
      if (quiz['age'] != null) _age = int.tryParse(quiz['age'].toString()) ?? 8;
    }
  }

  double _calculateBMI() {
    if (_height == 0) return 0;
    return _weight / ((_height / 100) * (_height / 100));
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final bmi = _calculateBMI();

    return Scaffold(
      body: Stack(
        children: [
          // 1. App Background
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const AppBackButton(),
                      const Spacer(),
                      Text(
                        isAr ? 'معمل الأبطال' : 'Hero Lab',
                        style:
                            (isAr ? GoogleFonts.cairo : GoogleFonts.dynaPuff)(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.appBlue,
                            ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        // 2. Character Display (The Hero)
                        _buildCharacterDisplay(),

                        const SizedBox(height: 30),

                        // 3. Main Stats Cards
                        _buildInputSections(isAr),

                        const SizedBox(height: 25),

                        // 4. Power Index (BMI) Card
                        _buildBMICard(bmi, isAr),

                        const SizedBox(height: 35),

                        // 5. Upgrade Action
                        _buildUpgradeButton(isAr),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterDisplay() {
    final characters = [
      AppImages.character1,
      AppImages.character2,
      AppImages.character3,
      AppImages.character4,
    ];

    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Tech Ring decoration
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.appBlue.withOpacity(0.15),
                width: 2,
              ),
            ),
          ).animate(onPlay: (c) => c.repeat()).rotate(duration: 15.seconds),

          // Scanning Line
          Container(
                width: 200,
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.appBlue.withOpacity(0),
                      AppTheme.appBlue.withOpacity(0.4),
                      AppTheme.appBlue.withOpacity(0),
                    ],
                  ),
                ),
              )
              .animate(onPlay: (c) => c.repeat())
              .moveY(begin: -80, end: 80, duration: 2.5.seconds),

          Image.asset(
            characters[_selectedCharacter + 1],
            height: 150,
          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
        ],
      ),
    );
  }

  Widget _buildInputSections(bool isAr) {
    return Column(
      children: [
        _buildSliderTile(
          title: isAr ? 'طول البطل' : 'Height',
          value: _height.toInt().toString(),
          unit: 'cm',
          icon: Icons.height_rounded,
          color: AppTheme.appBlue,
          currentValue: _height,
          min: 80,
          max: 200,
          onChanged: (val) => setState(() => _height = val),
          isAr: isAr,
        ),
        const SizedBox(height: 15),
        _buildSliderTile(
          title: isAr ? 'وزن البطل' : 'Weight',
          value: _weight.toInt().toString(),
          unit: 'kg',
          icon: Icons.monitor_weight_rounded,
          color: const Color(0xFF2ECC71),
          currentValue: _weight,
          min: 10,
          max: 150,
          onChanged: (val) => setState(() => _weight = val),
          isAr: isAr,
        ),
        const SizedBox(height: 15),
        _buildAgeSelector(isAr),
      ],
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required double currentValue,
    required double min,
    required double max,
    required Function(double) onChanged,
    required bool isAr,
  }) {
    return GlassCard(
      opacity: 0.8,
      blur: 20,
      borderRadius: 30,
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                  color: AppTheme.appBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: AppTheme.appBlue,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                " $unit",
                style: GoogleFonts.poppins(color: Colors.black38, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.1),
              thumbColor: Colors.white,
              overlayColor: color.withOpacity(0.2),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 10,
                elevation: 3,
              ),
            ),
            child: Slider(
              value: currentValue,
              min: min,
              max: max,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                onChanged(val);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeSelector(bool isAr) {
    return GlassCard(
      opacity: 0.8,
      blur: 20,
      borderRadius: 30,
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.appYellow.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.cake_rounded,
                  color: AppTheme.appYellow,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isAr ? 'العمر' : 'Age',
                style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                  color: AppTheme.appBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                "$_age ",
                style: GoogleFonts.poppins(
                  color: AppTheme.appBlue,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                isAr ? 'سنوات' : 'Years',
                style: GoogleFonts.poppins(color: Colors.black38, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 55,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: 15,
              itemBuilder: (context, index) {
                final age = index + 5;
                final isSelected = _age == age;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _age = age);
                  },
                  child: AnimatedContainer(
                    duration: 200.ms,
                    width: 55,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.appBlue
                          : AppTheme.appBlue.withOpacity(0.05),
                      shape: BoxShape.circle,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppTheme.appBlue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        age.toString(),
                        style: GoogleFonts.poppins(
                          color: isSelected ? Colors.white : AppTheme.appBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMICard(double bmi, bool isAr) {
    String status = isAr ? 'طبيعي' : 'Normal';
    Color color = AppTheme.appGreen;

    if (bmi < 18.5) {
      status = isAr ? 'وزن منخفض' : 'Underweight';
      color = AppTheme.appBlue;
    } else if (bmi > 25) {
      status = isAr ? 'وزن زائد' : 'Overweight';
      color = const Color(0xFFFF5F5F);
    }

    return GlassCard(
      opacity: 0.8,
      blur: 20,
      borderRadius: 30,
      color: Colors.white,
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? 'مؤشر قوة البطل' : 'Hero Power Index',
                  style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              bmi.toStringAsFixed(1),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton(bool isAr) {
    return Container(
          width: double.infinity,
          height: 65,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.appBlue, AppTheme.appBlue.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppTheme.appBlue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              context.read<ProfileCubit>().updateBioData(
                height: _height,
                weight: _weight,
                age: _age,
              );
              HapticFeedback.heavyImpact();
              _showSuccessEffect();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              isAr ? 'تحديث قدرات البطل' : 'Upgrade Hero Stats',
              style: (isAr ? GoogleFonts.cairo : GoogleFonts.dynaPuff)(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 2.seconds);
  }

  void _showSuccessEffect() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: GlassCard(
            opacity: 0.9,
            blur: 20,
            borderRadius: 30,
            color: Colors.white,
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.appGreen,
                      size: 80,
                    )
                    .animate()
                    .scale(duration: 500.ms, curve: Curves.easeOutBack)
                    .then()
                    .shake(),
                const SizedBox(height: 20),
                Text(
                  "UPGRADE COMPLETE",
                  style: GoogleFonts.dynaPuff(
                    color: AppTheme.appBlue,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ).animate().fadeIn().moveY(begin: 20),
              ],
            ),
          ),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close dialog
      Navigator.pop(context); // Back to Home
    });
  }
}
