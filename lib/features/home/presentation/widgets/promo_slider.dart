import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/l10n/app_localizations.dart';

class PromoSlider extends StatelessWidget {
  const PromoSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final List<Map<String, dynamic>> slides = [
      {
        "text": l10n.promoTip1,
        "color": const Color(0xFFFF5252),
        "textColor": Colors.white,
        "image": AppImages.character1, // Red/Health Hero
      },
      {
        "text": l10n.promoTip2,
        "color": const Color(0xFF4A90E2),
        "textColor": Colors.white,
        "image": AppImages.character3, // Blue/Water Hero
      },
      {
        "text": l10n.promoTip3,
        "color": const Color(0xFF66BB6A), // Green/Activity
        "textColor": Colors.white,
        "image": AppImages.character4,
      },
      {
        "text": l10n.promoTip4,
        "color": const Color(0xFF9C27B0), // Purple/Sleep
        "textColor": Colors.white,
        "image": AppImages.character2,
      },
      {
        "text": l10n.promoTip5,
        "color": const Color(0xFFFFB74D), // Orange/Teeth
        "textColor": Colors.white,
        "image": AppImages.character1,
      },
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 160,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9, // Wider card
        autoPlayInterval: const Duration(seconds: 5),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
      ),
      items: slides.map((slide) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    slide['color'],
                    (slide['color'] as Color).withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: (slide['color'] as Color).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias, // Ensures circles don't bleed out
              child: Stack(
                clipBehavior: Clip.antiAlias,
                children: [
                  // Decorative Circles (Background)
                  Positioned(
                    left: -20,
                    top: -20,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  Positioned(
                    right: -10,
                    bottom: -30,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.black.withOpacity(0.05),
                    ),
                  ),

                  // Content Row
                  Row(
                    children: [
                      // Text Section
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: 20,
                            top: 20,
                            bottom: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.stars_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      l10n.dailyTipTitle,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                slide['text'],
                                style: GoogleFonts.dynaPuff(
                                  fontSize: 14, // Slightly smaller for RTL fit
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 2,
                                      offset: const Offset(1, 1),
                                    ),
                                  ],
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Character Image Section
                      Expanded(
                        flex: 2,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              bottom: -10,
                              child:
                                  Image.asset(
                                        slide['image'],
                                        height: 140, // Nice large character
                                      )
                                      .animate(
                                        onPlay: (c) => c.repeat(reverse: true),
                                      )
                                      .scale(
                                        begin: const Offset(1, 1),
                                        end: const Offset(1.05, 1.05),
                                        duration: 1.5.seconds,
                                      )
                                      .slideY(
                                        begin: 0.05,
                                        end: 0,
                                        duration: 2.seconds,
                                      ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }
}
