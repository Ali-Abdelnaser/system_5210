import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/utils/app_tips_data.dart';
import 'package:system_5210/core/services/local_storage_service.dart';
import 'package:system_5210/core/utils/injection_container.dart';

class DailyTipOverlay extends StatefulWidget {
  final AppTip tip;
  final String character;

  const DailyTipOverlay({
    super.key,
    required this.tip,
    required this.character,
  });

  static bool _isShowing = false;

  static Future<void> showIfNeeded(BuildContext context, String role) async {
    if (role != 'child' || _isShowing) return;

    final storage = sl<LocalStorageService>();
    final today = DateTime.now().toIso8601String().split('T')[0];
    const boxName = 'child_tips_storage';
    const key = 'last_overlay_shown_date';

    final lastShownData = await storage.get(boxName, key);
    final lastShownDate = lastShownData?['date'];

    if (lastShownDate != today) {
      // Get today's tip (sync with ChildDailyTipCard if possible or just pick one)
      // For consistency, we can use the same logic as ChildDailyTipCard's _loadTodayTip
      final tipData = await storage.get(boxName, 'daily_tip');
      int tipIndex;

      if (tipData != null && tipData['date'] == today) {
        tipIndex = tipData['index'] ?? 0;
      } else {
        tipIndex = Random().nextInt(AppTipsData.childTips.length);
        await storage.save(boxName, 'daily_tip', {
          'date': today,
          'index': tipIndex,
          'isDone': false,
        });
      }

      final tip = AppTipsData.childTips[tipIndex];
      final charList = [
        AppImages.gameSuccess1,
        AppImages.gameSuccess2,
        AppImages.gameSuccess3,
        AppImages.gameSuccess4,
      ];
      final character = charList[tipIndex % charList.length];

      if (context.mounted) {
        await showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierLabel: '',
          barrierColor: Colors.black.withOpacity(0.5),
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, anim1, anim2) {
            return DailyTipOverlay(tip: tip, character: character);
          },
        );
        _isShowing = false;
        // Mark as shown for today
        await storage.save(boxName, key, {'date': today});
      }
    }
    _isShowing = false; // Just in case it wasn't shown
  }

  @override
  State<DailyTipOverlay> createState() => _DailyTipOverlayState();
}

class _DailyTipOverlayState extends State<DailyTipOverlay> {
  String _displayedText = "";
  bool _showButton = false;
  Timer? _typewriterTimer;
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTypewriter();
    _startButtonTimer();
  }

  void _startTypewriter() {
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 50), (
      timer,
    ) {
      if (_charIndex < widget.tip.description.length) {
        setState(() {
          _displayedText += widget.tip.description[_charIndex];
          _charIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startButtonTimer() {
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _showButton = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background Blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),

          // Content
          Directionality(
            textDirection: TextDirection.rtl,
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    bottom: 55,
                    left: -80,
                    child:
                        Image.asset(
                          widget.character,
                          height: MediaQuery.of(context).size.height * 0.5,
                        ).animate().slideY(
                          begin: 1.0,
                          end: 0,
                          duration: 800.ms,
                          curve: Curves.easeOutBack,
                        ),
                  ),

                  Positioned(
                    right: 50,
                    left: 50,
                    top: 70,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            // Bubble Image
                            Image.asset(
                              AppImages.speechBubble,
                              width: double.infinity,
                              fit: BoxFit.fill,
                              color: Colors.white, // In case it needs tinting
                            ).animate().scale(
                              delay: 600.ms,
                              duration: 400.ms,
                              curve: Curves.elasticOut,
                            ),

                            // Text inside bubble
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 30,
                                right: 60,
                                top: 60,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.tip.title,
                                    style: GoogleFonts.dynaPuff(
                                      color: AppTheme.appBlue,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    _displayedText,
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Continue Button
                  if (_showButton)
                    Positioned(
                      bottom: 40,
                      right: 30,
                      left: 30,
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.appBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 10,
                          ),
                          child: Text(
                            "فهمت يا بطل!",
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ).animate().fadeIn().scale(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
