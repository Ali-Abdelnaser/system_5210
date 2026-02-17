import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

class DailySummaryCard extends StatelessWidget {
  final int completedTargets;
  final int totalTargets;
  final VoidCallback onTap;

  const DailySummaryCard({
    super.key,
    required this.completedTargets,
    required this.totalTargets,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final double progress = (completedTargets / totalTargets).clamp(0.0, 1.0);
    final int percentage = (progress * 100).toInt();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              // Progress Ring
              Padding(
                padding: const EdgeInsets.all(20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: AppTheme.appBlue.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.appBlue,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      "$percentage%",
                      style: GoogleFonts.dynaPuff(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.appBlue,
                      ),
                    ),
                  ],
                ),
              ),

              // Text Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.summaryCardTitle,
                      style: GoogleFonts.dynaPuff(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.summaryCardSubTitle(completedTargets, totalTargets),
                      style:
                          (Localizations.localeOf(context).languageCode == 'ar'
                          ? GoogleFonts.cairo
                          : GoogleFonts.poppins)(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Container(
                margin: const EdgeInsetsDirectional.only(end: 20),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.appBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Localizations.localeOf(context).languageCode == 'ar'
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                  color: AppTheme.appBlue,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ).animate().slideY(begin: 0.2, duration: 500.ms).fadeIn(),
    );
  }
}
