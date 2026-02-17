import 'package:flutter/material.dart';

import 'package:system_5210/core/utils/app_routes.dart';
import 'dart:math' as math;
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/services/permission_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:system_5210/core/utils/injection_container.dart' as di;
import 'package:system_5210/core/services/local_storage_service.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  static bool _isFirstLaunch = true;
  late AnimationController _controller;
  late Animation<double> _radiusAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Total duration for the splash sequence
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    // Request multiple permissions at once
    PermissionService.requestInitialPermissions();

    // 1. Continuous Rotation
    _rotationAnimation = Tween<double>(begin: 0, end: 4).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.linear),
      ),
    );

    // 2. Radius Animation: Stay at full radius, then collapse at the end
    _radiusAnimation = TweenSequence([
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 80, // Orbiting normally for 80% of time
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20, // Collapse quickly in the last 20%
      ),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence([
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 85),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 15),
    ]).animate(_controller);

    if (!_isFirstLaunch) {
      _navigateNext();
      return;
    }
    _isFirstLaunch = false;

    _controller.forward();

    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        await _navigateNext();
      }
    });
  }

  Future<void> _navigateNext() async {
    // 1. Check Language
    final localStorage = di.sl<LocalStorageService>();
    final settings = await localStorage.get('settings', 'language');
    final bool hasLanguage = settings != null;

    if (!mounted) return;

    if (!hasLanguage) {
      Navigator.pushReplacementNamed(context, AppRoutes.language);
      return;
    }

    // 2. Check Auth
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // User is logged in, reload to get fresh token/claims if needed
      // await user.reload(); // Optional, but good practice
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      // User not logged in, go to Onboarding (which leads to Login)
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),

          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: CustomPaint(
                      painter: TrailPainter(
                        rotationProgress: _rotationAnimation.value,
                        radiusMultiplier: _radiusAnimation.value,
                        colors: [
                          AppTheme.appRed,
                          AppTheme.appYellow,
                          AppTheme.appGreen,
                          AppTheme.appBlue,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TrailPainter extends CustomPainter {
  final double rotationProgress;
  final double radiusMultiplier;
  final List<Color> colors;

  TrailPainter({
    required this.rotationProgress,
    required this.radiusMultiplier,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Base radius is size.width / 3, multiplied by our collapse factor
    final radius = (size.width / 3) * radiusMultiplier;

    // If radius is almost zero, draw a single merging dot at center
    if (radiusMultiplier < 0.1) {
      final mergePaint = Paint()
        ..color = colors[0].withOpacity(radiusMultiplier * 10);
      canvas.drawCircle(center, 14 * radiusMultiplier * 10, mergePaint);
      return;
    }

    for (int i = 0; i < 4; i++) {
      final double startAngle =
          (i * math.pi / 2) + (rotationProgress * 2 * math.pi);
      final rect = Rect.fromCircle(center: center, radius: radius);

      // Draw trails with shrinking width and opacity during collapse
      for (double j = 0; j < 1.0; j += 0.1) {
        final paint = Paint()
          ..color = colors[i].withOpacity(
            0.5 * (1 - j) * math.min(1.0, radiusMultiplier * 2),
          )
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 22 * (1 - j * 0.5) * (0.3 + 0.7 * radiusMultiplier);

        canvas.drawArc(rect, startAngle - (j * 0.8), 0.15, false, paint);
      }

      // Draw leading dot
      final dotPaint = Paint()..color = colors[i];
      final dotOffset = Offset(
        center.dx + radius * math.cos(startAngle),
        center.dy + radius * math.sin(startAngle),
      );
      canvas.drawCircle(
        dotOffset,
        14 * (0.4 + 0.6 * radiusMultiplier),
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant TrailPainter oldDelegate) => true;
}
