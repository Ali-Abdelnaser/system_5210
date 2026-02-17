import '../../domain/entities/quiz_question_entity.dart';

class QuizQuestionModel extends QuizQuestion {
  const QuizQuestionModel({
    required super.id,
    required super.level,
    required super.question,
    required super.options,
    required super.correctIndex,
    super.hint,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      id: json['id'],
      level: json['level'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctIndex: json['correct_index'],
      hint: json['hint'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'level': level,
      'question': question,
      'options': options,
      'correct_index': correctIndex,
      'hint': hint,
    };
  }
}
