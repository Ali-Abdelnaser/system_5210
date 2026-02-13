import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DiscoveryInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final bool isArabic;
  final String? Function(String?)? validator;

  const DiscoveryInputField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    required this.isArabic,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
              label,
              style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
                height: 1.4,
              ),
            )
            .animate()
            .fadeIn(duration: 600.ms)
            .slideX(begin: isArabic ? 0.1 : -0.1),
        Container(
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.05),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextFormField(
                controller: controller,
                validator: validator, // Added validator
                style: (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF334155),
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  hintText: hint,
                  hintStyle:
                      (isArabic ? GoogleFonts.cairo : GoogleFonts.poppins)(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                ),
              ),
            )
            .animate()
            .fadeIn(delay: 200.ms)
            .scale(begin: const Offset(0.95, 0.95)),
      ],
    );
  }
}
