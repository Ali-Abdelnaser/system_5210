import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:system_5210/core/theme/app_theme.dart';

class ProceduralBackground extends StatefulWidget {
  final double parallaxOffset;
  const ProceduralBackground({super.key, this.parallaxOffset = 0});

  @override
  State<ProceduralBackground> createState() => _ProceduralBackgroundState();
}

class _ProceduralBackgroundState extends State<ProceduralBackground>
    with TickerProviderStateMixin {
  late AnimationController _drawController;
  late AnimationController _pulseController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();

    // Single master timeline that runs forever
    _drawController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12), // Each shape's full cycle
    )..repeat(); // Infinite loop

    // Breathing/pulsing effect
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Overall floating drift
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _drawController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _drawController,
        _pulseController,
        _floatController,
      ]),
      builder: (context, child) {
        return Stack(
          children: [
            // Layer 1: The Hand-Drawn Elements
            CustomPaint(
              painter: _MotionArtPainter(
                drawProgress: _drawController.value,
                pulseProgress: _pulseController.value,
                floatProgress: _floatController.value,
                parallax: widget.parallaxOffset,
                colors: [
                  AppTheme.appBlue,
                  AppTheme.appRed,
                  AppTheme.appYellow,
                  AppTheme.appGreen,
                ],
              ),
              size: Size.infinite,
            ),

            // Layer 2: Subtle Screen Blur for Content Clarity
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0.8, sigmaY: 0.8),
                child: Container(color: Colors.white.withValues(alpha: 0.10)),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MotionArtPainter extends CustomPainter {
  final double drawProgress;
  final double pulseProgress;
  final double floatProgress;
  final double parallax;
  final List<Color> colors;

  _MotionArtPainter({
    required this.drawProgress,
    required this.pulseProgress,
    required this.floatProgress,
    required this.parallax,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Top Left: The Spring Spiral (Blue) - Fluidity
    _drawElement(
      canvas,
      size,
      type: _ElementType.spiral,
      color: colors[0],
      origin: Offset(size.width * 0.12, size.height * 0.15),
      rotation: -0.4,
      scale: 0.8,
      seed: 1,
      staggerDelay: 0.0, // Starts immediately
    );

    // 2. Top Right: The Hand-Drawn Star (Yellow) - Talent/Shine
    _drawElement(
      canvas,
      size,
      type: _ElementType.star,
      color: colors[2], // Use Yellow
      origin: Offset(size.width * 0.85, size.height * 0.18),
      rotation: 0.3,
      scale: 1.1,
      seed: 2,
      staggerDelay: 0.25, // Quarter cycle offset
    );

    // 3. Middle Left: The ZigZag Wave (Red) - Energy
    _drawElement(
      canvas,
      size,
      type: _ElementType.zigzag,
      color: colors[1],
      origin: Offset(size.width * -0.05, size.height * 0.6),
      rotation: 1.2,
      scale: 1.0,
      seed: 3,
      staggerDelay: 0.6, // More than half cycle
    );

    // 4. Bottom Right: The Rounded Loop (Green) - Simplicity
    _drawElement(
      canvas,
      size,
      type: _ElementType.loop,
      color: colors[3],
      origin: Offset(size.width * 0.75, size.height * 0.85),
      rotation: -0.2,
      scale: 1.2,
      seed: 4,
      staggerDelay: 0.4, // Different offset
    );

    // 5. Extra small Stars for "dusting" effect
    _drawElement(
      canvas,
      size,
      type: _ElementType.star,
      color: colors[2],
      origin: Offset(size.width * 0.3, size.height * 0.8),
      scale: 0.4,
      rotation: 0.5,
      seed: 5,
      staggerDelay: 0.15, // Early in cycle
    );

    // 6. The Sparkle Cluster (Yellow/Orange)
    _drawElement(
      canvas,
      size,
      type: _ElementType.sparkle,
      color: colors[2], // Yellow
      origin: Offset(size.width * 0.2, size.height * 0.45),
      rotation: -0.1,
      scale: 0.9,
      seed: 6,
      staggerDelay: 0.75, // Late in cycle
    );

    // 7. The Floating Heart (Red/Pink)
    _drawElement(
      canvas,
      size,
      type: _ElementType.heart,
      color: colors[1], // Red
      origin: Offset(size.width * 0.88, size.height * 0.55),
      rotation: -0.2,
      scale: 1.0,
      seed: 7,
      staggerDelay: 0.5, // Exactly half cycle (opposite to first)
    );
  }

  void _drawElement(
    Canvas canvas,
    Size size, {
    required _ElementType type,
    required Color color,
    required Offset origin,
    required double rotation,
    required double scale,
    required int seed,
    required double staggerDelay,
  }) {
    canvas.save();

    // Calculate independent lifecycle for each shape
    // Each shape has its own phase in the master timeline
    final double phaseOffset = staggerDelay;
    final double shapeTimeline = (drawProgress + phaseOffset) % 1.0;

    // Create a smooth loop with hold phase: 0 -> 1 -> [hold] -> 0
    // 0.0 - 0.3: Drawing (0 -> 1)
    // 0.3 - 0.7: Holding (stays at 1)
    // 0.7 - 1.0: Erasing (1 -> 0)
    double individualProgress;
    if (shapeTimeline < 0.3) {
      // Drawing phase (30% of cycle)
      individualProgress = shapeTimeline / 0.3; // 0 -> 1
    } else if (shapeTimeline < 0.7) {
      // Holding phase (40% of cycle)
      individualProgress = 1.0; // Stay at 1
    } else {
      // Erasing phase (30% of cycle)
      individualProgress = (1.0 - shapeTimeline) / 0.3; // 1 -> 0
    }

    // Apply easing for smoother transitions
    individualProgress = Curves.easeInOut.transform(individualProgress);

    // Position Calculations (Float + Parallax)
    final double dx = math.sin(floatProgress * math.pi * 2 + seed) * 15;
    final double dy = math.cos(floatProgress * math.pi * 2 + seed) * 15;
    final double parallaxX = parallax * 0.03 * size.width;

    canvas.translate(origin.dx + dx + parallaxX, origin.dy + dy);
    canvas.rotate(rotation);

    // Pulsing Scale logic
    final double pulseScale =
        1.0 + (math.sin(pulseProgress * math.pi * 2 + seed) * 0.05);
    canvas.scale(scale * pulseScale);

    final Path path = _getPathForType(type);

    // Draw logic based on type
    if (type == _ElementType.star ||
        type == _ElementType.sparkle ||
        type == _ElementType.heart) {
      _paintHandDrawnStar(canvas, path, color, individualProgress);
    } else {
      _paintStandardPath(
        canvas,
        path,
        color.withValues(alpha: 0.6),
        individualProgress,
      );
    }

    canvas.restore();
  }

  void _paintHandDrawnStar(
    Canvas canvas,
    Path path,
    Color color,
    double progress,
  ) {
    final PathMetrics metrics = path.computeMetrics();

    // 1. Scribble Fill (Yellow part in user's image)
    if (progress > 0.4) {
      final double fillOpacity = math.min(1.0, (progress - 0.4) * 2) * 0.8;

      // We clip to the path and draw some "scribble" lines inside
      canvas.save();
      canvas.clipPath(path);
      // Rough scribble effect
      final scribblePath = Path();
      for (double i = -50; i < 150; i += 8) {
        scribblePath.moveTo(-50, i);
        scribblePath.lineTo(150, i + 10);
      }
      canvas.drawPath(
        scribblePath,
        Paint()
          ..color = color.withValues(alpha: fillOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
      // Optional: use fillPaint if needed, but for now we fix the warning by keeping it or removing.
      // Since it was unused, I'll remove it to be clean.
      canvas.restore();
    }

    // 2. Black Outline (Hand-drawn look)
    final outlinePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.8 * progress)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.0;

    for (final PathMetric metric in metrics) {
      canvas.drawPath(
        metric.extractPath(0, metric.length * progress),
        outlinePaint,
      );
    }
  }

  void _paintStandardPath(
    Canvas canvas,
    Path path,
    Color color,
    double progress,
  ) {
    final paint = Paint()
      ..color = color.withValues(alpha: color.opacity * progress)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 20.0;

    final PathMetrics metrics = path.computeMetrics();
    for (final PathMetric metric in metrics) {
      canvas.drawPath(metric.extractPath(0, metric.length * progress), paint);
    }
  }

  Path _getPathForType(_ElementType type) {
    final Path path = Path();
    switch (type) {
      case _ElementType.star:
        // Proper 5-point star path
        _addStarPath(path, 0, 0, 40, 18);
        break;
      case _ElementType.sparkle:
        // Cluster of 3 stars
        _addStarPath(path, 0, 0, 30, 12);
        _addStarPath(path, 45, -25, 15, 6);
        _addStarPath(path, -35, 25, 20, 8);
        break;
      case _ElementType.heart:
        // A simple heart shape
        // Roughly 60x60 centered
        path.moveTo(0, 10);
        path.cubicTo(-30, -20, -60, 20, 0, 80);
        path.cubicTo(60, 20, 30, -20, 0, 10);
        break;
      case _ElementType.spiral:
        // The refined 3-loop squiggle
        path.moveTo(0, 0);
        path.cubicTo(40, -10, 80, 40, 40, 60);
        path.cubicTo(10, 75, 10, 20, 50, 40);
        path.cubicTo(90, 60, 110, 110, 70, 130);
        path.cubicTo(40, 145, 40, 90, 80, 110);
        path.cubicTo(120, 130, 140, 180, 100, 200);
        path.cubicTo(70, 215, 70, 160, 110, 180);
        break;
      case _ElementType.zigzag:
        path.moveTo(0, 0);
        path.lineTo(30, 40);
        path.lineTo(0, 80);
        path.lineTo(30, 120);
        path.lineTo(0, 160);
        break;
      case _ElementType.loop:
        path.addOval(Rect.fromLTWH(0, 0, 80, 100));
        break;
    }
    return path;
  }

  void _addStarPath(Path path, double cx, double cy, double r, double innerR) {
    for (int i = 0; i < 10; i++) {
      final double angle = i * math.pi / 5 - math.pi / 2;
      final double currR = i % 2 == 0 ? r : innerR;
      final double x = cx + math.cos(angle) * currR;
      final double y = cy + math.sin(angle) * currR;
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }
    path.close();
  }

  @override
  bool shouldRepaint(covariant _MotionArtPainter oldDelegate) => true;
}

enum _ElementType { star, spiral, zigzag, loop, sparkle, heart }
