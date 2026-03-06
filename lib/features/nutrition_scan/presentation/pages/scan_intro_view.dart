import 'package:flutter/material.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_routes.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_5210/features/nutrition_scan/presentation/manager/nutrition_scan_cubit.dart';
import 'package:system_5210/features/nutrition_scan/presentation/manager/nutrition_scan_state.dart';
import 'package:system_5210/features/daily_tasks_game/presentation/widgets/glass_card.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import 'package:system_5210/core/utils/app_alerts.dart';
import 'package:system_5210/core/utils/app_images.dart';

class ScanIntroView extends StatefulWidget {
  const ScanIntroView({super.key});

  @override
  State<ScanIntroView> createState() => _ScanIntroViewState();
}

class _ScanIntroViewState extends State<ScanIntroView> {
  int _dailyScanCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDailyCount();
  }

  Future<void> _loadDailyCount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && mounted) {
      context.read<NutritionScanCubit>().updateDailyScanCount(user.uid);
    }
  }

  void _handleStartScan(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      AppAlerts.showAlert(
        context,
        message: l10n.localeName == 'ar'
            ? "يجب تسجيل الدخول لاستخدام هذه الميزة"
            : "You must login to use this feature",
        type: AlertType.warning,
      );
      return;
    }

    // Check Daily Limit
    final cubit = context.read<NutritionScanCubit>();
    final reachedLimit = await cubit.hasReachedLimit(user.uid);

    if (!context.mounted) return;

    if (reachedLimit) {
      AppAlerts.showAlert(
        context,
        message: l10n.localeName == 'ar'
            ? "عذراً! لقد استهلكت جميع محاولات الفحص المتاحة لك اليوم (5 محاولات). يرجى المحاولة غداً."
            : "Sorry! You have used all your scan attempts for today (5 attempts). Please try again tomorrow.",
        type: AlertType.warning,
      );
      return;
    }

    Navigator.pushNamed(context, AppRoutes.nutritionScan);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = l10n.localeName == 'ar';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. App Background
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),

          // 3. Content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Custom Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDailyCounter(context, l10n),
                        _buildHistoryBadge(context, l10n),
                      ],
                    ),
                  ),
                ),

                // Hero Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),

                        // Transparent ENLARGED Animated Scanner Hero
                        SizedBox(
                          height: 250,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // 1. Organized Radar Waves (Sequential & Synchronized)
                              ...List.generate(
                                3,
                                (index) =>
                                    Container(
                                          width: 140,
                                          height: 140,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppTheme.appBlue
                                                  .withValues(alpha: 0.35),
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppTheme.appBlue
                                                    .withValues(alpha: 0.1),
                                                blurRadius: 15,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                        )
                                        .animate(onPlay: (c) => c.repeat())
                                        .scale(
                                          delay: (index * 600).ms,
                                          duration: 1800.ms,
                                          begin: const Offset(0.8, 0.8),
                                          end: const Offset(1.8, 1.8),
                                          curve: Curves.easeOut,
                                        )
                                        .fadeOut(
                                          delay: (index * 600).ms,
                                          duration: 1800.ms,
                                        ),
                              ),

                              // 2. Center Glow Point
                              Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.appBlue.withValues(
                                            alpha: 0.2,
                                          ),
                                          blurRadius: 40,
                                          spreadRadius: 10,
                                        ),
                                      ],
                                    ),
                                  )
                                  .animate(
                                    onPlay: (c) => c.repeat(reverse: true),
                                  )
                                  .shimmer(duration: 2.seconds),

                              // 3. Icon with Scanning Line
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(
                                        Icons.qr_code_scanner_rounded,
                                        size: 140,
                                        color: AppTheme.appBlue,
                                      )
                                      .animate(
                                        onPlay: (c) => c.repeat(reverse: true),
                                      )
                                      .scale(
                                        begin: const Offset(1, 1),
                                        end: const Offset(1.05, 1.05),
                                        duration: 1.seconds,
                                      ),

                                  // Laser Scanning Line (Vibrant)
                                  Container(
                                        width: 160,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: AppTheme.appBlue,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.appBlue,
                                              blurRadius: 15,
                                              spreadRadius: 4,
                                            ),
                                            BoxShadow(
                                              color: Colors.white.withValues(
                                                alpha: 0.8,
                                              ),
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                      )
                                      .animate(onPlay: (c) => c.repeat())
                                      .moveY(
                                        begin: -70,
                                        end: 70,
                                        duration: 2.seconds,
                                        curve: Curves.easeInOut,
                                      ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        Text(
                          l10n.scanIntroTitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF1E293B),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.scanIntroDesc,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: Colors.black45,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 50)),

                // Guided Bento Steps
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildBentoStep(
                        index: 1,
                        icon: Icons.camera_alt_rounded,
                        title: l10n.step1Title,
                        desc: l10n.step1Desc,
                        color: AppTheme.appBlue,
                        isAr: isAr,
                      ),
                      const SizedBox(height: 16),
                      _buildBentoStep(
                        index: 2,
                        icon: Icons.psychology_rounded,
                        title: l10n.step2Title,
                        desc: l10n.step2Desc,
                        color: AppTheme.appYellow,
                        isAr: isAr,
                      ),
                      const SizedBox(height: 16),
                      _buildBentoStep(
                        index: 3,
                        icon: Icons.fact_check_rounded,
                        title: l10n.step3Title,
                        desc: l10n.step3Desc,
                        color: AppTheme.appGreen,
                        isAr: isAr,
                      ),
                    ]),
                  ),
                ),

                // Action Area
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      height: 70,
                      child: ElevatedButton(
                        onPressed: () => _handleStartScan(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.appBlue,
                          foregroundColor: Colors.white,
                          elevation: 10,
                          shadowColor: AppTheme.appBlue.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.bolt_rounded, size: 28),
                            const SizedBox(width: 12),
                            Text(
                              l10n.startScan,
                              style: GoogleFonts.cairo(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 800.ms).scale(duration: 400.ms),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyCounter(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<NutritionScanCubit, NutritionScanState>(
      buildWhen: (prev, curr) => curr is DailyScanCountLoaded,
      builder: (context, state) {
        if (state is DailyScanCountLoaded) {
          _dailyScanCount = state.count;
        }

        final remaining = (NutritionScanCubit.maxDailyScans - _dailyScanCount)
            .clamp(0, NutritionScanCubit.maxDailyScans);

        return GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          opacity: 0.6,
          blur: 10,
          borderRadius: 20,
          color: Colors.white,
          child: Row(
            children: [
              Icon(
                Icons.bolt_rounded,
                color: remaining > 0 ? AppTheme.appYellow : Colors.grey,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                l10n.localeName == 'ar'
                    ? "المتبقي: $remaining / ${NutritionScanCubit.maxDailyScans}"
                    : "Remains: $remaining / ${NutritionScanCubit.maxDailyScans}",
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryBadge(BuildContext context, AppLocalizations l10n) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.recentScans),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        opacity: 0.6,
        blur: 10,
        borderRadius: 20,
        color: Colors.white,
        child: Row(
          children: [
            const Icon(
              Icons.history_rounded,
              color: AppTheme.appBlue,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              l10n.viewHistory,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.appBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoStep({
    required int index,
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
    required bool isAr,
  }) {
    return GlassCard(
          padding: const EdgeInsets.all(22),
          opacity: 0.15,
          blur: 25,
          borderRadius: 30,
          color: Colors.white,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Icon(icon, color: color, size: 26)),
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
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      desc,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: Colors.black45,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(delay: (200 * index).ms)
        .slideX(begin: isAr ? 0.1 : -0.1, end: 0);
  }
}
