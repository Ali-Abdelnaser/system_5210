enum BondingRole { parent, child }

class BondingChallenge {
  final String id;
  final String title;
  final String description;
  final BondingRole role;
  final bool isCompleted;

  BondingChallenge({
    required this.id,
    required String title,
    required this.description,
    required this.role,
    this.isCompleted = false,
  }) : title = title.replaceAll('"', '');

  BondingChallenge copyWith({
    String? id,
    String? title,
    String? description,
    BondingRole? role,
    bool? isCompleted,
  }) {
    return BondingChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      role: role ?? this.role,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'role': role.index,
      'isCompleted': isCompleted,
    };
  }

  factory BondingChallenge.fromMap(Map<String, dynamic> map) {
    return BondingChallenge(
      id: map['id'],
      title: (map['title'] as String).replaceAll('"', ''),
      description: map['description'],
      role: BondingRole.values[map['role']],
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
