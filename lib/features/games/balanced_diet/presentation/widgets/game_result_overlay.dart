import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/features/nutrition_scan/presentation/widgets/glass_container.dart';

class GameResultOverlay extends StatelessWidget {
  final bool isBalanced;
  final int stars;
  final String characterImagePath;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  const GameResultOverlay({
    super.key,
    required this.isBalanced,
    required this.stars,
    required this.characterImagePath,
    required this.onRetry,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GlassContainer(
        blur: 20,
        opacity: 0.3,
        color: Colors.black,
        borderRadius: BorderRadius.zero,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Content Layer (Bottom)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Star System
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final isFilled = index < stars;
                        return Icon(
                              isFilled
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: isFilled
                                  ? AppTheme.appYellow
                                  : Colors.white24,
                              size: 60,
                            )
                            .animate(delay: (400 * index).ms)
                            .scale(curve: Curves.easeOutBack)
                            .shimmer(delay: 1.seconds);
                      }),
                    ),

                    const SizedBox(height: 20),

                    // Character Image
                    Image.asset(
                      characterImagePath,
                      height: 250,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.emoji_events,
                        size: 100,
                        color: Colors.white,
                      ),
                    ).animate().slideY(
                      begin: 1.0,
                      end: 0,
                      curve: Curves.elasticOut,
                      duration: 800.ms,
                    ),

                    const SizedBox(height: 10),

                    // Result Text
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (isBalanced
                                        ? AppTheme.appGreen
                                        : AppTheme.appRed)
                                    .withOpacity(0.4),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            stars == 3
                                ? '🏆 طبق مثالي'
                                : stars == 2
                                ? '⭐ طبق رائع'
                                : stars == 1
                                ? '👍 بداية جيدة'
                                : '🔄 محاولة تانية',
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: GoogleFonts.cairo(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: isBalanced
                                  ? AppTheme.appGreen
                                  : AppTheme.appRed,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            stars == 3
                                ? 'قدرت تختار 5 أصناف صحية بذكاء'
                                : stars == 2
                                ? 'اخترت 4 أصناف صحية، قربت من الدرجة النهائية'
                                : stars == 1
                                ? 'طبقك فيه 3 أصناف صحية، تقدر تحسن النتيجة'
                                : 'طبقك محتاج أصناف صحية أكتر عشان تفوز',
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ).animate().scale(delay: 500.ms, curve: Curves.easeOutBack),

                    const SizedBox(height: 40),

                    // Action Buttons
                    Column(
                          children: [
                            SizedBox(
                              width: 220,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: onRetry,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isBalanced
                                      ? AppTheme.appGreen
                                      : AppTheme.appYellow,
                                  elevation: 10,
                                  shadowColor:
                                      (isBalanced
                                              ? AppTheme.appGreen
                                              : AppTheme.appYellow)
                                          .withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  ' العب تاني',
                                  style: GoogleFonts.cairo(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            SizedBox(
                              width: 220,
                              height: 55,
                              child: OutlinedButton(
                                onPressed: onExit,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Colors.white70,
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  ' خروج',
                                  style: GoogleFonts.cairo(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(delay: 800.ms)
                        .slideY(begin: 0.5, end: 0),
                  ],
                ),
              ),
            ),

            // 2. Celebration Overlay Layer (Top)
            if (isBalanced)
              IgnorePointer(
                child: Stack(
                  children: [
                    // Left Cannon Burst
                    ...List.generate(
                      40,
                      (index) => _buildConfetti(context, index, true),
                    ),
                    // Right Cannon Burst
                    ...List.generate(
                      40,
                      (index) => _buildConfetti(context, index, false),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfetti(BuildContext context, int index, bool isLeft) {
    final random = math.Random(index + (isLeft ? 0 : 1000));
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Trajectory settings
    final angle = isLeft
        ? (math.pi / 4) +
              (random.nextDouble() * math.pi / 4) // 45 to 90 degrees
        : (3 * math.pi / 4) +
              (random.nextDouble() * math.pi / 4); // 135 to 180 degrees

    final velocity = 600.0 + random.nextDouble() * 500.0;
    final duration = 1500.ms + (random.nextInt(1000)).ms;

    // Calculate burst path
    final endX = velocity * math.cos(angle);
    final endY = -velocity * math.sin(angle);

    return Positioned(
      bottom: -20,
      left: isLeft ? -20 : null,
      right: !isLeft ? -20 : null,
      child:
          Transform.rotate(
                angle: random.nextDouble() * 2 * math.pi,
                child: Icon(
                  [
                    Icons.star_rounded,
                    Icons.favorite_rounded,
                    Icons.auto_awesome,
                    Icons.circle,
                    Icons.celebration_rounded,
                    Icons.flash_on_rounded,
                  ][random.nextInt(6)],
                  color: [
                    Colors.yellowAccent,
                    Colors.pinkAccent,
                    Colors.cyanAccent,
                    Colors.lightGreenAccent,
                    Colors.orangeAccent,
                    Colors.purpleAccent,
                    Colors.white,
                  ][random.nextInt(7)],
                  size: 10.0 + random.nextDouble() * 20.0,
                ),
              )
              .animate(delay: (index * 15).ms)
              .move(
                begin: Offset.zero,
                end: Offset(endX, endY),
                duration: 800.ms,
                curve: Curves.easeOutCubic,
              )
              .then()
              .moveY(
                end: screenHeight,
                duration: 2.seconds,
                curve: Curves.easeInQuad,
              )
              .rotate(end: 2, duration: 3.seconds)
              .fadeOut(duration: 1.seconds),
    );
  }
}
