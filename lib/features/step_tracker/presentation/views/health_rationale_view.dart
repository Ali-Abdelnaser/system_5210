import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

class HealthRationaleView extends StatelessWidget {
  const HealthRationaleView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  
                  Container(
                    width: 100,
                    height: 100,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.appBlue.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: AppTheme.appBlue,
                      size: 60,
                    ),
                  ).animate().scale(
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),

                  const SizedBox(height: 30),

                  Text(
                    isAr
                        ? "لماذا نحتاج لبياناتك الصحية؟"
                        : "Why do we need health data?",
                    textAlign: TextAlign.center,
                    style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Rationale Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildReasonRow(
                              icon: Icons.directions_run_rounded,
                              title: isAr ? "تتبع النشاط" : "Activity Tracking",
                              desc: isAr
                                  ? "نحن نستخدم حساسات الموبايل المباشرة لقراءة عدد خطواتك اليومي لنساعدك في الوصول لهدف الـ 5210 الصحي."
                                  : "We use your phone's internal sensors to read your daily steps count to help you achieve your 5210 health goals.",
                              isAr: isAr,
                            ),
                            const Divider(height: 40),
                            _buildReasonRow(
                              icon: Icons.security_rounded,
                              title: isAr ? "الخصوصية أولاً" : "Privacy First",
                              desc: isAr
                                  ? "يتم استخدام بياناتك فقط داخل التطبيق لعرض تقدمك. نحن لا نشارك بياناتك الصحية أبداً مع أي جهات خارجية."
                                  : "Your data is only used within the app to show your progress. We never share your health data with any third parties.",
                              isAr: isAr,
                            ),
                            const Divider(height: 40),
                            _buildReasonRow(
                              icon: Icons.verified_user_rounded,
                              title: isAr ? "تحكم كامل" : "Full Control",
                              desc: isAr
                                  ? "يمكنك دائماً إلغاء الوصول للبيانات من خلال إعدادات التطبيق أو الموبايل في أي وقت."
                                  : "You can always revoke data access through app or phone settings at any time.",
                              isAr: isAr,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: 40),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.appBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                        shadowColor: AppTheme.appBlue.withOpacity(0.3),
                      ),
                      child: Text(
                        isAr ? "فهمت، شكراً" : "I understand, thanks",
                        style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonRow({
    required IconData icon,
    required String title,
    required String desc,
    required bool isAr,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.appBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: AppTheme.appBlue, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: isAr
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                textAlign: isAr ? TextAlign.right : TextAlign.left,
                style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
