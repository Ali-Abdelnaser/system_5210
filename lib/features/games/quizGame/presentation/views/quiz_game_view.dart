import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:system_5210/core/theme/app_theme.dart';
import 'package:system_5210/core/utils/app_images.dart';
import 'package:system_5210/features/games/quizGame/presentation/cubit/quiz_cubit.dart';
import 'package:system_5210/features/games/quizGame/presentation/cubit/quiz_state.dart';

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
        builder: (context, state) {
          if (state is QuizLoading) {
            return _buildLoadingState();
          }

          if (state is QuizGameInProgress) {
            final question = state.questions[state.currentQuestionIndex];

            return Stack(
              children: [
                // 1. App Background
                Positioned.fill(
                  child: Image.asset(
                    AppImages.authBackground,
                    fit: BoxFit.cover,
                  ),
                ),

                // 2. Animated Atmosphere (Drifting Clouds - Spread across screen)
                ...List.generate(12, (index) => _buildDriftingCloud(index)),

                SafeArea(
                  child: Column(
                    children: [
                      // 3. Premium HUD
                      _buildHUD(state),

                      const SizedBox(height: 10),

                      // 4. Progress Bar
                      _buildProgressBar(state),

                      const SizedBox(height: 20),

                      // 5. Animated Question Container
                      _buildQuestionContainer(question, state),

                      const SizedBox(height: 20),

                      // 6. Options List
                      Expanded(child: _buildOptionsGrid(question, state)),

                      // 7. Lifelines Section
                      _buildLifelines(state),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                // 8. Tutorial Overlay (If visible)
                if (state.isTutorialVisible) _buildTutorialOverlay(),
              ],
            );
          }

          return const Center(child: Text('خطأ في تحميل اللعبة'));
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

  Widget _buildDriftingCloud(int index) {
    // Distribute clouds more randomly across the whole height
    final double top = (index * 70.0) % MediaQuery.of(context).size.height;
    final double scale = 0.4 + (index % 4) * 0.25;
    final int speed = 20 + (index * 4);
    final double delay = index * 1.5;

    return Positioned(
          top: top,
          left: -300,
          child: Opacity(
            opacity: 0.5,
            child: Image.asset(AppImages.cloud, width: 250 * scale),
          ),
        )
        .animate(onPlay: (c) => c.repeat(), delay: delay.seconds)
        .moveX(
          begin: -300,
          end: 700,
          duration: speed.seconds,
          curve: Curves.linear,
        );
  }

  Widget _buildHUD(QuizGameInProgress state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              // Styled Back Button
              _buildGlassHUDItem(
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF1E293B),
                  size: 20,
                ),
                onTap: () {
                  context.read<QuizCubit>().exitGame();
                  Navigator.pop(context);
                },
              ),

              const Spacer(),

              // Points & Bonus
              _buildGlassHUDItem(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.stars_rounded,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${state.score * 100}',
                          style: GoogleFonts.cairo(
                            color: const Color(0xFF1E293B),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    if (state.bonusScore > 0)
                      Text(
                        '+${state.bonusScore} Bonus',
                        style: GoogleFonts.cairo(
                          color: AppTheme.appGreen,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Central Timer & Streak
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTimer(state),
              if (state.streakCount >= 2)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.fireplace_rounded,
                        color: Colors.orange,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'x${state.streakCount} Streak',
                        style: GoogleFonts.cairo(
                          color: Colors.orange,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ).animate().scale().shake(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassHUDItem({required Widget child, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: _buildGlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        borderRadius: 20,
        child: child,
      ),
    );
  }

  Widget _buildProgressBar(QuizGameInProgress state) {
    final progress = (state.currentQuestionIndex + 1) / state.questions.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'السؤال ${state.currentQuestionIndex + 1}',
                style: GoogleFonts.cairo(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                '${state.currentQuestionIndex + 1}/${state.questions.length}',
                style: GoogleFonts.cairo(
                  color: const Color(0xFF1E293B),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 10,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerRight,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.amber, Colors.orangeAccent],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimer(QuizGameInProgress state) {
    final isCritical = state.timerSeconds < 5;
    return _buildGlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          borderRadius: 25,
          borderColor: isCritical
              ? Colors.redAccent.withOpacity(0.5)
              : AppTheme.appGreen.withOpacity(0.3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${state.timerSeconds}',
                style: GoogleFonts.cairo(
                  color: isCritical ? Colors.redAccent : AppTheme.appGreen,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
              Text(
                'SECS',
                style: GoogleFonts.cairo(
                  color: (isCritical ? Colors.redAccent : AppTheme.appGreen)
                      .withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        )
        .animate(target: isCritical ? 1 : 0)
        .shake(hz: 4, curve: Curves.easeInOut)
        .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1));
  }

  Widget _buildGlassContainer({
    required Widget child,
    double borderRadius = 30,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? borderColor,
  }) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? Colors.white.withOpacity(0.35),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionContainer(question, QuizGameInProgress state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: _buildGlassContainer(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Text(
              question.question,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E293B),
                height: 1.4,
              ),
              textDirection: TextDirection.rtl,
            ),
            if (state.showCurrentHint)
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'تلميح: ${question.hint}',
                        style: GoogleFonts.cairo(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
              ).animate().scale(curve: Curves.easeOutBack).fadeIn(),
          ],
        ),
      ),
    ).animate().scale(curve: Curves.easeOutBack, duration: 600.ms).fadeIn();
  }

  Widget _buildOptionsGrid(question, QuizGameInProgress state) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: question.options.length,
      itemBuilder: (context, index) {
        final isCorrect = index == question.correctIndex;
        final isSelected = index == state.selectedOptionIndex;
        final isRemoved = state.currentRemovedOptions.contains(index);

        if (isRemoved) return const SizedBox.shrink();

        return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: GestureDetector(
                onTap: state.selectedOptionIndex == null && !isRemoved
                    ? () => context.read<QuizCubit>().answerQuestion(index)
                    : null,
                child: _buildOptionTile(
                  index: index,
                  label: question.options[index],
                  isSelected: isSelected,
                  isCorrect: isCorrect,
                  showFeedback: state.selectedOptionIndex != null,
                ),
              ),
            )
            .animate(
              target: isSelected && state.isLastAnswerCorrect == false ? 1 : 0,
            )
            .shake(hz: 8, curve: Curves.easeInOut);
      },
    );
  }

  Widget _buildOptionTile({
    required int index,
    required String label,
    required bool isSelected,
    required bool isCorrect,
    required bool showFeedback,
  }) {
    Color borderCol = Colors.white.withOpacity(0.35);

    if (showFeedback) {
      if (isCorrect) {
        borderCol = Colors.greenAccent;
      } else if (isSelected) {
        borderCol = Colors.redAccent;
      }
    } else if (isSelected) {
      borderCol = Colors.amber;
    }

    return Stack(
          children: [
            _buildGlassContainer(
              padding: const EdgeInsets.all(18),
              borderRadius: 20,
              borderColor: borderCol,
              child: Container(
                decoration: isCorrect && showFeedback
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.greenAccent.withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      )
                    : null,
                child: Row(
                  children: [
                    _buildOptionLabel(index, isCorrect && showFeedback),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        label,
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    if (showFeedback && isCorrect)
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.greenAccent,
                        size: 28,
                      ).animate().scale(curve: Curves.easeOutBack).fadeIn(),
                    if (showFeedback && isSelected && !isCorrect)
                      const Icon(
                        Icons.cancel_rounded,
                        color: Colors.redAccent,
                        size: 28,
                      ).animate().shake(),
                  ],
                ),
              ),
            ),
          ],
        )
        .animate(target: isCorrect && showFeedback ? 1 : 0)
        .shimmer(color: Colors.white.withOpacity(0.2), duration: 1.seconds)
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.02, 1.02),
          duration: 400.ms,
        );
  }

  Widget _buildOptionLabel(int index, bool isCorrect) {
    final labels = ['A', 'B', 'C', 'D'];
    return Container(
      width: 45,
      height: 45,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isCorrect
            ? Colors.greenAccent.withOpacity(0.3)
            : const Color(0xFF1E293B).withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: isCorrect
              ? Colors.greenAccent
              : const Color(0xFF1E293B).withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Text(
        labels[index % 4],
        style: GoogleFonts.cairo(fontWeight: FontWeight.w900, fontSize: 16),
      ),
    );
  }

  Widget _buildLifelines(QuizGameInProgress state) {
    return _buildGlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 15),
      borderRadius: 25,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLifelineBtn(
            Icons.exposure_minus_2_rounded,
            '50:50',
            state.isFiftyFiftyUsed,
            () => context.read<QuizCubit>().useFiftyFifty(),
          ),
          _buildLifelineBtn(
            Icons.timer_off_outlined,
            'تجميد',
            state.isTimeStoppedUsed,
            () => context.read<QuizCubit>().useStopTime(),
          ),
          _buildLifelineBtn(
            Icons.skip_next_rounded,
            'تخطي',
            state.isSkipUsed,
            () => context.read<QuizCubit>().useSkipQuestion(),
          ),
          _buildLifelineBtn(
            Icons.lightbulb_outline_rounded,
            'تلميح',
            state.isHintUsed,
            () => context.read<QuizCubit>().useHint(),
          ),
        ],
      ),
    );
  }

  Widget _buildLifelineBtn(
    IconData icon,
    String label,
    bool isUsed,
    VoidCallback onTap,
  ) {
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: isUsed ? null : onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUsed ? Colors.black26 : Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isUsed
                      ? Colors.transparent
                      : Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                color: isUsed ? Colors.black12 : AppTheme.appGreen,
                size: 26,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.cairo(
                color: isUsed ? Colors.black12 : AppTheme.appGreen,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResultDialog(BuildContext context, QuizGameFinished state) {
    final cubit = context.read<QuizCubit>();
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
                                    style: GoogleFonts.cairo(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.orange,
                                    ),
                                  ).animate().shimmer(),
                                ],
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:
                                      List.generate(
                                            3,
                                            (index) => Icon(
                                              index < state.stars
                                                  ? Icons.star_rounded
                                                  : Icons.star_border_rounded,
                                              color: Colors.amber,
                                              size: 55,
                                            ),
                                          )
                                          .animate(interval: 200.ms)
                                          .scale(curve: Curves.easeOutBack)
                                          .shake(),
                                ),
                                const SizedBox(height: 35),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                            color: Color(0xFF1E293B),
                                            width: 2,
                                          ),
                                          foregroundColor: const Color(
                                            0xFF1E293B,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 15,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          cubit.exitGame();
                                          Navigator.pop(dialogContext);
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'الخروج',
                                          style: GoogleFonts.cairo(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF1E293B,
                                          ),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 15,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(dialogContext);
                                          cubit.startLevel(widget.level);
                                        },
                                        child: Text(
                                          'إعادة',
                                          style: GoogleFonts.cairo(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (state.stars >= 1) ...[
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.appGreen,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 15,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(dialogContext);
                                            cubit.startLevel(widget.level + 1);
                                          },
                                          child: Text(
                                            'التالي',
                                            style: GoogleFonts.cairo(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -100,
                        child:
                            Image.asset(
                                  state.stars >= 1
                                      ? AppImages.gameSuccess3
                                      : AppImages.gameFail3,
                                  height: 220,
                                )
                                .animate()
                                .slideY(
                                  begin: 0.3,
                                  end: 0,
                                  duration: 800.ms,
                                  curve: Curves.easeOutBack,
                                )
                                .fadeIn(),
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

  Widget _buildTutorialOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(25),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.help_outline_rounded,
                size: 50,
                color: Colors.blue,
              ),
              const SizedBox(height: 15),
              Text(
                'كيف تلعب',
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 10),
              Text(
                'أجب عن الأسئلة قبل انتهاء الوقت، يمكنك استخدام المساعدات بالأسفل إذا احتجت',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(fontSize: 16),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.read<QuizCubit>().dismissTutorial(),
                  child: Text(
                    'ابدأ الآن',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildScoreDetail(String label, String value, {bool isBonus = false}) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: const Color(0xFF1E293B).withOpacity(0.6),
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 18,
            color: isBonus ? AppTheme.appGreen : const Color(0xFF1E293B),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
