import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/utils/app_routes.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/main.dart';
import 'package:system_5210/core/services/local_storage_service.dart';
import 'package:system_5210/core/utils/injection_container.dart' as di;
import 'dart:ui';

class LanguageView extends StatelessWidget {
  final bool fromSettings;
  const LanguageView({super.key, this.fromSettings = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Center(child: Image.asset(AppImages.logo, height: 180))
                      .animate()
                      .scale(duration: 400.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 20),
                  Text(
                    'Select Language',
                    style: GoogleFonts.dynaPuff(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3142),
                    ),
                  ).animate().slideY(begin: 0.3, curve: Curves.easeOutBack),
                  const SizedBox(height: 10),
                  Text(
                    'اختر لغتك المفضلة',
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF64748B),
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 36),
                  _LanguageButton(
                    title: 'English',
                    flag: '🇺🇸',
                    onTap: () => _changeLanguage(context, 'en'),
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                  const SizedBox(height: 16),
                  _LanguageButton(
                    title: 'العربية',
                    flag: '🇪🇬',
                    isArabic: true,
                    onTap: () => _changeLanguage(context, 'ar'),
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1),
                  const Spacer(flex: 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _changeLanguage(BuildContext context, String langCode) async {
    // 1. Update App State
    appLocale.value = Locale(langCode);

    // 2. Persist Selection
    try {
      final localStorage = di.sl<LocalStorageService>();
      await localStorage.save('settings', 'language', {'code': langCode});
    } catch (e) {
      debugPrint("Failed to save language: $e");
    }

    // 3. Navigate
    if (fromSettings) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    }
  }
}

class _LanguageButton extends StatelessWidget {
  final String title;
  final String flag;
  final VoidCallback onTap;
  final bool isArabic;

  const _LanguageButton({
    required this.title,
    required this.flag,
    required this.onTap,
    this.isArabic = false,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1565C0);

    return Container(
      width: double.infinity,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(flag, style: const TextStyle(fontSize: 32)),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style:
                                (isArabic
                                ? GoogleFonts.cairo
                                : GoogleFonts.poppins)(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1E293B),
                                  height: 1.2,
                                ),
                          ),
                          Text(
                            isArabic ? 'هيا بنا' : "Let's Go",
                            style:
                                (isArabic
                                ? GoogleFonts.cairo
                                : GoogleFonts.poppins)(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF64748B),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color(0xFF1565C0),
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
