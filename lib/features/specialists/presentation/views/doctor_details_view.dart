import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/features/specialists/domain/entities/doctor.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/l10n/app_localizations.dart';

class DoctorDetailsView extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailsView({super.key, required this.doctor});

  Future<void> _launchPhone() async {
    final Uri url = Uri.parse('tel:${doctor.contactNumber}');
    if (!await launchUrl(url)) debugPrint('Could not launch $url');
  }

  Future<void> _launchWhatsApp() async {
    final String cleanNumber = doctor.whatsappNumber.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final Uri url = Uri.parse('https://wa.me/+2$cleanNumber');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  Future<void> _launchMaps() async {
    final String query = Uri.encodeComponent(doctor.clinicLocation);
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lang = Localizations.localeOf(context).languageCode;
    final isAr = lang == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 400,
                pinned: true,
                stretch: true,
                leading: const SizedBox.shrink(),
                backgroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'doctor_image_${doctor.id}',
                        child: Image.network(
                          doctor.imageUrl,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.transparent,
                                Colors.white.withOpacity(0.95),
                              ],
                              stops: const [0.0, 0.4, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  centerTitle: true,
                  title: LayoutBuilder(
                    builder: (context, constraints) {
                      final isCollapsed = constraints.maxHeight < 120;
                      return AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isCollapsed ? 1.0 : 0.0,
                        child: Text(
                          doctor.getName(lang),
                          style:
                              (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2D3142),
                              ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      // Floating Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            context,
                            "${doctor.experienceYears}+",
                            l10n.yearsExp,
                            Colors.blue,
                          ),
                          _buildStatItem(
                            context,
                            doctor.allowsOnlineConsultation ? "ON" : "OFF",
                            l10n.availableOnline,
                            doctor.allowsOnlineConsultation
                                ? AppTheme.appGreen
                                : Colors.grey,
                          ),
                        ],
                      ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.1),

                      const SizedBox(height: 32),

                      // Name & Specialty
                      Text(
                        doctor.getName(lang),
                        style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF2D3142),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        doctor.getSpecialty(lang),
                        style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.appBlue,
                          letterSpacing: isAr ? 0 : 1.2,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Section: About
                      _buildSectionHeader(l10n.experience),
                      const SizedBox(height: 12),
                      Text(
                        doctor.getAbout(lang),
                        textAlign: TextAlign.start,
                        style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                          fontSize: 15,
                          color: Colors.blueGrey[600],
                          height: 1.7,
                        ),
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 32),

                      // Section: Working Schedule
                      _buildSectionHeader(l10n.workingHours),
                      const SizedBox(height: 16),
                      _buildScheduleCard(context, doctor, lang, isAr, l10n),

                      const SizedBox(height: 32),

                      // Section: Clinic Info
                      _buildSectionHeader(l10n.clinicsLocation),
                      const SizedBox(height: 16),
                      _buildLocationTile(
                        context,
                        doctor.clinicLocation,
                        isAr,
                        _launchMaps,
                      ),

                      const SizedBox(height: 32),

                      // Section: Certificates
                      if (doctor.certificates.isNotEmpty) ...[
                        _buildSectionHeader(l10n.certificates),
                        const SizedBox(height: 16),
                        _buildCertificatesSlider(context, doctor.certificates),
                        const SizedBox(height: 32),
                      ],

                      const SizedBox(height: 140),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Custom Absolute Floating Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 5,
            left: isAr ? null : 16,
            right: isAr ? 16 : null,
            child: const AppBackButton(iconColor: Color.fromARGB(255, 0, 0, 0)),
          ),

          // Fixed Bottom Action Buttons
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildGradientButton(
                    context,
                    onTap: _launchPhone,
                    text: l10n.callNow,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildWhatsAppButton(
                    context,
                    onTap: _launchWhatsApp,
                    l10n: l10n,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style:
              (Localizations.localeOf(context).languageCode == 'ar'
              ? GoogleFonts.cairo
              : GoogleFonts.poppins)(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style:
              (Localizations.localeOf(context).languageCode == 'ar'
              ? GoogleFonts.cairo
              : GoogleFonts.poppins)(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[300],
              ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.cairo(
        fontSize: 19,
        fontWeight: FontWeight.w800,
        color: const Color(0xFF2D3142),
      ),
    );
  }

  Widget _buildScheduleCard(
    BuildContext context,
    Doctor doctor,
    String lang,
    bool isAr,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, color: AppTheme.appBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  doctor.getWorkingDays(lang).join(" - "),
                  style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFE2E8F0)),
          ),
          Row(
            children: [
              const Icon(
                Icons.access_time_filled_rounded,
                color: Colors.orange,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  doctor.getWorkingHours(lang),
                  style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCertificatesSlider(BuildContext context, List<String> images) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Container(
            width: 260,
            margin: const EdgeInsetsDirectional.only(end: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: DecorationImage(
                image: NetworkImage(images[index]),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationTile(
    BuildContext context,
    String location,
    bool isAr,
    VoidCallback onTap,
  ) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2D3142).withOpacity(0.04),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: AppTheme.appBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      location,
                      style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.appBlue,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.appBlue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                isAr
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.directions_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton(
    BuildContext context, {
    required VoidCallback onTap,
    required String text,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppTheme.appBlue,
        boxShadow: [
          BoxShadow(
            color: AppTheme.appBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                AppImages.iconPhone,
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                text,
                style:
                    (Localizations.localeOf(context).languageCode == 'ar'
                    ? GoogleFonts.cairo
                    : GoogleFonts.poppins)(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWhatsAppButton(
    BuildContext context, {
    required VoidCallback onTap,
    required AppLocalizations l10n,
  }) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppTheme.appGreen,
        boxShadow: [
          BoxShadow(
            color: AppTheme.appGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: SvgPicture.asset(
              AppImages.iconWhatsApp,
              width: 40,
              height: 40,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
