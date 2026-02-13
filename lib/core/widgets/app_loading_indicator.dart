import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:system_5210/core/theme/app_theme.dart';

class AppLoadingIndicator extends StatefulWidget {
  final double size;
  const AppLoadingIndicator({super.key, this.size = 60});

  @override
  State<AppLoadingIndicator> createState() => _AppLoadingIndicatorState();
}

class _AppLoadingIndicatorState extends State<AppLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: _RotatingDotsPainter(
                rotationProgress: _controller.value,
                colors: [
                  AppTheme.appRed,
                  AppTheme.appYellow,
                  AppTheme.appGreen,
                  AppTheme.appBlue,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RotatingDotsPainter extends CustomPainter {
  final double rotationProgress;
  final List<Color> colors;

  _RotatingDotsPainter({required this.rotationProgress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;

    for (int i = 0; i < 4; i++) {
      final double startAngle =
          (i * math.pi / 2) + (rotationProgress * 2 * math.pi);

      // Draw trails
      final rect = Rect.fromCircle(center: center, radius: radius);
      for (double j = 0; j < 1.0; j += 0.2) {
        final paint = Paint()
          ..color = colors[i].withValues(alpha: 0.5 * (1 - j))
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = (size.width * 0.1) * (1 - j * 0.5);

        canvas.drawArc(rect, startAngle - (j * 0.6), 0.1, false, paint);
      }

      // Draw dot
      final dotPaint = Paint()..color = colors[i];
      final dotOffset = Offset(
        center.dx + radius * math.cos(startAngle),
        center.dy + radius * math.sin(startAngle),
      );
      canvas.drawCircle(dotOffset, size.width * 0.08, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RotatingDotsPainter oldDelegate) => true;
}
