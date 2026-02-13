import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/theme/app_theme.dart';

class GameProgressBar extends StatelessWidget {
  final int currentCount;
  final int maxCount;

  const GameProgressBar({
    super.key,
    required this.currentCount,
    this.maxCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المهمة: املأ الطبق بالكنوز',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: const Color(0xFF475569),
                ),
              ),
              Text(
                '$currentCount / $maxCount',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: AppTheme.appBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedContainer(
                    duration: 400.ms,
                    height: 10,
                    width: constraints.maxWidth * (currentCount / maxCount),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.appBlue,
                          AppTheme.appBlue.withOpacity(0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.appBlue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ).animate(target: currentCount == maxCount ? 1 : 0).shimmer();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
