import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/l10n/app_localizations.dart';

class InsightPromoBanner extends StatelessWidget {
  final VoidCallback onTap;

  const InsightPromoBanner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 160,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. The Glassmorphic White Base
          Container(
            height: 125,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.appBlue.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: AppTheme.appBlue.withOpacity(0.05),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Stack(
                children: [
                  // Decorative accents
                  Positioned(
                    right: isAr ? null : -20,
                    left: isAr ? -20 : null,
                    top: -20,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.appBlue.withOpacity(0.04),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. The Yellow Character (Girl) Pop-out
          Positioned(
            right: isAr ? null : 15,
            left: isAr ? 15 : null,
            bottom: 0,
            child:
                Image.asset(
                      AppImages
                          .gameSuccess3, // Matches "The girl in yellow" description
                      height: 155,
                      fit: BoxFit.contain,
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .slideY(
                      begin: 0.05,
                      end: -0.05,
                      duration: 2.seconds,
                      curve: Curves.easeInOut,
                    ),
          ),

          // 3. Content Area with Locale Alignment
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: 125,
                padding: EdgeInsetsDirectional.only(
                  start: 24,
                  end: 140, // Space for the character
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.appBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.lightbulb_rounded,
                            color: AppTheme.appBlue,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.didYouKnow,
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.appBlue,
                            ),
                          ),
                        ],
                      ),
                    ).animate().shimmer(duration: 3.seconds),

                    const SizedBox(height: 8),

                    Text(
                      l10n.healthyInsightsTitle,
                      style: GoogleFonts.cairo(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E293B),
                        height: 1.1,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      l10n.healthyInsightsSubTitle,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Floating Action Button Style
          Positioned(
            left: isAr ? 20 : null,
            right: isAr ? null : 20,
            top: 50,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05))],
              ),
              child: Icon(
                isAr
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.arrow_forward_ios_rounded,
                color: AppTheme.appBlue,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.1, end: 0);
  }
}
