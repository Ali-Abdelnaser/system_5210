import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'package:system_5210/core/widgets/app_back_button.dart';

class DeveloperProfileView extends StatelessWidget {
  const DeveloperProfileView({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background - Pure White for cleanliness
          Positioned.fill(child: Container(color: Colors.white)),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Large Dynamic Header
              SliverAppBar(
                expandedHeight: size.height * 0.55,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: const AppBackButton(),
                stretch: true,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // The Image - Starts from the very top
                      Image.asset(AppImages.developerPhoto, fit: BoxFit.cover),
                      // Elegant Gradient Overlay for text readability
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.6, 0.85, 1.0],
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(0.8),
                                Colors.white,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Floating Name Card (Professional)
                      Positioned(
                        bottom: 40,
                        left: 24,
                        right: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                                  isAr ? "علي عبد الناصر " : "Ali Abdelnaser ",
                                  textAlign: TextAlign.center,
                                  style:
                                      (isAr
                                      ? GoogleFonts.cairo
                                      : GoogleFonts.poppins)(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                        color: const Color.fromARGB(
                                          255,
                                          2,
                                          109,
                                          158,
                                        ),
                                        letterSpacing: 1.2,
                                      ),
                                )
                                .animate()
                                .fadeIn(duration: 800.ms)
                                .slideY(begin: 0.3),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.appBlue,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.appBlue.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Text(
                                isAr
                                    ? "مطور تطبيقات الموبايل"
                                    : " Flutter Developer",
                                style:
                                    (isAr
                                    ? GoogleFonts.cairo
                                    : GoogleFonts.poppins)(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.0,
                                    ),
                              ),
                            ).animate().fadeIn(delay: 400.ms).scale(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // About Section - Clean & Minimal
                      _buildSectionHeader(
                        isAr ? "عن المطور" : "About Me",
                        isAr,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isAr
                            ? "أنا مطور تطبيقات فلاتر (Flutter Developer) متخصص في بناء تطبيقات موبايل عالية الأداء وذات تصميمات بصرية جذابة. أمتلك خبرة واسعة في تطوير حلول برمجية متكاملة تجمع بين سلاسة تجربة المستخدم وقوة الأنظمة البرمجية. أتخصص في استخدام أحدث تقنيات إدارة الحالة (Bloc/Cubit) وهيكلة الكود النظيف (Clean Architecture)، مع التركيز الدائم على تقديم برمجيات قابلة للتوسع والتطوير. هذا التطبيق هو نتاج شغفي بالتميز والتزامي بتقديم تجارب رقمية تترك أثراً حقيقياً."
                            : "I am a professional Flutter Developer dedicated to crafting high-performance, visually stunning mobile applications. I specialize in building cross-platform solutions that combine seamless user experiences with robust backend integration. With expertise in state management (Bloc/Cubit), Clean Architecture, and performance optimization, I focus on delivering scalable and maintainable code. This application is a testament to my commitment to quality and digital excellence.",
                        style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                          fontSize: 16,
                          height: 1.8,
                          color: const Color(0xFF334155),
                        ),
                      ).animate().fadeIn(delay: 600.ms),

                      const SizedBox(height: 40),

                      // Professional Social Grid
                      _buildSectionHeader(
                        isAr ? "تواصل معي" : "Connect with me",
                        isAr,
                      ),
                      const SizedBox(height: 20),

                      _buildSocialGrid(isAr),

                      const SizedBox(height: 32),

                      // Special Footer - Signature style
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isAr) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.appBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialGrid(bool isAr) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildProfessionalTile(
          imagePath: AppImages.whatsappLogo,
          label: isAr ? "واتساب" : "WhatsApp",
          color: const Color(0xFF25D366),
          onTap: () => _launchUrl("https://wa.me/201068643407"),
        ),
        _buildProfessionalTile(
          imagePath: AppImages.linkedinLogo,
          label: isAr ? "لينكد إن" : "LinkedIn",
          color: const Color(0xFF0077B5),
          onTap: () => _launchUrl(
            "https://www.linkedin.com/in/ali-abdelnaser-947230295/",
          ),
        ),
        _buildProfessionalTile(
          imagePath: AppImages.githubLogo,
          label: isAr ? "جيت هب" : "GitHub",
          color: const Color(0xFF181717),
          onTap: () => _launchUrl("https://github.com/Ali-Abdelnaser"),
        ),
        _buildProfessionalTile(
          imagePath: AppImages.facebookLogo,
          label: isAr ? "فيسبوك" : "Facebook",
          color: const Color(0xFF1877F2),
          onTap: () =>
              _launchUrl("https://www.facebook.com/ali.abdelnaser.349930"),
        ),
      ],
    );
  }

  Widget _buildProfessionalTile({
    required String imagePath,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                imagePath,
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(delay: 200.ms, duration: 400.ms);
  }
}
