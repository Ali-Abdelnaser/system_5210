import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/utils/app_tips_data.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import 'package:system_5210/core/services/local_storage_service.dart';
import 'package:system_5210/core/utils/injection_container.dart';
import 'package:flutter/services.dart';

class ChildDailyTipCard extends StatefulWidget {
  const ChildDailyTipCard({super.key});

  @override
  State<ChildDailyTipCard> createState() => _ChildDailyTipCardState();
}

class _ChildDailyTipCardState extends State<ChildDailyTipCard> {
  AppTip? _todayTip;
  String _character = AppImages.gameSuccess1;
  bool _isDone = false;
  final String _boxName = 'child_tips_storage';

  @override
  void initState() {
    super.initState();
    _loadTodayTip();
  }

  Future<void> _loadTodayTip() async {
    final storage = sl<LocalStorageService>();
    final today = DateTime.now().toIso8601String().split('T')[0];

    final tipData = await storage.get(_boxName, 'daily_tip');
    int tipIndex;

    if (tipData != null && tipData['date'] == today) {
      tipIndex = tipData['index'] ?? 0;
      _isDone = tipData['isDone'] ?? false;
    } else {
      tipIndex = Random().nextInt(AppTipsData.childTips.length);
      await storage.save(_boxName, 'daily_tip', {
        'date': today,
        'index': tipIndex,
        'isDone': false,
      });
      _isDone = false;
    }

    setState(() {
      _todayTip = AppTipsData.childTips[tipIndex];
      final charList = [
        AppImages.gameSuccess1,
        AppImages.gameSuccess2,
        AppImages.gameSuccess3,
        AppImages.gameSuccess4,
      ];
      _character = charList[tipIndex % charList.length];
    });
  }

  Future<void> _markAsDone() async {
    final storage = sl<LocalStorageService>();
    final tipData = await storage.get(_boxName, 'daily_tip');

    if (tipData != null) {
      await HapticFeedback.mediumImpact();
      await storage.save(_boxName, 'daily_tip', {...tipData, 'isDone': true});
    }

    setState(() {
      _isDone = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_todayTip == null) return const SizedBox.shrink();

    // Select a theme color based on the tip index to rotate through 5210 colors
    final themeColors = [
      AppTheme.appBlue,
      AppTheme.appGreen,
      AppTheme.appRed,
      AppTheme.appYellow,
    ];
    final colorIndex =
        max(0, AppTipsData.childTips.indexOf(_todayTip!)) % themeColors.length;
    final primaryColor = themeColors[colorIndex];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Bubble Section
              Expanded(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Speech Bubble Container
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.2),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _todayTip!.title,
                                style: GoogleFonts.dynaPuff(
                                  color: primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _todayTip!.description,
                                style: GoogleFonts.cairo(
                                  color: const Color(0xFF2D3142),
                                  fontSize: 13,
                                  height: 1.3,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (!_isDone) ...[
                                const SizedBox(height: 12),
                                InkWell(
                                  onTap: _markAsDone,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.done_all_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "نفذت المهمة! 🫡",
                                          style: GoogleFonts.cairo(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ] else ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: AppTheme.appGreen,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "بطل حقيقي! 🏆",
                                      style: GoogleFonts.cairo(
                                        color: AppTheme.appGreen,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ).animate().scale(
                                  duration: 400.ms,
                                  curve: Curves.bounceOut,
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Bubble Tail
                        Positioned(
                          bottom: 20,
                          left: -12,
                          child: CustomPaint(
                            painter: BubbleTailPainter(
                              color: Colors.white,
                              borderColor: primaryColor.withOpacity(0.2),
                            ),
                            size: const Size(15, 15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ), // Padding to align with character base
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Character Section
              SizedBox(
                width: 100,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                        borderRadius: const BorderRadius.all(
                          Radius.elliptical(60, 20),
                        ),
                      ),
                    ),
                    Image.asset(_character, height: 130)
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .moveY(
                          begin: -5,
                          end: 5,
                          duration: 2.seconds,
                          curve: Curves.easeInOut,
                        ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BubbleTailPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  BubbleTailPainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, size.height / 2)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
