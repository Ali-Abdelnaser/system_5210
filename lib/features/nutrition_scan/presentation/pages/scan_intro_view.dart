import 'package:flutter/material.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_routes.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import 'package:system_5210/core/utils/app_alerts.dart';

class ScanIntroView extends StatelessWidget {
  const ScanIntroView({super.key});

  void _handleStartScan(BuildContext context) {
    // محاكاة لفحص حالة السيرفر (يمكن استبدالها بفحص حقيقي لاحقاً)
    bool isServerDown = false; // لو خليتها true هيظهر الأليرت

    if (isServerDown) {
      final l10n = AppLocalizations.of(context)!;
      AppAlerts.showAlert(
        context,
        message: l10n.serverErrorMessage,
        type: AlertType.warning,
      );
    } else {
      Navigator.pushNamed(context, AppRoutes.nutritionScan);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = l10n.localeName == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.appBlue.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.document_scanner_rounded,
                    size: 80,
                    color: AppTheme.appBlue,
                  ),
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 48),

              // Main Headline
              Text(
                    l10n.scanIntroTitle,
                    style: GoogleFonts.cairo(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.appBlue,
                      height: 1.2,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideX(begin: isAr ? 0.2 : -0.2),

              const SizedBox(height: 12),

              Text(
                    l10n.scanIntroDesc,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .slideX(begin: isAr ? 0.1 : -0.1),

              const SizedBox(height: 40),

              // How it works section
              _buildSectionTitle(context, l10n.howItWorks),
              const SizedBox(height: 20),
              _buildStepItem(
                context,
                icon: Icons.camera_alt_outlined,
                title: l10n.step1Title,
                desc: l10n.step1Desc,
              ),
              _buildStepItem(
                context,
                icon: Icons.psychology_outlined,
                title: l10n.step2Title,
                desc: l10n.step2Desc,
                delay: 200.ms,
              ),
              _buildStepItem(
                context,
                icon: Icons.fact_check_outlined,
                title: l10n.step3Title,
                desc: l10n.step3Desc,
                delay: 400.ms,
              ),

              const SizedBox(height: 40),

              // Primary Action
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  onPressed: () => _handleStartScan(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.appBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.qr_code_scanner, size: 28)
                          .animate(onPlay: (controller) => controller.repeat())
                          .shimmer(duration: 1500.ms, color: Colors.white30)
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.1, 1.1),
                            duration: 750.ms,
                            curve: Curves.easeInOut,
                          )
                          .then()
                          .scale(
                            begin: const Offset(1.1, 1.1),
                            end: const Offset(1, 1),
                            duration: 750.ms,
                            curve: Curves.easeInOut,
                          ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.startScan,
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().scale(delay: 600.ms),

              const SizedBox(height: 16),

              // Secondary Action (History)
              InkWell(
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.recentScans),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.appYellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.appYellow.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history, color: AppTheme.appYellow),
                      const SizedBox(width: 12),
                      Text(
                        l10n.viewHistory,
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF9E7700),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildStepItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String desc,
    Duration delay = Duration.zero,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.appBlue.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppTheme.appBlue, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay).slideY(begin: 0.1);
  }
}
