import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/utils/app_images.dart';

class DriftingCloud extends StatelessWidget {
  final int index;
  const DriftingCloud({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    // Distribute clouds more randomly across the whole height
    final double top = (index * 70.0) % MediaQuery.of(context).size.height;
    final double scale = 0.4 + (index % 4) * 0.25;
    final int speed = 20 + (index * 4);
    final double delay = index * 1.5;

    return Positioned(
      top: top,
      left: 0,
      child:
          Opacity(
                opacity: 0.5,
                child: Image.asset(AppImages.cloud, width: 250 * scale),
              )
              .animate(onPlay: (c) => c.repeat(), delay: delay.seconds)
              .moveX(
                begin: -300,
                end: MediaQuery.of(context).size.width + 300,
                duration: speed.seconds,
                curve: Curves.linear,
              ),
    );
  }
}
