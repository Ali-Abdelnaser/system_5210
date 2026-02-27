import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_theme.dart';
import '../cubit/quiz_cubit.dart';
import '../cubit/quiz_state.dart';
import 'quiz_glass_container.dart';

class QuizLifelines extends StatelessWidget {
  const QuizLifelines({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizCubit, QuizState>(
      buildWhen: (previous, current) {
        if (current is QuizGameInProgress && previous is QuizGameInProgress) {
          return current.isFiftyFiftyUsed != previous.isFiftyFiftyUsed ||
              current.isTimeStoppedUsed != previous.isTimeStoppedUsed ||
              current.isSkipUsed != previous.isSkipUsed ||
              current.isHintUsed != previous.isHintUsed;
        }
        return current is QuizGameInProgress;
      },
      builder: (context, state) {
        if (state is! QuizGameInProgress) return const SizedBox.shrink();

        return QuizGlassContainer(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 15),
          borderRadius: 25,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLifelineBtn(
                context,
                Icons.exposure_minus_2_rounded,
                '50:50',
                state.isFiftyFiftyUsed,
                () => context.read<QuizCubit>().useFiftyFifty(),
              ),
              _buildLifelineBtn(
                context,
                Icons.timer_off_outlined,
                'تجميد',
                state.isTimeStoppedUsed,
                () => context.read<QuizCubit>().useStopTime(),
              ),
              _buildLifelineBtn(
                context,
                Icons.skip_next_rounded,
                'تخطي',
                state.isSkipUsed,
                () => context.read<QuizCubit>().useSkipQuestion(),
              ),
              _buildLifelineBtn(
                context,
                Icons.lightbulb_outline_rounded,
                'تلميح',
                state.isHintUsed,
                () => context.read<QuizCubit>().useHint(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLifelineBtn(
    BuildContext context,
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
}
