import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import 'dart:ui';

class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.privacyTitle,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(24),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSection(
                          l10n.infoCollectionTitle,
                          l10n.infoCollectionDesc,
                          isAr,
                        ),
                        _buildSection(
                          l10n.howWeUseInfoTitle,
                          l10n.howWeUseInfoDesc,
                          isAr,
                        ),
                        _buildSection(
                          l10n.dataSecurityTitle,
                          l10n.dataSecurityDesc,
                          isAr,
                        ),
                        _buildSection(
                          l10n.childrenPrivacyTitle,
                          l10n.childrenPrivacyDesc,
                          isAr,
                        ),
                        _buildSection(
                          l10n.userRightsTitle,
                          l10n.userRightsDesc,
                          isAr,
                        ),
                        _buildSection(
                          l10n.policyChangesTitle,
                          l10n.policyChangesDesc,
                          isAr,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.lastUpdated,
                          style:
                              (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                        ),
                      ],
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

  Widget _buildSection(String title, String content, bool isAr) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: isAr
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            textAlign: isAr ? TextAlign.right : TextAlign.left,
            style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
              fontSize: 14,
              height: 1.5,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
