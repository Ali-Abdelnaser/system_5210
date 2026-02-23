import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/features/nutrition_scan/presentation/widgets/glass_container.dart';

class MatchingResultOverlay extends StatelessWidget {
  final int stars;
  final Duration duration;
  final int wrongAttempts;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  const MatchingResultOverlay({
    super.key,
    required this.stars,
    required this.duration,
    required this.wrongAttempts,
    required this.onRetry,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GlassContainer(
        blur: 25,
        opacity: 0.4,
        color: Colors.black,
        borderRadius: BorderRadius.zero,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Star Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final isFilled = index < stars;
                    return Icon(
                          isFilled
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: isFilled ? AppTheme.appYellow : Colors.white24,
                          size: 60,
                        )
                        .animate(delay: (300 * index).ms)
                        .scale(curve: Curves.elasticOut, duration: 800.ms);
                  }),
                ),

                const SizedBox(height: 10),

                // Character Image - Premium Addition
                Image.asset(
                  AppImages.gameSuccess1,
                  height: 180,
                ).animate().slideY(
                  begin: 1.0,
                  end: 0,
                  curve: Curves.easeOutBack,
                  duration: 800.ms,
                ),

                const SizedBox(height: 10),

                Text(
                  'بطل المعرفة الصحية',
                  style: GoogleFonts.cairo(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      const Shadow(
                        color: Colors.black45,
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                ).animate().scale(curve: Curves.easeOutBack),

                const SizedBox(height: 30),

                // Stats Row with Cards
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.timer_outlined,
                        label: 'الوقت المستغرق',
                        value: '${duration.inSeconds} ثانية',
                        color: AppTheme.appBlue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.error_outline_rounded,
                        label: 'عدد الأخطاء',
                        value: '$wrongAttempts',
                        color: AppTheme.appRed,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 40),

                // Actions
                Column(
                  children: [
                    _buildActionButton(
                      label: 'العب مرة تانية',
                      icon: Icons.replay_rounded,
                      color: AppTheme.appBlue,
                      onPressed: onRetry,
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      label: 'خروج من اللعبة',
                      icon: Icons.exit_to_app_rounded,
                      color: Colors.white.withOpacity(0.15),
                      isOutlined: true,
                      onPressed: onExit,
                    ),
                  ],
                ).animate().slideY(begin: 0.5, end: 0, delay: 1.seconds),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 260),
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 22),
        label: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : color,
          elevation: isOutlined ? 0 : 8,
          shadowColor: color.withOpacity(0.4),
          side: isOutlined
              ? BorderSide(color: Colors.white.withOpacity(0.4), width: 2)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
