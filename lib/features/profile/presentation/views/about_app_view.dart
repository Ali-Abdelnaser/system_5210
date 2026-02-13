import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'dart:ui';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:system_5210/l10n/app_localizations.dart';

class AboutAppView extends StatefulWidget {
  const AboutAppView({super.key});

  @override
  State<AboutAppView> createState() => _AboutAppViewState();
}

class _AboutAppViewState extends State<AboutAppView> {
  String _version = '1.0.0';
  String _buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.aboutAppTitle,
          style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3142),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const AppBackButton(),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              AppImages.logo, // Assuming this exists
                              width: 80,
                              height: 80,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            l10n.appName,
                            style:
                                (isAr
                                ? GoogleFonts.cairo
                                : GoogleFonts.poppins)(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Version $_version ($_buildNumber)",
                            style:
                                (isAr
                                ? GoogleFonts.cairo
                                : GoogleFonts.poppins)(
                                  fontSize: 14,
                                  color: const Color(0xFF64748B),
                                ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            l10n.appDescription,
                            textAlign: TextAlign.center,
                            style:
                                (isAr
                                ? GoogleFonts.cairo
                                : GoogleFonts.poppins)(
                                  fontSize: 15,
                                  height: 1.6,
                                  color: const Color(0xFF475569),
                                ),
                          ),
                          const SizedBox(height: 40),
                          const Divider(),
                          const SizedBox(height: 20),
                          Text(
                            l10n.developedBy,
                            style:
                                (isAr
                                ? GoogleFonts.cairo
                                : GoogleFonts.poppins)(
                                  fontSize: 12,
                                  color: const Color(0xFF94A3B8),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.companyName,
                            style:
                                (isAr
                                ? GoogleFonts.cairo
                                : GoogleFonts.poppins)(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B),
                                ),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            l10n.allRightsReserved,
                            style:
                                (isAr
                                ? GoogleFonts.cairo
                                : GoogleFonts.poppins)(
                                  fontSize: 12,
                                  color: const Color(0xFF94A3B8),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
