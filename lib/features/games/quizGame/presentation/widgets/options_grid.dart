import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../cubit/quiz_cubit.dart';
import '../cubit/quiz_state.dart';
import 'quiz_glass_container.dart';

class OptionsGrid extends StatelessWidget {
  const OptionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizCubit, QuizState>(
      buildWhen: (previous, current) {
        if (current is QuizGameInProgress && previous is QuizGameInProgress) {
          return current.currentQuestionIndex !=
                  previous.currentQuestionIndex ||
              current.selectedOptionIndex != previous.selectedOptionIndex ||
              current.currentRemovedOptions != previous.currentRemovedOptions ||
              current.isLastAnswerCorrect != previous.isLastAnswerCorrect;
        }
        return current is QuizGameInProgress;
      },
      builder: (context, state) {
        if (state is! QuizGameInProgress) return const SizedBox.shrink();

        final question = state.questions[state.currentQuestionIndex];
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
                    child: _OptionTile(
                      index: index,
                      label: question.options[index],
                      isSelected: isSelected,
                      isCorrect: isCorrect,
                      showFeedback: state.selectedOptionIndex != null,
                    ),
                  ),
                )
                .animate(
                  target: isSelected && state.isLastAnswerCorrect == false
                      ? 1
                      : 0,
                )
                .shake(hz: 8, curve: Curves.easeInOut);
          },
        );
      },
    );
  }
}

class _OptionTile extends StatelessWidget {
  final int index;
  final String label;
  final bool isSelected;
  final bool isCorrect;
  final bool showFeedback;

  const _OptionTile({
    required this.index,
    required this.label,
    required this.isSelected,
    required this.isCorrect,
    required this.showFeedback,
  });

  @override
  Widget build(BuildContext context) {
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
            QuizGlassContainer(
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
}
