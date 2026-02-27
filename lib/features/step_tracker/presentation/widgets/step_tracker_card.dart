import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/features/daily_tasks_game/presentation/widgets/glass_card.dart';
import 'package:system_5210/features/profile/presentation/manager/profile_cubit.dart';
import 'package:system_5210/features/profile/presentation/manager/profile_state.dart';
import 'package:system_5210/features/step_tracker/presentation/manager/step_tracker_cubit.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

class StepTrackerCard extends StatelessWidget {
  final int targetSteps;

  const StepTrackerCard({super.key, this.targetSteps = 10000});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, profileState) {
        return BlocBuilder<StepTrackerCubit, StepTrackerState>(
          builder: (context, stepState) {
            if (stepState is StepTrackerPermissionDenied) {
              return _buildPermissionDeniedCard(context);
            }

            int steps = 0;
            if (stepState is StepTrackerLoaded) {
              steps = stepState.steps;
            }

            double height = 120.0;
            double weight = 25.0;

            if (profileState is ProfileLoaded) {
              final quiz = profileState.profile.quizAnswers;
              height =
                  double.tryParse(quiz['height']?.toString() ?? '120.0') ??
                  120.0;
              weight =
                  double.tryParse(quiz['weight']?.toString() ?? '25.0') ?? 25.0;
            }

            final strideLengthCm = height * 0.413;
            final distanceKm = (steps * strideLengthCm) / 100000;
            final calories = weight * distanceKm * 0.75;
            final activeMinutes = (steps / 100).round();

            final isAr = Localizations.localeOf(context).languageCode == 'ar';
            final progress = (steps / targetSteps).clamp(0.001, 1.0);

            // Hero Status Logic
            String status = isAr ? "بطل صاعد" : "Rising Hero";
            Color statusColor = AppTheme.appBlue;
            if (steps >= targetSteps) {
              status = isAr ? "بطل متميز" : "Legendary Hero";
              statusColor = const Color(0xFFFFD700);
            } else if (steps > 5000) {
              status = isAr ? "بطل نشيط" : "Active Hero";
              statusColor = const Color(0xFF2ECC71);
            }

            return GlassCard(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              padding: const EdgeInsets.all(24),
              opacity: 0.7, // High enough to see the tint clearly on white
              blur: 25,
              borderRadius: 35,
              color: const Color(0xFFEBF5FF), // Beautiful Ice Blue Tint
              border: Border.all(
                color: AppTheme.appBlue.withOpacity(0.15),
                width: 1.5,
              ),
              child: Column(
                children: [
                  // 1. Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.appBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.flash_on_rounded,
                              color: AppTheme.appBlue,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isAr ? "نشاط اليوم" : "Today's Energy",
                              style:
                                  (isAr
                                  ? GoogleFonts.cairo
                                  : GoogleFonts.poppins)(
                                    color: AppTheme.appBlue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        status,
                        style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // 2. Main Stats Section
                  Row(
                    children: [
                      // Circular Progress with Gradient
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.appBlue.withOpacity(0.1),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: CustomPaint(
                              painter: _ModernRingPainter(
                                progress: progress,
                                color: AppTheme.appBlue,
                                backgroundColor: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                          Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    (progress * 100).toInt().toString(),
                                    style: GoogleFonts.dynaPuff(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.appBlue,
                                    ),
                                  ),
                                  Text(
                                    "%",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.appBlue.withOpacity(0.5),
                                      height: 0.8,
                                    ),
                                  ),
                                ],
                              )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .shimmer(duration: 3.seconds),
                        ],
                      ),

                      const SizedBox(width: 75),

                      // Step Count Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              steps.toString(),
                              style: GoogleFonts.dynaPuff(
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                color: const Color(
                                  0xFF0F172A,
                                ), // Dark Navy for contrast
                                height: 1.1,
                              ),
                            ),
                            Text(
                              isAr ? 'خطوة بطل' : 'Hero Steps',
                              style:
                                  (isAr
                                  ? GoogleFonts.cairo
                                  : GoogleFonts.poppins)(
                                    fontSize: 14,
                                    color: Colors.black45,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            // Small Progress Indicator Line
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FractionallySizedBox(
                                widthFactor: progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.appBlue,
                                        AppTheme.appBlue.withOpacity(0.6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // 3. Bento Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickStat(
                        icon: Icons.local_fire_department_rounded,
                        color: const Color(0xFFFF5F5F),
                        value: calories.toStringAsFixed(0),
                        unit: isAr ? 'سعرة' : 'kcal',
                        isAr: isAr,
                      ),
                      _buildQuickStat(
                        icon: Icons.directions_run_rounded,
                        color: const Color(0xFF2ECC71),
                        value: distanceKm.toStringAsFixed(1),
                        unit: isAr ? 'كم' : 'km',
                        isAr: isAr,
                      ),
                      _buildQuickStat(
                        icon: Icons.timer_rounded,
                        color: const Color(0xFF8B5CF6),
                        value: activeMinutes.toString(),
                        unit: isAr ? 'دق' : 'min',
                        isAr: isAr,
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
          },
        );
      },
    );
  }

  Widget _buildPermissionDeniedCard(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(24),
      opacity: 0.7,
      blur: 25,
      borderRadius: 35,
      color: const Color.fromARGB(255, 255, 255, 255), // Subtle Red Tint
      child: Column(
        children: [
          const Icon(
            Icons.lock_person_rounded,
            color: Colors.redAccent,
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            isAr ? "تحتاج لصلاحية تتبع النشاط" : "Activity Tracking Required",
            style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isAr
                ? "من فضلك فعل صلاحية تتبع النشاط من إعدادات الهاتف لمتابعة خطواتك"
                : "Please enable activity tracking permission in settings to track your steps",
            textAlign: TextAlign.center,
            style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => openAppSettings(),
            icon: const Icon(Icons.settings_rounded, size: 18),
            label: Text(isAr ? "إفتح الإعدادات" : "Open Settings"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.appBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required Color color,
    required String value,
    required String unit,
    required bool isAr,
  }) {
    return Container(
      width: 95,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1E293B),
            ),
          ),
          Text(
            unit,
            style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _ModernRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - 8;

    // Background Shadow Path
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      2 * math.pi,
      false,
      bgPaint,
    );

    // Progress Path with Shimmer Gradient
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [color.withOpacity(0.4), color, color.withOpacity(0.8)],
        stops: const [0, 0.7, 1],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );

    // Endpoint Glow
    if (progress > 0) {
      final endAngle = -math.pi / 2 + 2 * math.pi * progress;
      final endPoint = Offset(
        center.dx + radius * math.cos(endAngle),
        center.dy + radius * math.sin(endAngle),
      );
      final glowPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(endPoint, 5, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ModernRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
