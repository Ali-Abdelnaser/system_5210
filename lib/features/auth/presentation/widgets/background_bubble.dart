import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BackgroundBubble extends StatelessWidget {
  final int index;
  final Color color;

  const BackgroundBubble({super.key, required this.index, required this.color});

  @override
  Widget build(BuildContext context) {
    final alignments = [
      Alignment.topLeft,
      Alignment.topRight,
      Alignment.bottomLeft,
      Alignment.centerRight,
      Alignment.bottomRight,
    ];

    return Align(
      alignment: alignments[index % alignments.length],
      child:
          Container(
                width: 100 + (index * 20),
                height: 100 + (index * 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.1),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.2, 1.2),
                duration: (2 + index).seconds,
              ),
    );
  }
}
