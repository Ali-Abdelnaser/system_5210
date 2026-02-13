import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/l10n/app_localizations.dart';

class AppErrorView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onBack;
  final IconData icon;

  const AppErrorView({
    super.key,
    this.title = "",
    required this.message,
    required this.onRetry,
    this.onBack,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = l10n.localeName == 'ar';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with animation
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.appRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: AppTheme.appRed)
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .shake(duration: 2.seconds),
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              title.isNotEmpty
                  ? title
                  : (isAr ? "عذراً، حدث خطأ ما" : "Oops! Something went wrong"),
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              _mapErrorMessage(message, isAr),
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 15,
                color: const Color(0xFF64748B),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),

            // Retry Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.appBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isAr ? "حاول مرة أخرى" : "Try Again",
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ).animate().scale(delay: 200.ms, curve: Curves.elasticOut),

            const SizedBox(height: 12),

            // Optional Back Button
            if (onBack != null)
              TextButton(
                onPressed: onBack,
                child: Text(
                  isAr ? "رجوع" : "Go Back",
                  style: GoogleFonts.cairo(
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _mapErrorMessage(String msg, bool isAr) {
    if (msg.contains("SocketException") ||
        msg.contains("timeout") ||
        msg.contains("connection")) {
      return isAr
          ? "تأكدي من اتصالك بالإنترنت وحاولي مرة أخرى."
          : "Please check your internet connection and try again.";
    }
    if (msg.contains("FirebaseException") ||
        msg.contains("permission-denied")) {
      return isAr
          ? "ليس لديك صلاحية للقيام بهذا الإجراء."
          : "You don't have permission to perform this action.";
    }
    return msg;
  }
}
