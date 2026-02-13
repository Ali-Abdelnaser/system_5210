import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/features/home/presentation/widgets/daily_quest_card.dart';
import 'package:system_5210/l10n/app_localizations.dart';
import '../widgets/counter_dialog.dart';
import '../widgets/slider_dialog.dart';
import 'package:system_5210/core/widgets/app_back_button.dart';
import 'package:system_5210/core/utils/app_alerts.dart';

class DailyChallengeView extends StatefulWidget {
  const DailyChallengeView({super.key});

  @override
  State<DailyChallengeView> createState() => _DailyChallengeViewState();
}

class _DailyChallengeViewState extends State<DailyChallengeView> {
  // State Variables
  int _fruitCount = 0; // Target: 5
  double _screenTimeMinutes = 0; // Limit: 120 (2 hours)
  double _activityMinutes = 0; // Goal: 60 (1 hour)
  int _sugaryDrinksCount = 0; // Limit: 0

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Progress Calculations
    double fruitProgress = (_fruitCount / 5).clamp(0.0, 1.0);
    double screenProgress = (_screenTimeMinutes / 120).clamp(0.0, 1.0);
    double activityProgress = (_activityMinutes / 60).clamp(0.0, 1.0);
    double sugaryProgress = _sugaryDrinksCount == 0
        ? 1.0
        : (1.0 / (_sugaryDrinksCount + 1));

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          l10n.dailyTarget,
          style: GoogleFonts.dynaPuff(
            color: const Color(0xFF2D3142),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        toolbarHeight: 50,
        leading: const AppBackButton(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
        children: [
          // 5 - Fruits & Veggies
          DailyQuestCard(
            number: '5',
            title: l10n.onboardingTitle5,
            imagePath: AppImages.character1,
            color: AppTheme.appRed,
            progress: fruitProgress,
            progressText: l10n.servingsProgress(_fruitCount, 5),
            onTap: () {},
            onIncrement: () => _openCounterDialog(
              context: context,
              title: l10n.onboardingTitle5,
              color: AppTheme.appRed,
              initialValue: _fruitCount,
              unit: l10n.servings,
              onSave: (val) => setState(() => _fruitCount = val),
            ),
          ).animate().slideX(begin: 0.1, delay: 100.ms).fadeIn(),
          const SizedBox(height: 16),

          // 2 - Screen Time
          DailyQuestCard(
            number: '2',
            title: l10n.onboardingTitle2,
            imagePath: AppImages.character2,
            color: AppTheme.appYellow,
            progress: screenProgress,
            progressText:
                "${_formatDuration(_screenTimeMinutes, l10n)} / 2h ${l10n.limit}",
            onTap: () {},
            onIncrement: () => _openSliderDialog(
              context: context,
              title: l10n.onboardingTitle2,
              color: AppTheme.appYellow,
              initialValue: _screenTimeMinutes,
              max: 120,
              onSave: (val) => setState(() => _screenTimeMinutes = val),
            ),
          ).animate().slideX(begin: 0.1, delay: 200.ms).fadeIn(),
          const SizedBox(height: 16),

          // 1 - Physical Activity
          DailyQuestCard(
            number: '1',
            title: l10n.onboardingTitle1,
            imagePath: AppImages.character4,
            color: AppTheme.appGreen,
            progress: activityProgress,
            progressText:
                "${_formatDuration(_activityMinutes, l10n)} / 1h ${l10n.goal}",
            onTap: () {},
            onIncrement: () => _openSliderDialog(
              context: context,
              title: l10n.onboardingTitle1,
              color: AppTheme.appGreen,
              initialValue: _activityMinutes,
              max: 180, // Allow up to 3 hours
              onSave: (val) => setState(() => _activityMinutes = val),
            ),
          ).animate().slideX(begin: 0.1, delay: 300.ms).fadeIn(),
          const SizedBox(height: 16),

          // 0 - Sugary Drinks
          DailyQuestCard(
            number: '0',
            title: l10n.onboardingTitle0,
            imagePath: AppImages.character3,
            color: AppTheme.appBlue,
            progress: sugaryProgress,
            progressText: l10n.drinksProgress(_sugaryDrinksCount),
            onTap: () {},
            onIncrement: () => _openCounterDialog(
              context: context,
              title: l10n.onboardingTitle0,
              color: AppTheme.appBlue,
              initialValue: _sugaryDrinksCount,
              unit: l10n.drinks,
              isBadHabit: true,
              onSave: (val) => setState(() => _sugaryDrinksCount = val),
            ),
          ).animate().slideX(begin: 0.1, delay: 400.ms).fadeIn(),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  String _formatDuration(double minutes, AppLocalizations l10n) {
    int h = minutes ~/ 60;
    int m = minutes.toInt() % 60;
    if (h > 0) {
      return l10n.durationFormat(h, m);
    }
    return l10n.minutesFormat(m);
  }

  void _openCounterDialog({
    required BuildContext context,
    required String title,
    required Color color,
    required int initialValue,
    required String unit,
    required Function(int) onSave,
    bool isBadHabit = false,
  }) {
    AppAlerts.showAppDialog(
      context,
      child: CounterDialog(
        title: title,
        color: color,
        initialValue: initialValue,
        unit: unit,
        isBadHabit: isBadHabit,
        onSave: onSave,
      ),
    );
  }

  void _openSliderDialog({
    required BuildContext context,
    required String title,
    required Color color,
    required double initialValue,
    required double max,
    required Function(double) onSave,
  }) {
    AppAlerts.showAppDialog(
      context,
      child: SliderDialog(
        title: title,
        color: color,
        initialValue: initialValue,
        max: max,
        onSave: onSave,
      ),
    );
  }
}
