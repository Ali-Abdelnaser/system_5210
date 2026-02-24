import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/features/daily_tasks_game/presentation/widgets/glass_card.dart';
import 'package:system_5210/features/hero_lab/presentation/views/hero_lab_view.dart';
import 'package:system_5210/features/profile/presentation/manager/profile_cubit.dart';
import 'package:system_5210/features/profile/presentation/manager/profile_state.dart';
import 'package:system_5210/features/step_tracker/presentation/manager/step_tracker_cubit.dart';
import 'dart:math' as math;

class ActivityDetailsView extends StatelessWidget {
  const ActivityDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: Stack(
        children: [
          // 1. App Background
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),

          // 2. Main Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                leading: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: AppBackButton(),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                centerTitle: true,
                title: Text(
                  isAr ? 'تفاصيل النشاط' : 'Activity Details',
                  style: (isAr ? GoogleFonts.cairo : GoogleFonts.dynaPuff)(
                    color: AppTheme.appBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, profileState) {
                      return BlocBuilder<StepTrackerCubit, StepTrackerState>(
                        builder: (context, stepState) {
                          int steps = 0;
                          if (stepState is StepTrackerLoaded) {
                            steps = stepState.steps;
                          }

                          double height = 120.0;
                          double weight = 25.0;

                          if (profileState is ProfileLoaded) {
                            final quiz = profileState.profile.quizAnswers;
                            height =
                                double.tryParse(
                                  quiz['height']?.toString() ?? '120.0',
                                ) ??
                                120.0;
                            weight =
                                double.tryParse(
                                  quiz['weight']?.toString() ?? '25.0',
                                ) ??
                                25.0;
                          }

                          final strideLengthCm = height * 0.413;
                          final distanceKm = (steps * strideLengthCm) / 100000;
                          final calories = weight * distanceKm * 0.75;
                          final activeMinutes = (steps / 100).round();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),

                              // 3. Main White Glass Summary Card
                              _buildMainSummaryCard(steps, isAr),

                              const SizedBox(height: 30),

                              // 5. Weekly Analysis White Glass Section
                              _buildWeeklyGlassSection(isAr),

                              const SizedBox(height: 30),

                              // 4. Grid of detailed stats with White Glass effect
                              GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                mainAxisSpacing: 15,
                                crossAxisSpacing: 15,
                                childAspectRatio: 1.1,
                                children: [
                                  _buildStatGlassCard(
                                    isAr ? 'سعرة حرارية' : 'Calories',
                                    calories.toStringAsFixed(0),
                                    Icons.local_fire_department_rounded,
                                    const Color(0xFFFF5F5F),
                                    isAr,
                                  ),
                                  _buildStatGlassCard(
                                    isAr ? 'كيلومتر' : 'Distance',
                                    distanceKm.toStringAsFixed(1),
                                    Icons.straighten_rounded,
                                    const Color(0xFF2ECC71),
                                    isAr,
                                  ),
                                  _buildStatGlassCard(
                                    isAr ? 'دقيقة نشطة' : 'Active Time',
                                    activeMinutes.toString(),
                                    Icons.bolt_rounded,
                                    const Color(0xFFF1C40F),
                                    isAr,
                                  ),
                                  _buildStatGlassCard(
                                    isAr ? 'معدل القوة' : 'Power Index',
                                    'Level 4',
                                    Icons.auto_awesome_rounded,
                                    const Color(0xFF9B59B6),
                                    isAr,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 30),

                              // 6. Navigation CTA
                              _buildUpgradeHeroCTA(context, isAr),

                              const SizedBox(height: 50),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainSummaryCard(int steps, bool isAr) {
    return GlassCard(
      blur: 20,
      opacity: 0.8,
      borderRadius: 35,
      color: Colors.white,
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? 'إجمالي الخطوات' : "Total Steps",
                    style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      color: AppTheme.appBlue.withOpacity(0.6),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    steps.toString(),
                    style: GoogleFonts.dynaPuff(
                      color: AppTheme.appBlue,
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.appBlue.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.directions_run_rounded,
                      color: AppTheme.appBlue,
                      size: 38,
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveY(
                    begin: -4,
                    end: 4,
                    duration: 1.5.seconds,
                    curve: Curves.easeInOut,
                  ),
            ],
          ),
          const SizedBox(height: 25),
          Stack(
            children: [
              Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.appBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedContainer(
                    duration: 1.seconds,
                    height: 14,
                    width:
                        constraints.maxWidth * (math.min(steps / 10000, 1.0)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.appBlue,
                          AppTheme.appBlue.withOpacity(0.7),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.appBlue.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  );
                },
              ).animate().shimmer(duration: 2.seconds),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'الهدف: ١٠,٠٠٠' : 'Goal: 10,000',
                style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.appBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${((steps / 10000) * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.poppins(
                    color: AppTheme.appBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatGlassCard(
    String label,
    String value,
    IconData icon,
    Color iconColor,
    bool isAr,
  ) {
    return GlassCard(
      blur: 20,
      opacity: 0.7,
      borderRadius: 28,
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: AppTheme.appBlue,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
              color: Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().scale(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildWeeklyGlassSection(bool isAr) {
    final weeklySteps = [4200, 5800, 8100, 7450, 9200, 6500, 5210];
    final days = isAr
        ? ['س', 'ح', 'ن', 'ث', 'ر', 'خ', 'ج']
        : ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return GlassCard(
      blur: 20,
      opacity: 0.7,
      borderRadius: 30,
      color: Colors.white,
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAr ? 'تحليل الأسبوع' : 'Weekly Analysis',
            style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
              color: AppTheme.appBlue,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(weeklySteps.length, (index) {
              final hRatio = weeklySteps[index] / 10000;
              final isToday = index == 6;

              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 140 * hRatio.clamp(0.15, 1.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: isToday
                            ? [
                                AppTheme.appBlue.withOpacity(0.7),
                                AppTheme.appBlue,
                              ]
                            : [
                                const Color(0xFFEDF2F7),
                                const Color(0xFFCBD5E1),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: isToday
                          ? [
                              BoxShadow(
                                color: AppTheme.appBlue.withOpacity(0.2),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                  ).animate().scaleY(
                    begin: 0,
                    end: 1,
                    duration: (400 + (index * 100)).ms,
                    curve: Curves.easeOutBack,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    days[index],
                    style: GoogleFonts.poppins(
                      color: isToday ? AppTheme.appBlue : Colors.black45,
                      fontSize: 13,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeHeroCTA(BuildContext context, bool isAr) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HeroLabView()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 22),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.appBlue, AppTheme.appBlue.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppTheme.appBlue.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_fix_high_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? 'تطوير البطل' : 'Hero Evolution',
                    style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isAr
                        ? 'حدث بياناتك لقوة أكبر'
                        : 'Update stats for power boost',
                    style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 3.seconds);
  }
}
