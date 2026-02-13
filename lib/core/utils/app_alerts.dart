import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

enum AlertType { success, error, warning, info }

class AppAlerts {
  static void showAlert(
    BuildContext context, {
    required String message,
    AlertType type = AlertType.error,
  }) {
    final baseColor = _getBaseColor(type);
    final icon = _getIcon(type);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        duration: const Duration(seconds: 4),
        content: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: baseColor.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: baseColor.withAlpha(255), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF1E293B),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Future<T?> showAppDialog<T>(
    BuildContext context, {
    required Widget child,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: child,
      ),
    );
  }

  static Color _getBaseColor(AlertType type) {
    switch (type) {
      case AlertType.success:
        return const Color(0xFF10B981); // Modern Green
      case AlertType.error:
        return const Color(0xFFEF4444); // Modern Red
      case AlertType.warning:
        return const Color(0xFFF59E0B); // Modern Amber
      case AlertType.info:
        return const Color(0xFF3B82F6); // Modern Blue
    }
  }

  static IconData _getIcon(AlertType type) {
    switch (type) {
      case AlertType.success:
        return Icons.check_circle_rounded;
      case AlertType.error:
        return Icons.error_rounded;
      case AlertType.warning:
        return Icons.warning_rounded;
      case AlertType.info:
        return Icons.info_rounded;
    }
  }

  static void showCustomDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
    IconData? icon,
    Color? iconColor,
    List<Color>? buttonColors,
    bool isSuccess = true,
    String? cancelText,
    VoidCallback? onCancel,
  }) {
    // Default colors based on success/failure if not provided
    final themeColor = isSuccess
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);
    final finalIcon =
        icon ?? (isSuccess ? Icons.check_rounded : Icons.error_rounded);
    final finalIconColor = iconColor ?? themeColor;
    final finalButtonColors =
        buttonColors ??
        (isSuccess
            ? [const Color(0xFF1565C0), const Color(0xFF0D47A1)]
            : [const Color(0xFFEF4444), const Color(0xFFB91C1C)]);

    showAppDialog(
      context,
      child: AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        contentPadding: const EdgeInsets.all(30),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: finalIconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(finalIcon, color: finalIconColor, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.dynaPuff(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            GestureDetector(
              onTap: () {
                onPressed();
              },
              child: Container(
                height: 52,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: finalButtonColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: finalButtonColors.first.withOpacity(0.35),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    buttonText,
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            if (cancelText != null) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onCancel ?? () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    cancelText,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
