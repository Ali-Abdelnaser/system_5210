import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/features/nutrition_scan/presentation/widgets/glass_container.dart';

class GameHistoryItem extends StatelessWidget {
  final dynamic result;

  const GameHistoryItem({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final date = intl.DateFormat(
      'yyyy/MM/dd - hh:mm a',
      'ar',
    ).format(result.playedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        blur: 15,
        opacity: 0.6,
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status Indicator
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color:
                      (result.isBalanced ? AppTheme.appGreen : AppTheme.appRed)
                          .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  result.isBalanced
                      ? Icons.done_all_rounded
                      : Icons.close_rounded,
                  color: result.isBalanced
                      ? AppTheme.appGreen
                      : AppTheme.appRed,
                ),
              ),

              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.isBalanced ? 'طبق متوازن' : 'طبق غير متوازن',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3142),
                      ),
                    ),
                    Text(
                      date,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),

              // Stars
              Row(
                children: List.generate(3, (index) {
                  return Icon(
                    index < result.stars
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: index < result.stars
                        ? AppTheme.appYellow
                        : Colors.black12,
                    size: 18,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.05, end: 0);
  }
}
