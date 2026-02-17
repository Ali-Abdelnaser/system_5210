import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/features/onboarding/data/models/onboarding_model.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_routes.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final List<OnboardingModel> screens = [
      OnboardingModel(
        title: l10n.onboardingTitle5,
        description: l10n.onboardingDesc5,
        image: AppImages.img5,
        color: AppTheme.appRed,
      ),
      OnboardingModel(
        title: l10n.onboardingTitle2,
        description: l10n.onboardingDesc2,
        image: AppImages.img2,
        color: AppTheme.appYellow,
      ),
      OnboardingModel(
        title: l10n.onboardingTitle1,
        description: l10n.onboardingDesc1,
        image: AppImages.img1,
        color: AppTheme.appGreen,
      ),
      OnboardingModel(
        title: l10n.onboardingTitle0,
        description: l10n.onboardingDesc0,
        image: AppImages.img0,
        color: AppTheme.appBlue,
      ),
    ];

    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.height < 700;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              color: screens[_currentPage].color.withOpacity(0.05),
            ),
            child: Stack(
              children: [
                ...List.generate(
                  6,
                  (index) =>
                      _buildFloatingBubble(index, screens[_currentPage].color),
                ),
              ],
            ),
          ),

          // 3. محتوى الصفحات
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: screens.length,
            itemBuilder: (context, index) {
              final item = screens[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: isSmallScreen ? 40 : 20),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                              width: isSmallScreen ? 200 : 300,
                              height: isSmallScreen ? 200 : 300,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: item.color.withOpacity(0.15),
                              ),
                            )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(
                              begin: const Offset(0.8, 0.8),
                              end: const Offset(1.1, 1.1),
                              duration: 2.seconds,
                            ),

                        Image.asset(
                              item.image,
                              height: isSmallScreen ? size.height * 0.35 : 450,
                              fit: BoxFit.contain,
                            )
                            .animate(key: ValueKey(index))
                            .slideY(
                              begin: 0.1,
                              end: 0,
                              duration: 800.ms,
                              curve: Curves.easeOutBack,
                            )
                            .fadeIn(duration: 800.ms),
                      ],
                    ),

                    SizedBox(height: isSmallScreen ? 20 : 10),

                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: isSmallScreen ? 24 : 32,
                        fontWeight: FontWeight.w900,
                        color: item.color,
                      ),
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 15),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        item.description,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: isSmallScreen ? 16 : 20,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ).animate().fadeIn(delay: 500.ms),
                    SizedBox(height: isSmallScreen ? 100 : 80),
                  ],
                ),
              );
            },
          ),

          // 4. أزرار التحكم والـ Indicator
          Positioned(
            bottom: 40,
            left: 25,
            right: 25,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, AppRoutes.login),
                  child: Text(
                    l10n.skip,
                    style: GoogleFonts.cairo(
                      color: Colors.grey[600],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Row(
                  children: List.generate(
                    screens.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 12,
                      width: _currentPage == index ? 30 : 12,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? screens[index].color
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    if (_currentPage < screens.length - 1) {
                      _pageController.nextPage(
                        duration: 600.ms,
                        curve: Curves.easeInOut,
                      );
                    } else {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: screens[_currentPage].color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: screens[_currentPage].color.withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      _currentPage == screens.length - 1
                          ? Icons.done_all
                          : (Localizations.localeOf(context).languageCode ==
                                    'ar'
                                ? Icons.arrow_back_ios_new_rounded
                                : Icons.arrow_forward_ios_rounded),
                      color: Colors.white,
                      size: 28,
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

  Widget _buildFloatingBubble(int index, Color color) {
    final List<Alignment> alignments = [
      Alignment.topLeft,
      Alignment.topRight,
      Alignment.bottomLeft,
      Alignment.centerLeft,
      Alignment.centerRight,
      Alignment.topCenter,
    ];
    return Align(
      alignment: alignments[index % alignments.length],
      child:
          Container(
                width: 100 + (index * 20),
                height: 100 + (index * 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.05),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .move(
                begin: const Offset(-20, -20),
                end: const Offset(20, 20),
                duration: (3 + index).seconds,
                curve: Curves.easeInOut,
              )
              .scale(
                begin: const Offset(0.9, 0.9),
                end: const Offset(1.1, 1.1),
              ),
    );
  }
}
