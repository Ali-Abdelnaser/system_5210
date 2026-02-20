class BondingMemory {
  final String id;
  final String title;
  final String date;
  final List<String> photoPaths;
  final String roleName;

  const BondingMemory({
    required this.id,
    required this.title,
    required this.date,
    required this.photoPaths,
    required this.roleName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date,
      'photoPaths': photoPaths,
      'roleName': roleName,
    };
  }

  factory BondingMemory.fromMap(Map<dynamic, dynamic> map) {
    return BondingMemory(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      date: map['date'] ?? '',
      photoPaths: List<String>.from(map['photoPaths'] ?? []),
      roleName: map['roleName'] ?? '',
    );
  }
}
