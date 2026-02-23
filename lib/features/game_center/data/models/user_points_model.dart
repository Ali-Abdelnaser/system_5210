import 'dart:convert';

class UserPointsModel {
  final int balancedPlatePoints;
  final int foodMatchingPoints;
  final int quizPoints;
  final int bondingGamePoints;
  final int dailyJourneyPoints;
  final DateTime lastUpdatedAt;

  UserPointsModel({
    this.balancedPlatePoints = 0,
    this.foodMatchingPoints = 0,
    this.quizPoints = 0,
    this.bondingGamePoints = 0,
    this.dailyJourneyPoints = 0,
    DateTime? lastUpdatedAt,
  }) : lastUpdatedAt = lastUpdatedAt ?? DateTime.now();

  int get totalPoints =>
      balancedPlatePoints +
      foodMatchingPoints +
      quizPoints +
      bondingGamePoints +
      dailyJourneyPoints;

  UserPointsModel copyWith({
    int? balancedPlatePoints,
    int? foodMatchingPoints,
    int? quizPoints,
    int? bondingGamePoints,
    int? dailyJourneyPoints,
    DateTime? lastUpdatedAt,
  }) {
    return UserPointsModel(
      balancedPlatePoints: balancedPlatePoints ?? this.balancedPlatePoints,
      foodMatchingPoints: foodMatchingPoints ?? this.foodMatchingPoints,
      quizPoints: quizPoints ?? this.quizPoints,
      bondingGamePoints: bondingGamePoints ?? this.bondingGamePoints,
      dailyJourneyPoints: dailyJourneyPoints ?? this.dailyJourneyPoints,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'balancedPlatePoints': balancedPlatePoints,
      'foodMatchingPoints': foodMatchingPoints,
      'quizPoints': quizPoints,
      'bondingGamePoints': bondingGamePoints,
      'dailyJourneyPoints': dailyJourneyPoints,
      'totalPoints': totalPoints,
      'lastUpdatedAt': lastUpdatedAt.millisecondsSinceEpoch,
    };
  }

  factory UserPointsModel.fromMap(Map<String, dynamic> map) {
    return UserPointsModel(
      balancedPlatePoints: map['balancedPlatePoints'] ?? 0,
      foodMatchingPoints: map['foodMatchingPoints'] ?? 0,
      quizPoints: map['quizPoints'] ?? 0,
      bondingGamePoints: map['bondingGamePoints'] ?? 0,
      dailyJourneyPoints: map['dailyJourneyPoints'] ?? 0,
      lastUpdatedAt: map['lastUpdatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastUpdatedAt'])
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserPointsModel.fromJson(String source) =>
      UserPointsModel.fromMap(json.decode(source));
}

class LeaderboardEntry {
  final String uid;
  final String name;
  final String? photoUrl;
  final int points;

  LeaderboardEntry({
    required this.uid,
    required this.name,
    this.photoUrl,
    required this.points,
  });

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map, String id) {
    return LeaderboardEntry(
      uid: id,
      name: map['userName'] ?? 'لاعب',
      photoUrl: map['userPhoto'],
      points: map['totalPoints'] ?? 0,
    );
  }
}
