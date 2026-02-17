import 'package:equatable/equatable.dart';

class QuizQuestion extends Equatable {
  final int id;
  final int level;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? hint;

  const QuizQuestion({
    required this.id,
    required this.level,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.hint,
  });

  @override
  List<Object?> get props => [id, level, question, options, correctIndex, hint];
}
