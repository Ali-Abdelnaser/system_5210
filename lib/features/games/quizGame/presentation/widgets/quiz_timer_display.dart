import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_theme.dart';
import '../cubit/quiz_cubit.dart';
import '../cubit/quiz_state.dart';
import 'quiz_glass_container.dart';

class QuizTimerDisplay extends StatelessWidget {
  const QuizTimerDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizCubit, QuizState>(
      buildWhen: (previous, current) {
        if (current is QuizGameInProgress && previous is QuizGameInProgress) {
          return current.timerSeconds != previous.timerSeconds;
        }
        return current is QuizGameInProgress;
      },
      builder: (context, state) {
        if (state is! QuizGameInProgress) return const SizedBox.shrink();

        final isCritical = state.timerSeconds < 5;
        return QuizGlassContainer(
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
      },
    );
  }
}
