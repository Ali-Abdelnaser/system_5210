import 'dart:io';
import 'package:flutter/material.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/features/nutrition_scan/presentation/pages/processing_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';

class ScanConfirmationPage extends StatefulWidget {
  final String imagePath;
  const ScanConfirmationPage({super.key, required this.imagePath});

  @override
  State<ScanConfirmationPage> createState() => _ScanConfirmationPageState();
}

class _ScanConfirmationPageState extends State<ScanConfirmationPage> {
  bool _isProcessing = false;

  void _processImage() async {
    setState(() => _isProcessing = true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProcessingView(imagePath: widget.imagePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. The Real Captured Image (Full Brightness)
          Center(
            child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
          ),

          // 2. Subtle Bottom Gradient for Button Visibility
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.0, 0.2, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // 3. UI Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  "تأكيد الوضوح",
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      const Shadow(color: Colors.black45, blurRadius: 10),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: -0.2),
                const Spacer(),

                // Bottom Instruction
                Text(
                  "تأكدي أن النص واضح للحصول على أدق تحليل",
                  style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13),
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 30),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Row(
                    children: [
                      // Retake Button
                      Expanded(
                        child: _buildButton(
                          label: "إعادة",
                          icon: Icons.refresh,
                          onTap: () => Navigator.pop(context),
                          isPrimary: false,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Confirm Button
                      Expanded(
                        child: _buildButton(
                          label: "تحليل",
                          icon: Icons.auto_awesome,
                          onTap: _processImage,
                          isPrimary: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: isPrimary
                  ? AppTheme.appBlue
                  : Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
