import 'package:flutter/material.dart';
import 'package:system_5210/core/theme/app_theme.dart';

class MatchingLine {
  final Offset start;
  final Offset end;
  final bool isCompleted;

  MatchingLine({
    required this.start,
    required this.end,
    this.isCompleted = false,
  });
}

class MatchingLinePainter extends CustomPainter {
  final List<MatchingLine> completedLines;
  final Offset? activeStart;
  final Offset? activeEnd;

  MatchingLinePainter({
    required this.completedLines,
    this.activeStart,
    this.activeEnd,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw completed lines
    for (final line in completedLines) {
      // 1. Extreme Glow (Outer)
      final glow1 = Paint()
        ..color = AppTheme.appGreen.withOpacity(0.12)
        ..strokeWidth = 24.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
      canvas.drawLine(line.start, line.end, glow1);

      // 2. Medium Glow
      final glow2 = Paint()
        ..color = AppTheme.appGreen.withOpacity(0.25)
        ..strokeWidth = 14.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);
      canvas.drawLine(line.start, line.end, glow2);

      // 3. Inner Sharp Glow
      final glow3 = Paint()
        ..color = AppTheme.appGreen.withOpacity(0.5)
        ..strokeWidth = 8.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
      canvas.drawLine(line.start, line.end, glow3);

      // 4. Core Core Line
      final corePaint = Paint()
        ..color = Colors.white.withOpacity(0.9)
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(line.start, line.end, corePaint);

      // End points decor
      final decoratorPaint = Paint()
        ..color = AppTheme.appGreen
        ..strokeWidth = 2.0;
      canvas.drawCircle(line.start, 6.0, decoratorPaint);
      canvas.drawCircle(line.end, 6.0, decoratorPaint);
      canvas.drawCircle(line.start, 2.5, Paint()..color = Colors.white);
      canvas.drawCircle(line.end, 2.5, Paint()..color = Colors.white);
    }

    // Draw active line
    if (activeStart != null && activeEnd != null) {
      // Active line outer glow
      final activeGlow = Paint()
        ..color = AppTheme.appBlue.withOpacity(0.15)
        ..strokeWidth = 20.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
      canvas.drawLine(activeStart!, activeEnd!, activeGlow);

      // Active line inner glow
      final activeInnerGlow = Paint()
        ..color = AppTheme.appBlue.withOpacity(0.4)
        ..strokeWidth = 10.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
      canvas.drawLine(activeStart!, activeEnd!, activeInnerGlow);

      // Active line core
      final activeCore = Paint()
        ..color = AppTheme.appBlue.withOpacity(0.9)
        ..strokeWidth = 5.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(activeStart!, activeEnd!, activeCore);

      // Active start pulse
      canvas.drawCircle(
        activeStart!,
        9.0,
        Paint()..color = AppTheme.appBlue.withOpacity(0.3),
      );
      canvas.drawCircle(activeStart!, 5.0, Paint()..color = Colors.white);

      // Active end pointer
      canvas.drawCircle(activeEnd!, 4.0, Paint()..color = AppTheme.appBlue);
    }
  }

  @override
  bool shouldRepaint(covariant MatchingLinePainter oldDelegate) {
    return oldDelegate.completedLines != completedLines ||
        oldDelegate.activeStart != activeStart ||
        oldDelegate.activeEnd != activeEnd;
  }
}
