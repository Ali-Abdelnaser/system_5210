import 'dart:convert';

enum DailyTaskType { breakfast, fruitGame, water, movement, lunch, sleep }

class DailyTask {
  final DailyTaskType type;
  final String title;
  final bool isCompleted;
  final String? imagePath; // For breakfast/lunch
  final double progress; // For water/movement
  final DateTime? sleepStartTime;
  final DateTime? wakeUpTime;

  DailyTask({
    required this.type,
    required this.title,
    this.isCompleted = false,
    this.imagePath,
    this.progress = 0.0,
    this.sleepStartTime,
    this.wakeUpTime,
  });

  DailyTask copyWith({
    bool? isCompleted,
    String? imagePath,
    double? progress,
    DateTime? sleepStartTime,
    DateTime? wakeUpTime,
  }) {
    return DailyTask(
      type: type,
      title: title,
      isCompleted: isCompleted ?? this.isCompleted,
      imagePath: imagePath ?? this.imagePath,
      progress: progress ?? this.progress,
      sleepStartTime: sleepStartTime ?? this.sleepStartTime,
      wakeUpTime: wakeUpTime ?? this.wakeUpTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.index,
      'title': title,
      'isCompleted': isCompleted,
      'imagePath': imagePath,
      'progress': progress,
      'sleepStartTime': sleepStartTime?.millisecondsSinceEpoch,
      'wakeUpTime': wakeUpTime?.millisecondsSinceEpoch,
    };
  }

  factory DailyTask.fromMap(Map<String, dynamic> map) {
    return DailyTask(
      type: DailyTaskType.values[map['type']],
      title: map['title'],
      isCompleted: map['isCompleted'] ?? false,
      imagePath: map['imagePath'],
      progress: (map['progress'] ?? 0.0).toDouble(),
      sleepStartTime: map['sleepStartTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['sleepStartTime'])
          : null,
      wakeUpTime: map['wakeUpTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['wakeUpTime'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory DailyTask.fromJson(String source) =>
      DailyTask.fromMap(json.decode(source));
}
