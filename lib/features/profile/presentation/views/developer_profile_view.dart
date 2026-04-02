import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:five2ten/core/theme/app_theme.dart';
import 'package:five2ten/core/utils/app_images.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:five2ten/core/widgets/app_back_button.dart';

const String _kDeveloperEmail = 'alinaserhema60@gmail.com';
const String _kLinkedInUrl =
    'https://www.linkedin.com/in/ali-abdelnaser-947230295/';
const String _kWhatsAppDigits = '201068643407';

class DeveloperProfileView extends StatelessWidget {
  const DeveloperProfileView({super.key});

  static Future<void> _openUri(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final textStyle = isAr ? GoogleFonts.cairo : GoogleFonts.poppins;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: size.height * 0.48,
            pinned: true,
            backgroundColor: const Color(0xFFF8FAFC),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: const AppBackButton(),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(AppImages.developerPhoto, fit: BoxFit.cover),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.5, 0.88, 1.0],
                          colors: [
                            Colors.transparent,
                            const Color(0xFFF8FAFC).withValues(alpha: 0.92),
                            const Color(0xFFF8FAFC),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 24,
                    child: Column(
                      children: [
                        Text(
                              isAr ? 'علي عبد الناصر' : 'Ali Abdelnaser',
                              textAlign: TextAlign.center,
                              style: textStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0F172A),
                                letterSpacing: isAr ? 0 : -0.3,
                                height: 1.2,
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.12, curve: Curves.easeOutCubic),
                        const SizedBox(height: 10),
                        Text(
                          isAr
                              ? 'مطوّر تطبيقات موبايل'
                              : 'Mobile Application Developer',
                          textAlign: TextAlign.center,
                          style: textStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                            height: 1.3,
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionLabel(
                    text: isAr ? 'نبذة مهنية' : 'Professional summary',
                    isAr: isAr,
                  ).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 12),
                  _ProCard(
                    child: Text(
                      isAr
                          ? 'أنا مطور تطبيقات فلاتر (Flutter Developer) متخصص في بناء تطبيقات موبايل عالية الأداء وذات تصميمات بصرية جذابة. أمتلك خبرة واسعة في تطوير حلول برمجية متكاملة تجمع بين سلاسة تجربة المستخدم وقوة الأنظمة البرمجية. أتخصص في استخدام أحدث تقنيات إدارة الحالة (Bloc/Cubit) وهيكلة الكود النظيف (Clean Architecture)، مع التركيز الدائم على تقديم برمجيات قابلة للتوسع والتطوير. هذا التطبيق هو نتاج شغفي بالتميز والتزامي بتقديم تجارب رقمية تترك أثراً حقيقياً.'
                          : 'I am a professional Flutter Developer dedicated to crafting high-performance, visually stunning mobile applications. I specialize in building cross-platform solutions that combine seamless user experiences with robust backend integration. With expertise in state management (Bloc/Cubit), Clean Architecture, and performance optimization, I focus on delivering scalable and maintainable code. This application is a testament to my commitment to quality and digital excellence.',
                      style: textStyle(
                        fontSize: 15,
                        height: 1.7,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.04),
                  const SizedBox(height: 28),
                  _SectionLabel(
                    text: isAr ? 'قنوات التواصل' : 'Contact channels',
                    isAr: isAr,
                  ),
                  const SizedBox(height: 12),
                  _ProCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _ContactChannelTile(
                          isAr: isAr,
                          leading: _ChannelIconBox(
                            color: const Color(0xFFEFF6FF),
                            child: Icon(
                              Icons.mail_outline_rounded,
                              color: AppTheme.appBlue,
                              size: 22,
                            ),
                          ),
                          title: isAr ? 'البريد الإلكتروني' : 'Email',
                          subtitle: isAr
                              ? 'فتح تطبيق البريد'
                              : 'Open your mail app',
                          onTap: () => _openUri(
                            Uri(scheme: 'mailto', path: _kDeveloperEmail),
                          ),
                        ),
                        const _ChannelDivider(),
                        _ContactChannelTile(
                          isAr: isAr,
                          leading: _ChannelIconBox(
                            color: const Color(0xFF25D366),
                            child: SvgPicture.asset(
                              AppImages.iconWhatsApp,
                              width: 24,
                              height: 24,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                          title: 'WhatsApp',
                          subtitle: isAr
                              ? 'محادثة مباشرة'
                              : 'Start a conversation',
                          onTap: () => _openUri(
                            Uri.parse('https://wa.me/$_kWhatsAppDigits'),
                          ),
                        ),
                        const _ChannelDivider(),
                        _ContactChannelTile(
                          isAr: isAr,
                          leading: const _LinkedInGlyph(),
                          title: 'LinkedIn',
                          subtitle: isAr ? 'الملف الشخصي' : 'Profile',
                          onTap: () => _openUri(Uri.parse(_kLinkedInUrl)),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.04),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.isAr});

  final String text;
  final bool isAr;

  @override
  Widget build(BuildContext context) {
    final font = isAr ? GoogleFonts.cairo : GoogleFonts.poppins;
    return Text(
      text.toUpperCase(),
      style: font(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: const Color(0xFF94A3B8),
      ),
    );
  }
}

class _ProCard extends StatelessWidget {
  const _ProCard({
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ChannelDivider extends StatelessWidget {
  const _ChannelDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 76),
      child: Divider(height: 1, thickness: 1, color: const Color(0xFFF1F5F9)),
    );
  }
}

class _ContactChannelTile extends StatelessWidget {
  const _ContactChannelTile({
    required this.isAr,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool isAr;
  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final titleStyle = (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF0F172A),
    );
    final subStyle = (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: const Color(0xFF94A3B8),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: titleStyle),
                    const SizedBox(height: 2),
                    Text(subtitle, style: subStyle),
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new_rounded,
                size: 18,
                color: const Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChannelIconBox extends StatelessWidget {
  const _ChannelIconBox({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

/// LinkedIn “in” mark — crisp, no low-res SVG.
class _LinkedInGlyph extends StatelessWidget {
  const _LinkedInGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF0A66C2),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        'in',
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          height: 1,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
