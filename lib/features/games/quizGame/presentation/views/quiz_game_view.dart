import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:five2ten/core/utils/app_images.dart';
import 'package:five2ten/features/games/quizGame/presentation/cubit/quiz_cubit.dart';
import 'package:five2ten/features/games/quizGame/presentation/cubit/quiz_state.dart';
import '../widgets/drifting_cloud.dart';
import '../widgets/quiz_hud.dart';
import '../widgets/quiz_progress_bar.dart';
import '../widgets/question_container.dart';
import '../widgets/options_grid.dart';
import '../widgets/quiz_lifelines.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:five2ten/core/theme/app_theme.dart';

class QuizGameView extends StatefulWidget {
  final int level;
  const QuizGameView({super.key, required this.level});

  @override
  State<QuizGameView> createState() => _QuizGameViewState();
}

class _QuizGameViewState extends State<QuizGameView> {
  @override
  void initState() {
    super.initState();
    context.read<QuizCubit>().startLevel(widget.level);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<QuizCubit, QuizState>(
        listener: (context, state) {
          if (state is QuizGameFinished) {
            _showResultDialog(context, state);
          }
        },
        buildWhen: (previous, current) {
          // Only rebuild the main structure if the major state type changes
          return previous.runtimeType != current.runtimeType;
        },
        builder: (context, state) {
          if (state is QuizLoading) {
            return _buildLoadingState();
          }

          if (state is QuizGameInProgress) {
            return Stack(
              children: [
                // 1. App Background
                Positioned.fill(
                  child: Image.asset(
                    AppImages.authBackground,
                    fit: BoxFit.cover,
                  ),
                ),

                // 2. Animated Atmosphere (Drifting Clouds)
                ...List.generate(12, (index) => DriftingCloud(index: index)),

                SafeArea(
                  child: Column(
                    children: [
                      const QuizHUD(),
                      const SizedBox(height: 10),
                      const QuizProgressBar(),
                      const SizedBox(height: 20),
                      const QuestionContainer(),
                      const SizedBox(height: 20),
                      const Expanded(child: OptionsGrid()),
                      const QuizLifelines(),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                // 8. Tutorial Overlay (If visible)
                BlocBuilder<QuizCubit, QuizState>(
                  buildWhen: (prev, curr) =>
                      (prev is QuizGameInProgress &&
                      curr is QuizGameInProgress &&
                      prev.isTutorialVisible != curr.isTutorialVisible),
                  builder: (context, state) {
                    if (state is QuizGameInProgress &&
                        state.isTutorialVisible) {
                      return _buildTutorialOverlay();
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            );
          }

          if (state is QuizError) {
            return _buildErrorState(state.message);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF1E293B)),
              const SizedBox(height: 20),
              Text(
                'جاري تحضير الأسئلة...',
                style: GoogleFonts.cairo(
                  color: const Color(0xFF1E293B),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.cairo(fontSize: 18)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('عودة'),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(),
                Text(
                  'طريقة اللعب',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 40),
                _buildTutorialItem(
                  Icons.timer_outlined,
                  'أجب بسرعة لتحصل على نقاط إضافية',
                ),
                _buildTutorialItem(
                  Icons.auto_awesome_rounded,
                  'استخدم المساعدات بحكمة، فعدم استخدامها يمنحك بونص كبير',
                ),
                _buildTutorialItem(
                  Icons.fireplace_rounded,
                  'حافظ على سلسلة الإجابات الصحيحة لمضاعفة نقاطك',
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ElevatedButton(
                    onPressed: () =>
                        context.read<QuizCubit>().dismissTutorial(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.appGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(
                      'أنا جاهز!',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTutorialItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.appGreen.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.appGreen.withOpacity(0.5)),
            ),
            child: Icon(icon, color: AppTheme.appGreen, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.2, end: 0);
  }

  void _showResultDialog(BuildContext context, QuizGameFinished state) {
    // Note: This dialog uses state data, so we don't need a separate BlocBuilder here
    // because it's called once when the state type changes.
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Result',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (dialogContext, animation, secondaryAnimation) => Stack(
        children: [
          // 1. Full Screen Background
          Positioned.fill(
            child: Image.asset(AppImages.authBackground, fit: BoxFit.cover),
          ),
          // 2. Blur and Content Overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: animation.drive(
                  Tween(
                    begin: 0.8,
                    end: 1.0,
                  ).chain(CurveTween(curve: Curves.easeOutBack)),
                ),
                child: Dialog(
                  backgroundColor: Colors.transparent,
                  insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      // Premium Glass Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(25, 100, 25, 30),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.5),
                                  Colors.white.withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 2.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  state.stars >= 2 ? 'مذهل 🎉' : 'أداء جيد 👍',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.cairo(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.appGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppTheme.appGreen.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        '${(state.score * 100) + state.bonusScore}',
                                        style: GoogleFonts.cairo(
                                          fontSize: 42,
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.appGreen,
                                        ),
                                      ),
                                      Text(
                                        'مجموع النقاط',
                                        style: GoogleFonts.cairo(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.appGreen.withOpacity(
                                            0.7,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 15),
                                // Score Breakdown
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildScoreDetail(
                                      'الأساسي',
                                      '${state.score * 100}',
                                    ),
                                    _buildScoreDetail(
                                      'بونص',
                                      '${state.bonusScore}',
                                      isBonus: true,
                                    ),
                                  ],
                                ),
                                if (state.noAidsBonus > 0) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '✨ +${state.noAidsBonus} بونص عدم استخدام مساعدات ✨',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.cairo(
                                      color: Colors.amber[800],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 30),
                                // Action Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildActionBtn(
                                        'الخروج',
                                        Colors.grey[200]!,
                                        const Color(0xFF1E293B),
                                        () {
                                          Navigator.pop(dialogContext);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: _buildActionBtn(
                                        'المستوى التالي',
                                        AppTheme.appGreen,
                                        Colors.white,
                                        () {
                                          Navigator.pop(dialogContext);
                                          if (state.level < 14) {
                                            context
                                                .read<QuizCubit>()
                                                .startLevel(state.level + 1);
                                          } else {
                                            Navigator.pop(context);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Floating Header Image
                      Positioned(
                        top: -80,
                        child: Image.asset(
                          state.stars >= 2
                              ? AppImages.gameSuccess1
                              : AppImages.gameSuccess2,
                          width: 180,
                        ).animate().shimmer(duration: 800.ms),
                      ),
                      // Stars Row
                      Positioned(
                        top: 60,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(3, (i) {
                            final hasStar = i < state.stars;
                            return Icon(
                                  hasStar
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  color: Colors.amber,
                                  size: 45,
                                )
                                .animate(delay: (200 * i).ms)
                                .scale(curve: Curves.easeOutBack);
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDetail(String label, String value, {bool isBonus = false}) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: const Color(0xFF1E293B).withOpacity(0.6),
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: isBonus ? AppTheme.appGreen : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildActionBtn(String label, Color bg, Color fg, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        padding: const EdgeInsets.symmetric(vertical: 15),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
