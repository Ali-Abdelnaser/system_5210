import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:five2ten/core/theme/app_theme.dart';

class SubmitPlateButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onPressed;

  const SubmitPlateButton({
    super.key,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child:
          SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: isEnabled ? onPressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.appRed,
                    elevation: 10,
                    shadowColor: AppTheme.appRed.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    '🍽️ تقديم الطبق',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
              .animate(target: isEnabled ? 1.0 : 0.0)
              .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05))
              .shimmer(),
    );
  }
}
