class HealthyInsight {
  final String id;
  final String question;
  final String answer;
  final String sourceLink;
  final String sourceName;
  final String category;

  const HealthyInsight({
    this.id = '',
    required this.question,
    required this.answer,
    required this.sourceLink,
    required this.sourceName,
    required this.category,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'question': question,
      'answer': answer,
      'sourceLink': sourceLink,
      'sourceName': sourceName,
      'category': category,
    };
  }

  factory HealthyInsight.fromFirestore(Map<String, dynamic> data, String id) {
    return HealthyInsight(
      id: id,
      question: data['question'] ?? '',
      answer: data['answer'] ?? '',
      sourceLink: data['sourceLink'] ?? '',
      sourceName: data['sourceName'] ?? '',
      category: data['category'] ?? 'الصحة العامة',
    );
  }
}
