import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/app_images.dart';

class WaterStageView extends StatefulWidget {
  final VoidCallback onComplete;

  const WaterStageView({super.key, required this.onComplete});

  @override
  State<WaterStageView> createState() => _WaterStageViewState();
}

class _WaterStageViewState extends State<WaterStageView> {
  double fillLevel = 0.0;
  int taps = 0;
  final int maxTaps = 8; // 8 cups to fill completely

  void _onTap() {
    if (fillLevel >= 1.0) return;

    setState(() {
      taps++;
      fillLevel = taps / maxTaps;
    });

    if (taps >= maxTaps) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        widget.onComplete();
        if (mounted) Navigator.pop(context);
      });
    }
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
                  'اشرب ميه كتيير!',
                  style: GoogleFonts.cairo(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'كل ما تشرب كوباية، دوس على الكوباية الكبيرة',
                  style: GoogleFonts.cairo(fontSize: 16, color: Colors.white70),
                ),
                const Spacer(),

                // Animated Cup
                GestureDetector(
                  onTap: _onTap,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Cup Outline
                        Container(
                          height: 250,
                          width: 150,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 5,
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                        ),

                        // Water Fill
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          height: 250 * fillLevel,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.7),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(25),
                              bottomRight: Radius.circular(25),
                            ),
                          ),
                          child: fillLevel > 0.1
                              ? const Icon(
                                  Icons.waves,
                                  color: Colors.white30,
                                  size: 50,
                                ).animate(onPlay: (c) => c.repeat()).shimmer()
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text(
                    '$taps / $maxTaps كوبايات',
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                if (fillLevel >= 1.0)
                  Text(
                    'برافو! جسمك دلوقتي رويان',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                    ),
                  ).animate().scale(duration: 400.ms, curve: Curves.bounceOut),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
