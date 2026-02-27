import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/features/specialists/domain/entities/doctor.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import 'package:system_5210/core/widgets/app_shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

class DoctorQuickCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;

  const DoctorQuickCard({super.key, required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final isAr = lang == 'ar';
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
          onTap: onTap,
          child: Container(
            width: 170,
            margin: const EdgeInsets.only(right: 20, bottom: 8, top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2D3142).withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Hero(
                            tag: 'doctor_image_${doctor.id}',
                            child: Image.network(
                              doctor.imageUrl,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              width: double.infinity,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
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
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              doctor.getName(lang),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  (lang == 'ar'
                                  ? GoogleFonts.cairo
                                  : GoogleFonts.poppins)(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E293B),
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              doctor.getSpecialty(lang),
                              maxLines: 1,
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
                    const SizedBox(height: 10),
                  ],
                ),
                if (doctor.allowsOnlineConsultation)
                  Positioned(
                    top: 12,
                    right: isAr ? null : 12,
                    left: isAr ? 12 : null,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.appGreen.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            l10n.onlineConsultation,
                            style:
                                (lang == 'ar'
                                ? GoogleFonts.cairo
                                : GoogleFonts.poppins)(
                                  fontSize: 9,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack);
  }
}
