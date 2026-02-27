import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_theme.dart';
import '../cubit/quiz_cubit.dart';
import '../cubit/quiz_state.dart';
import 'quiz_glass_container.dart';
import 'quiz_timer_display.dart';

class QuizHUD extends StatelessWidget {
  const QuizHUD({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizCubit, QuizState>(
      buildWhen: (previous, current) {
        if (current is QuizGameInProgress && previous is QuizGameInProgress) {
          return current.score != previous.score ||
              current.bonusScore != previous.bonusScore ||
              current.streakCount != previous.streakCount;
        }
        return current is QuizGameInProgress;
      },
      builder: (context, state) {
        if (state is! QuizGameInProgress) return const SizedBox.shrink();

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
                  const QuizTimerDisplay(),
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
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.5),
                        ),
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
      },
    );
  }

  Widget _buildGlassHUDItem({required Widget child, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: QuizGlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        borderRadius: 20,
        child: child,
      ),
    );
  }
}
