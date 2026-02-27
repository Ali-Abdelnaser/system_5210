import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../cubit/quiz_cubit.dart';
import '../cubit/quiz_state.dart';
import 'quiz_glass_container.dart';

class QuestionContainer extends StatelessWidget {
  const QuestionContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizCubit, QuizState>(
      buildWhen: (previous, current) {
        if (current is QuizGameInProgress && previous is QuizGameInProgress) {
          return current.currentQuestionIndex !=
                  previous.currentQuestionIndex ||
              current.showCurrentHint != previous.showCurrentHint;
        }
        return current is QuizGameInProgress;
      },
      builder: (context, state) {
        if (state is! QuizGameInProgress) return const SizedBox.shrink();

        final question = state.questions[state.currentQuestionIndex];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: QuizGlassContainer(
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
      },
    );
  }
}
