import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../../../core/utils/app_images.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/glass_card.dart';

class MovementStageView extends StatefulWidget {
  final VoidCallback onComplete;

  const MovementStageView({super.key, required this.onComplete});

  @override
  State<MovementStageView> createState() => _MovementStageViewState();
}

class _MovementStageViewState extends State<MovementStageView> {
  int jumps = 0;
  final int targetJumps = 20;
  bool isJumping = false;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _startDetection();
  }

  void _startDetection() {
    _subscription = userAccelerometerEvents.listen((
      UserAccelerometerEvent event,
    ) {
      // Logic to detect a jump (spike in Y axis)
      // Usually when jumping, there's a quick up and down acceleration
      if (event.y.abs() > 12.0 && !isJumping) {
        if (mounted) {
          setState(() {
            jumps++;
            isJumping = true;
          });

          if (jumps >= targetJumps) {
            _onTargetReached();
          }

          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) setState(() => isJumping = false);
          });
        }
      }
    });
  }

  void _onTargetReached() {
    _subscription?.cancel();
    // Show confetti or success
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                Text(
                  'نتحرك سوا!',
                  style: GoogleFonts.cairo(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'نط في مكانك 20 نطة',
                  style: GoogleFonts.cairo(fontSize: 18, color: Colors.white70),
                ),

                const Spacer(),

                // Jump Animation/Icon
                Center(
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child:
                        Icon(
                              Icons.directions_run,
                              size: 100,
                              color: isJumping ? AppTheme.appRed : Colors.white,
                            )
                            .animate(target: isJumping ? 1 : 0)
                            .moveY(
                              begin: 0,
                              end: -50,
                              duration: 200.ms,
                              curve: Curves.easeOut,
                            )
                            .then()
                            .moveY(
                              begin: -50,
                              end: 0,
                              duration: 200.ms,
                              curve: Curves.easeIn,
                            ),
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Text(
                        '$jumps / $targetJumps',
                        style: GoogleFonts.cairo(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: jumps / targetJumps,
                          minHeight: 15,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.appRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (jumps >= targetJumps)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onComplete();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'تم المهمة!',
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ).animate().scale(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
