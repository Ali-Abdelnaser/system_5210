import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/features/specialists/domain/entities/doctor.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import 'package:system_5210/core/widgets/app_shimmer.dart';
import 'dart:ui';
import 'package:system_5210/features/nutrition_scan/presentation/widgets/glass_container.dart';

class DoctorQuickCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;
  final double? width;

  const DoctorQuickCard({
    super.key,
    required this.doctor,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final isAr = lang == 'ar';
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: GlassContainer(
          borderRadius: BorderRadius.circular(24),
          opacity: 0.1,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image Section
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'doctor_image_${doctor.id}',
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        child: Image.network(
                          doctor.imageUrl,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return AppShimmer(
                              width: double.infinity,
                              height: double.infinity,
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFF1F5F9),
                              child: const Icon(
                                Icons.person,
                                color: Color(0xFFCBD5E1),
                                size: 40,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (doctor.allowsOnlineConsultation)
                      Positioned(
                        top: 12,
                        right: isAr ? null : 12,
                        left: isAr ? 12 : null,
                        child: _buildBadge(l10n.onlineConsultation, lang),
                      ),
                  ],
                ),
              ),
              // Details Section
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        doctor.getName(lang),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style:
                            (lang == 'ar'
                            ? GoogleFonts.cairo
                            : GoogleFonts.poppins)(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                              height: 1.2,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor.getSpecialty(lang),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style:
                            (lang == 'ar'
                            ? GoogleFonts.cairo
                            : GoogleFonts.poppins)(
                              fontSize: 11,
                              color: AppTheme.appBlue,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, String lang) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.appGreen.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Text(
            text,
            style: (lang == 'ar' ? GoogleFonts.cairo : GoogleFonts.poppins)(
              fontSize: 9,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
