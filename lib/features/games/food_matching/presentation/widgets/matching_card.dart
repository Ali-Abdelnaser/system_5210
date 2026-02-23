import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/features/nutrition_scan/presentation/widgets/glass_container.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/features/games/balanced_diet/domain/entities/ingredient_entity.dart';

class MatchingCard extends StatelessWidget {
  final IngredientEntity item;
  final bool isImage;
  final bool isMatched;
  final bool isSelected;

  const MatchingCard({
    super.key,
    required this.item,
    required this.isImage,
    required this.isMatched,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
          duration: 400.ms,
          curve: Curves.easeOutQuart,
          width: isImage ? 115 : 160, // Wider for benefits
          height: 100, // Taller cards for text wrap
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: isMatched
                  ? [
                      AppTheme.appGreen.withOpacity(0.5),
                      AppTheme.appGreen.withOpacity(0.2),
                    ]
                  : isSelected
                  ? [
                      AppTheme.appBlue.withOpacity(0.5),
                      AppTheme.appBlue.withOpacity(0.2),
                    ]
                  : [
                      const Color(0xFF1E293B).withOpacity(0.12), // Darker base
                      const Color(0xFF1E293B).withOpacity(0.06),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              if (isSelected || isMatched)
                BoxShadow(
                  color: (isMatched ? AppTheme.appGreen : AppTheme.appBlue)
                      .withOpacity(0.25),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isMatched
                  ? AppTheme.appGreen.withOpacity(0.8)
                  : isSelected
                  ? AppTheme.appBlue
                  : const Color(0xFF1E293B).withOpacity(0.2),
              width: isSelected || isMatched ? 2.5 : 1.5,
            ),
          ),
          child: GlassContainer(
            blur: 15,
            opacity: 0,
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Center(
                  child: isImage
                      ? Padding(
                          padding: const EdgeInsets.all(
                            8.0,
                          ), // Slightly more padding
                          child:
                              Image.asset(item.imagePath, fit: BoxFit.contain)
                                  .animate(target: isMatched ? 1 : 0)
                                  .scale(
                                    begin: const Offset(1, 1),
                                    end: const Offset(1.15, 1.15),
                                    duration: 400.ms,
                                    curve: Curves.easeOutBack,
                                  ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(
                            item.benefit, // Use benefit instead of name
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 13, // Slightly smaller for longer text
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                              color: isMatched
                                  ? const Color(0xFF064E3B)
                                  : isSelected
                                  ? const Color(0xFF1E3A8A)
                                  : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                ),
                if (isMatched)
                  Positioned(
                    top: 8,
                    right: 8,
                    child:
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.appGreen,
                          size: 20,
                        ).animate().scale(
                          curve: Curves.elasticOut,
                          duration: 600.ms,
                        ),
                  ),
              ],
            ),
          ),
        )
        .animate(target: isMatched ? 1 : 0)
        .shimmer(
          duration: 1.5.seconds,
          color: Colors.white30,
          delay: isMatched ? 0.ms : 2.seconds,
        );
  }
}
