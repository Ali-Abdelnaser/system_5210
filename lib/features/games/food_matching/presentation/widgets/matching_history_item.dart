import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/features/nutrition_scan/presentation/widgets/glass_container.dart';
import 'package:system_5210/features/games/balanced_diet/data/models/game_result_model.dart';

class MatchingHistoryItem extends StatelessWidget {
  final GameResultModel result;

  const MatchingHistoryItem({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final date = intl.DateFormat(
      'yyyy/MM/dd - hh:mm a',
      'ar',
    ).format(result.playedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: GlassContainer(
        blur: 20,
        opacity: 0.7,
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.appBlue.withOpacity(0.15),
          width: 1.5,
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              // Icon Indicator
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.appBlue.withOpacity(0.2),
                      AppTheme.appBlue.withOpacity(0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_fix_high_rounded,
                  color: AppTheme.appBlue,
                  size: 26,
                ),
              ),

              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ذكاء توصيل عالي',
                      style: GoogleFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),

              // Stars
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.appYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: List.generate(3, (index) {
                    final isFilled = index < result.stars;
                    return Icon(
                      isFilled
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: isFilled ? AppTheme.appYellow : Colors.black12,
                      size: 18,
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}
