import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/features/nutrition_scan/presentation/widgets/glass_container.dart';

class GameFeedbackOverlay extends StatelessWidget {
  final String message;
  final bool isHealthy;

  const GameFeedbackOverlay({
    super.key,
    required this.message,
    required this.isHealthy,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
          blur: 15,
          opacity: 0.85,
          color: isHealthy ? AppTheme.appGreen : AppTheme.appRed,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (isHealthy ? AppTheme.appGreen : AppTheme.appRed)
                .withOpacity(0.4),
            width: 2,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isHealthy ? Icons.auto_awesome : Icons.info_outline_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(key: ValueKey(message))
        .slideY(begin: -0.3, end: 0, curve: Curves.easeOutBack)
        .fadeIn()
        .then(delay: 2.seconds)
        .fadeOut();
  }
}
