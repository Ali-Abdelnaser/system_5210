class GameStatsModel {
  final int totalPlays;
  final int balancedPlays;
  final int unbalancedPlays;
  final DateTime? lastPlayedAt;

  GameStatsModel({
    required this.totalPlays,
    required this.balancedPlays,
    required this.unbalancedPlays,
    this.lastPlayedAt,
  });

  factory GameStatsModel.fromJson(Map<String, dynamic> json) {
    return GameStatsModel(
      totalPlays: json['totalPlays'] ?? 0,
      balancedPlays: json['balancedPlays'] ?? 0,
      unbalancedPlays: json['unbalancedPlays'] ?? 0,
      lastPlayedAt: json['lastPlayedAt'] != null
          ? (json['lastPlayedAt'] as dynamic).toDate()
          : null,
    );
  }
}
