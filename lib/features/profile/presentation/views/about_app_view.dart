import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'dart:ui';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/l10n/app_localizations.dart';

class AboutAppView extends StatefulWidget {
  const AboutAppView({super.key});

  @override
  State<AboutAppView> createState() => _AboutAppViewState();
}

class _AboutAppViewState extends State<AboutAppView> {
  String _version = '1.0.0';
  String _buildNumber = '1';

  final List<Map<String, String>> _mediaCoverage = [
    {
      'title': 'Sada El Omma Coverage',
      'url': 'https://www.sadaelomma.com/2026/02/cic-5210.html',
      'source': 'Sada El Omma',
    },
    {
      'title': 'E3raf Aktar News',
      'url': 'https://www.e3rafaktar.com/2026/02/FiveTwoTen%20.html',
      'source': 'E3raf Aktar',
    },
    {
      'title': 'El Entilaqa News',
      'url': 'https://elentilaqanews.com/?p=75462',
      'source': 'El Entilaqa',
    },
    {
      'title': 'Hurghada 24',
      'url': 'https://hurghada24.net/?p=23269',
      'source': 'Hurghada 24',
    },
    {
      'title': 'Facebook Post 1',
      'url': 'https://www.facebook.com/share/p/1D1qFZ98FZ/',
      'source': 'Facebook',
    },
    {
      'title': 'Facebook Post 2',
      'url': 'https://www.facebook.com/share/p/1AxP1t8PBF/',
      'source': 'Facebook',
    },
    {
      'title': 'Facebook Post 3',
      'url': 'https://www.facebook.com/share/p/17uTdqFaCa/',
      'source': 'Facebook',
    },
  ];

  final Map<String, String> _socialLinks = {
    'youtube': 'https://www.youtube.com/@Fivetwoten-eg',
    'facebook': 'https://www.facebook.com/share/14Up9sdE57q/?mibextid=wwXIfr',
    'instagram':
        'https://www.instagram.com/five.two.ten?igsh=MTB4c2UwMzBobnM1dQ%3D%3D&utm_source=qr',
    'tiktok': 'https://www.tiktok.com/@five.two.ten?_r=1&_t=ZS-93fsYSupnI0',
  };

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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not launch link')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: Stack(
        children: [
          // Global Background Image
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),

          // Slight overlay to ensure readability
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(l10n, isAr),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildSectionCard(
                        l10n.aboutWhoWeAreTitle,
                        l10n.aboutWhoWeAreContent,
                        Icons.groups_rounded,
                        Colors.blue,
                        isAr,
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
                      const SizedBox(height: 20),
                      _buildTeamPhotoSection(l10n, isAr)
                          .animate()
                          .fadeIn(delay: 100.ms, duration: 600.ms)
                          .slideY(begin: 0.2),
                      const SizedBox(height: 20),
                      _buildFiveTwoTenSection(l10n, isAr)
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 600.ms)
                          .slideY(begin: 0.2),
                      const SizedBox(height: 20),
                      _buildAppConceptSection(l10n, isAr)
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 600.ms)
                          .slideY(begin: 0.2),
                      const SizedBox(height: 20),
                      Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard(
                                  l10n.aboutVisionTitle,
                                  l10n.aboutVisionContent,
                                  Icons.track_changes_rounded,
                                  Colors.purple,
                                  isAr,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildInfoCard(
                                  l10n.aboutMissionTitle,
                                  l10n.aboutMissionContent,
                                  Icons.verified_rounded,
                                  Colors.orange,
                                  isAr,
                                ),
                              ),
                            ],
                          )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 600.ms)
                          .slideY(begin: 0.2),
                      const SizedBox(height: 32),
                      _buildMediaCoverageSection(
                        l10n,
                        isAr,
                      ).animate().fadeIn(delay: 500.ms, duration: 600.ms),
                      const SizedBox(height: 32),
                      _buildSocialMediaSection(
                        l10n,
                        isAr,
                      ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
                      const SizedBox(height: 48),
                      _buildFooter(l10n, isAr),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(AppLocalizations l10n, bool isAr) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: const AppBackButton(),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: Image.asset(
                        AppImages.logo,
                        width: 200,
                        height: 200,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.appName,
                    style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    "Version $_version+$_buildNumber",
                    style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassContainer({
    required Widget child,
    double borderRadius = 24,
    Color? borderColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    String title,
    String content,
    IconData icon,
    Color color,
    bool isAr,
  ) {
    return _buildGlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                fontSize: 15,
                height: 1.7,
                color: const Color(0xFF334155),
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String content,
    IconData icon,
    Color color,
    bool isAr,
  ) {
    return _buildGlassContainer(
      borderColor: color.withOpacity(0.2),
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 12),
            Text(
              title,
              style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                content,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                  fontSize: 13,
                  height: 1.5,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamPhotoSection(AppLocalizations l10n, bool isAr) {
    return _buildGlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                const Icon(Icons.groups_outlined, color: Colors.blue, size: 22),
                const SizedBox(width: 8),
                Text(
                  l10n.aboutMeetOurTeamTitle,
                  style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                AppImages.teamPhoto,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.white.withOpacity(0.3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.image_outlined,
                          color: Color(0xFF64748B),
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Team Photo",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiveTwoTenSection(AppLocalizations l10n, bool isAr) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0F172A).withOpacity(0.85),
                const Color(0xFF1E293B).withOpacity(0.85),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Text(
                l10n.aboutFiveTwoTenDetail,
                textAlign: TextAlign.center,
                style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricItem("5", AppImages.gameSuccess3),
                  _buildMetricItem("2", AppImages.gameSuccess4),
                  _buildMetricItem("1", AppImages.gameSuccess1),
                  _buildMetricItem("0", AppImages.gameSuccess2),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(String number, String imagePath) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Image.asset(
              imagePath,
              width: 65,
              height: 65,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          number,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAppConceptSection(AppLocalizations l10n, bool isAr) {
    return _buildSectionCard(
      l10n.aboutAppConceptTitle,
      l10n.aboutAppConceptContent,
      Icons.auto_awesome_rounded,
      Colors.amber,
      isAr,
    );
  }

  Widget _buildMediaCoverageSection(AppLocalizations l10n, bool isAr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.newspaper_outlined,
              color: Color(0xFF3B82F6),
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              l10n.aboutMediaCoverageTitle,
              style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _mediaCoverage.length,
            itemBuilder: (context, index) {
              final item = _mediaCoverage[index];
              final source = item['source']!;

              // Brand colors for different sources
              Color sourceColor = const Color(0xFF3B82F6);
              if (source.contains('Facebook'))
                sourceColor = const Color(0xFF1877F2);
              if (source.contains('Sada'))
                sourceColor = const Color(0xFF10B981);
              if (source.contains('Aktar'))
                sourceColor = const Color(0xFFF59E0B);
              if (source.contains('Hurghada'))
                sourceColor = const Color(0xFFEF4444);

              return Container(
                width: 260,
                margin: EdgeInsets.only(
                  right: isAr ? 0 : 16,
                  left: isAr ? 16 : 0,
                ),
                child: _buildGlassContainer(
                  borderRadius: 24,
                  child: InkWell(
                    onTap: () => _launchUrl(item['url']!),
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: sourceColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: sourceColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  source,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: sourceColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_outward,
                                size: 16,
                                color: const Color(0xFF64748B).withOpacity(0.5),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            item['title']!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                (isAr
                                ? GoogleFonts.cairo
                                : GoogleFonts.poppins)(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                  color: const Color(0xFF1E293B),
                                ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                isAr ? "اقرأ المزيد" : "Read Full Article",
                                style:
                                    (isAr
                                    ? GoogleFonts.cairo
                                    : GoogleFonts.poppins)(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: sourceColor,
                                    ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right,
                                size: 14,
                                color: sourceColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSocialMediaSection(AppLocalizations l10n, bool isAr) {
    return _buildGlassContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            Text(
              l10n.aboutSocialMediaTitle,
              style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSimpleSocialIcon(
                  imagePath: AppImages.youtubeLogo,
                  url: _socialLinks['youtube']!,
                  label: "YouTube",
                  fallbackColor: const Color(0xFFFF0000),
                ),
                _buildSimpleSocialIcon(
                  imagePath: AppImages.facebookLogo,
                  url: _socialLinks['facebook']!,
                  label: "Facebook",
                  fallbackColor: const Color(0xFF1877F2),
                ),
                _buildSimpleSocialIcon(
                  imagePath: AppImages.instagramLogo,
                  url: _socialLinks['instagram']!,
                  label: "Instagram",
                  fallbackColor: const Color(0xFFE4405F),
                ),
                _buildSimpleSocialIcon(
                  imagePath: AppImages.tiktokLogo,
                  url: _socialLinks['tiktok']!,
                  label: "TikTok",
                  fallbackColor: Colors.black,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleSocialIcon({
    required String imagePath,
    required String url,
    required String label,
    required Color fallbackColor,
  }) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        height: 40,
        width: 40,
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              label == "YouTube"
                  ? Icons.play_arrow_rounded
                  : label == "Facebook"
                  ? Icons.facebook_rounded
                  : label == "Instagram"
                  ? Icons.camera_rounded
                  : Icons.music_note_rounded,
              color: fallbackColor,
              size: 40,
            );
          },
        ),
      ),
    );
  }

  Widget _buildFooter(AppLocalizations l10n, bool isAr) {
    return Column(
      children: [
        const Divider(color: Colors.white24),
        const SizedBox(height: 24),
        Text(
          l10n.developedBy,
          style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "CIC Faculty of Mass Communication Students",
          textAlign: TextAlign.center,
          style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.allRightsReserved,
          style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
            fontSize: 12,
            color: const Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}
