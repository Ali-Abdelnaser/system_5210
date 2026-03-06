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
import 'package:system_5210/core/services/step_tracker_service.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:fl_chart/fl_chart.dart';

class ActivityDetailsView extends StatefulWidget {
  const ActivityDetailsView({super.key});

  @override
  State<ActivityDetailsView> createState() => _ActivityDetailsViewState();
}

class _ActivityDetailsViewState extends State<ActivityDetailsView> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      body: BlocListener<StepTrackerCubit, StepTrackerState>(
        listener: (context, state) {
          if (state is StepTrackerLoaded && state.isGoalReached && !state.hasCelebrated) {
            _confettiController.play();
          }
        },
        child: Stack(
          children: [
            // 1. App Background
            Positioned.fill(
              child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
            ),

            // 2. Confetti
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  AppTheme.appBlue,
                  Colors.amber,
                  Colors.pink,
                  Colors.green,
                  Colors.orange,
                ],
              ),
            ),

            // 3. Main Content
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
                    AppLocalizations.of(context)!.stepTrackerTitle,
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
                            if (stepState is StepTrackerLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

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

                              final strideHeight = height;
                              final distanceKm = StepTrackerService.calculateDistanceKm(steps, strideHeight);
                              final calories = StepTrackerService.calculateCalories(steps, strideHeight, weight);
                              final activeMinutes = StepTrackerService.calculateActiveMinutes(steps);
                              final l10n = AppLocalizations.of(context)!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),

                                // 3. Main White Glass Summary Card
                                _buildMainSummaryCard(steps, l10n),

                                const SizedBox(height: 30),

                                // 5. Weekly Analysis White Glass Section
                                _buildWeeklyGlassSection(l10n, isAr),

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
                                      l10n.caloriesLabel,
                                      calories.toStringAsFixed(0),
                                      Icons.local_fire_department_rounded,
                                      const Color(0xFFFF5F5F),
                                      isAr,
                                    ),
                                    _buildStatGlassCard(
                                      l10n.distanceLabel,
                                      distanceKm.toStringAsFixed(1),
                                      Icons.straighten_rounded,
                                      const Color(0xFF2ECC71),
                                      isAr,
                                    ),
                                    _buildStatGlassCard(
                                      l10n.activeTimeLabel,
                                      activeMinutes.toString(),
                                      Icons.bolt_rounded,
                                      const Color(0xFFF1C40F),
                                      isAr,
                                    ),
                                    _buildStatGlassCard(
                                      l10n.powerIndexLabel,
                                      steps >= StepTrackerService.goalThreshold ? 'Level 5' : 'Level 4',
                                      Icons.auto_awesome_rounded,
                                      const Color(0xFF9B59B6),
                                      isAr,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 30),

                                // 6. Navigation CTA
                                _buildUpgradeHeroCTA(context, l10n, isAr),

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
      ),
    );
  }

  Widget _buildMainSummaryCard(int steps, AppLocalizations l10n) {
    final isAr = l10n.localeName == 'ar';
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
                    l10n.totalSteps,
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
                        constraints.maxWidth * (math.min(steps / StepTrackerService.goalThreshold, 1.0)),
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
                l10n.stepsGoal(StepTrackerService.goalThreshold.toString()),
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
                  '${((steps / StepTrackerService.goalThreshold) * 100).toStringAsFixed(0)}%',
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

  Widget _buildWeeklyGlassSection(AppLocalizations l10n, bool isAr) {
    return BlocBuilder<StepTrackerCubit, StepTrackerState>(
      builder: (context, stepState) {
        Map<String, int> history = <String, int>{};
        if (stepState is StepTrackerLoaded) {
          history = stepState.weeklySteps;
        }

        // Generate last 7 days
        final List<Map<String, dynamic>> dailyData = [];
        final now = DateTime.now();

        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final dateStr = StepTrackerService.formatDate(date);
          final steps = history[dateStr] ?? 0;
          
          String labelEn = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][(date.weekday - 1) % 7];
          String labelAr = ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح'][(date.weekday - 1) % 7];
          String fullDayAr = ['الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'][(date.weekday - 1) % 7];
          String fullDayEn = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][(date.weekday - 1) % 7];

          dailyData.add({
            'steps': steps,
            'label': isAr ? labelAr : labelEn,
            'fullName': isAr ? fullDayAr : fullDayEn,
            'isToday': i == 0,
            'date': dateStr,
          });
        }

        final weeklySteps = dailyData.map((e) => e['steps'] as int).toList();

        return GlassCard(
          blur: 25,
          opacity: 0.8,
          borderRadius: 35,
          color: Colors.white,
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.weeklyAnalysis,
                        style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                          color: AppTheme.appBlue,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isAr ? 'آخر ٧ أيام من نشاطك' : 'Your last 7 days of activity',
                        style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                          color: Colors.black45,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.appBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.insights_rounded,
                      color: AppTheme.appBlue,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 35),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: math.max(
                          weeklySteps.reduce(math.max).toDouble(),
                          StepTrackerService.goalThreshold.toDouble(),
                        ) *
                        1.2,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => AppTheme.appBlue.withOpacity(0.9),
                        tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${rod.toY.round()}\n${isAr ? 'خطوة' : 'steps'}',
                            GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= dailyData.length) {
                              return const SizedBox.shrink();
                            }
                            final isToday = dailyData[index]['isToday'];
                            return Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                dailyData[index]['label'],
                                style: GoogleFonts.poppins(
                                  color: isToday ? AppTheme.appBlue : Colors.black45,
                                  fontSize: 13,
                                  fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                                ),
                              ),
                            );
                          },
                          reservedSize: 32,
                        ),
                      ),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(dailyData.length, (index) {
                      final isToday = dailyData[index]['isToday'];
                      final steps = dailyData[index]['steps'].toDouble();
                      final isReached = steps >= StepTrackerService.goalThreshold;
 
                      return BarChartGroupData(
                        x: index,
                        showingTooltipIndicators: steps > 0 ? [0] : [],
                        barRods: [
                          BarChartRodData(
                            toY: steps,
                            gradient: LinearGradient(
                              colors: isToday
                                  ? [AppTheme.appBlue, AppTheme.appBlue.withOpacity(0.7)]
                                  : isReached
                                      ? [const Color(0xFF2ECC71), const Color(0xFF27AE60)]
                                      : [const Color(0xFFCBD5E1), const Color(0xFF94A3B8)],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            width: 20,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: StepTrackerService.goalThreshold.toDouble(),
                              color: const Color(0xFFF1F5F9),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Divider(color: Colors.black12, height: 1),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    isAr ? 'المتوسط' : 'Average',
                    (weeklySteps.reduce((a, b) => a + b) / 7).round().toString(),
                    Icons.analytics_outlined,
                    isAr,
                  ),
                  _buildSummaryItem(
                    isAr ? 'أفضل يوم' : 'Best Day',
                    weeklySteps.isEmpty ? '0' : weeklySteps.reduce(math.max).toString(),
                    Icons.star_outline_rounded,
                    isAr,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              
              // 7. Daily History Detail List
              _buildDailyDetailList(dailyData, isAr),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, bool isAr) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.appBlue),
            const SizedBox(width: 6),
            Text(
              label,
              style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                color: Colors.black54,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.dynaPuff(
            color: AppTheme.appBlue,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyDetailList(List<Map<String, dynamic>> dailyData, bool isAr) {
    return Column(
      children: dailyData.reversed.map((data) {
        final int steps = data['steps'];
        final bool isReached = steps >= StepTrackerService.goalThreshold;
        final double progress = (steps / StepTrackerService.goalThreshold).clamp(0.0, 1.0);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.appBlue.withOpacity(0.03),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: data['isToday'] ? AppTheme.appBlue.withOpacity(0.2) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isReached 
                      ? [const Color(0xFF2ECC71), const Color(0xFF27AE60)]
                      : [AppTheme.appBlue.withOpacity(0.1), AppTheme.appBlue.withOpacity(0.2)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    data['label'],
                    style: GoogleFonts.poppins(
                      color: isReached ? Colors.white : AppTheme.appBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['fullName'],
                      style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data['date'],
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    steps.toString(),
                    style: GoogleFonts.dynaPuff(
                      color: isReached ? const Color(0xFF27AE60) : AppTheme.appBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    isAr ? 'خطوة' : 'steps',
                    style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      fontSize: 10,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUpgradeHeroCTA(BuildContext context, AppLocalizations l10n, bool isAr) {
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
                    l10n.heroEvolution,
                    style: (isAr ? GoogleFonts.cairo : GoogleFonts.poppins)(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    l10n.heroEvolutionDesc,
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
