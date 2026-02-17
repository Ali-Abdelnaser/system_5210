import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';

import 'package:system_5210/l10n/app_localizations.dart';

class SupportView extends StatelessWidget {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.supportTitle,
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
                clipBehavior: Clip.antiAlias,
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionHeader(l10n.faqTitle, isAr),
                        const SizedBox(height: 20),
                        _buildFAQItem(
                          l10n.faqUpdateProfileQ,
                          l10n.faqUpdateProfileA,
                          isAr,
                        ),
                        _buildFAQItem(
                          l10n.faqManageChildrenQ,
                          l10n.faqManageChildrenA,
                          isAr,
                        ),
                        _buildFAQItem(
                          l10n.faqDataSecurityQ,
                          l10n.faqDataSecurityA,
                          isAr,
                        ),
                        const SizedBox(height: 32),
                        _buildSectionHeader(l10n.contactSupportTitle, isAr),
                        const SizedBox(height: 20),
                        _buildContactOption(
                          context: context,
                          icon: Icons.email_rounded,
                          title: l10n.emailSupportTitle,
                          subtitle: "support@familyhealth.com",
                          onTap: () {
                            final Uri emailLaunchUri = Uri(
                              scheme: 'mailto',
                              path: 'support@familyhealth.com',
                              query: 'subject=Support Request',
                            );
                            launchUrl(emailLaunchUri);
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildContactOption(
                          context: context,
                          icon: Icons.chat_bubble_rounded,
                          title: l10n.liveChatTitle,
                          subtitle: l10n.liveChatSubtitle,
                          onTap: () {
                            // Link to live chat or support portal
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildContactOption(
                          context: context,
                          icon: Icons.lightbulb_outline_rounded,
                          title: l10n.healthyInsightsTitle,
                          subtitle: l10n.healthyInsightsSubTitle,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/healthy-insights', // Using the route name directly to avoid import issues if not available, but AppRoutes is standard
                            );
                          },
                        ),
                        const SizedBox(height: 180),

                        // Add more options as needed
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

  Widget _buildSectionHeader(String title, bool isAr) {
    return Text(
      title,
      style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer, bool isAr) {
    return ExpansionTile(
      title: Text(
        question,
        style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1E293B),
        ),
      ),
      childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      expandedCrossAxisAlignment: isAr
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          answer,
          textAlign: isAr ? TextAlign.right : TextAlign.left,
          style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
            fontSize: 14,
            height: 1.5,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildContactOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF1565C0)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: isAr
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            if (!isAr)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
            if (isAr)
              const Icon(
                Icons.arrow_back_ios_rounded,
                size: 16,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }
}
