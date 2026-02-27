import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:system_5210/core/utils/app_routes.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/services/permission_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:system_5210/features/home/presentation/manager/home_cubit.dart';
import 'package:system_5210/features/healthy_recipes/presentation/manager/recipe_cubit.dart';
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

  // Animation for each layer
  late Animation<double> _bgFadeAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _logoScaleAnimation;

  static const int _splashDurationInSeconds = 5;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _splashDurationInSeconds),
    );

    // 1. Background Fade-In (Starts after a small delay to match native logo)
    _bgFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.45, curve: Curves.easeIn),
    );

    // 2. Content (Text & Loader) Fade-In
    _contentFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.40, 0.70, curve: Curves.easeIn),
    );

    // 3. Subtle Logo Breathing (Starts after background is visible)
    _logoScaleAnimation = TweenSequence([
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 40),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.05,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.05,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_controller);

    // 4. Loader Rotation (Premium dynamic rotation)
    _rotationAnimation = Tween<double>(begin: 0, end: 3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    PermissionService.requestInitialPermissions();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Trigger pre-fetching while animation plays
      di.sl<HomeCubit>().loadUserProfile();
      di.sl<RecipeCubit>().getRecipes();
    }
    // ----------------------------

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
    final localStorage = di.sl<LocalStorageService>();
    final settings = await localStorage.get('settings', 'language');
    final bool hasLanguage = settings != null;

    if (!mounted) return;

    String nextRoute;
    if (!hasLanguage) {
      nextRoute = AppRoutes.language;
    } else {
      final user = FirebaseAuth.instance.currentUser;
      nextRoute = (user != null) ? AppRoutes.home : AppRoutes.onboarding;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, anim, secAnim) {
          final route = AppRoutes.onGenerateRoute(
            RouteSettings(name: nextRoute),
          );
          return (route is MaterialPageRoute)
              ? route.builder(context)
              : const Scaffold();
        },
        transitionsBuilder: (context, anim, secAnim, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 1000),
      ),
    );
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
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: FadeTransition(
              opacity: _bgFadeAnimation,
              child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
            ),
          ),

          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                FadeTransition(
                  opacity: _contentFadeAnimation,
                  child: RotationTransition(
                    turns: _rotationAnimation,
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: CustomPaint(
                        painter: LoadingArcPainter(
                          colors: [
                            AppTheme.appBlue.withOpacity(0.0),
                            AppTheme.appBlue.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                ScaleTransition(
                  scale: _logoScaleAnimation,
                  child: Image.asset(AppImages.logo, width: 180, height: 180),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 250,
            child: FadeTransition(
              opacity: _contentFadeAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '5210EG',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                      color: AppTheme.appBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 1.5,
                    width: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.appBlue.withOpacity(0),
                          AppTheme.appBlue.withOpacity(0.5),
                          AppTheme.appBlue.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'HEALTHY HABITS FOR FAMILIES',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.5,
                      color: AppTheme.appBlue.withOpacity(0.5),
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

class LoadingArcPainter extends CustomPainter {
  final List<Color> colors;
  LoadingArcPainter({required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 1. Subtle Glow Background Arc
    final shadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..color = colors.last.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawArc(rect, 0.5, 1.8, false, shadowPaint);

    // 2. Main Gradient Arc
    final paint = Paint()
      ..shader = SweepGradient(
        colors: colors,
        stops: const [0.0, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0.5, 1.8, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
