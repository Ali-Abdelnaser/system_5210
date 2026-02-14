class GameStatsModel {
  final int totalPlays;
  final int balancedPlays;
  final int unbalancedPlays;
  final DateTime? lastPlayedAt;
  final int? stars3Count;

  GameStatsModel({
    required this.totalPlays,
    required this.balancedPlays,
    required this.unbalancedPlays,
    this.lastPlayedAt,
    this.stars3Count,
  });

  factory GameStatsModel.fromJson(Map<String, dynamic> json) {
    return GameStatsModel(
      totalPlays: json['totalPlays'] ?? 0,
      balancedPlays: json['balancedPlays'] ?? 0,
      unbalancedPlays: json['unbalancedPlays'] ?? 0,
      stars3Count: json['stars3Count'] ?? 0,
      lastPlayedAt: json['lastPlayedAt'] != null
          ? (json['lastPlayedAt'] as dynamic).toDate()
          : null,
    );
  }
}
