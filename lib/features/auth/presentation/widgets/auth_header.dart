import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/utils/app_images.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  const AuthHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isSmallScreen = size.height < 700;
    return Column(
      children: [
        Center(
          child: Image.asset(AppImages.logo, height: isSmallScreen ? 150 : 220),
        ),
        const SizedBox(height: 15),
        Text(
          title,
          style: GoogleFonts.dynaPuff(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3142),
          ),
        ).animate().slideY(begin: 0.3, curve: Curves.easeOutBack),
      ],
    );
  }
}
