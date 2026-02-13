import 'package:cloud_firestore/cloud_firestore.dart';

class GameResultModel {
  final String gameId;
  final DateTime playedAt;
  final List<String> selectedIngredientsIds;
  final bool isBalanced;
  final int healthyCount;
  final int unhealthyCount;
  final int stars;

  GameResultModel({
    required this.gameId,
    required this.playedAt,
    required this.selectedIngredientsIds,
    required this.isBalanced,
    required this.healthyCount,
    required this.unhealthyCount,
    required this.stars,
  });

  Map<String, dynamic> toJson() {
    return {
      'gameId': gameId,
      'playedAt': Timestamp.fromDate(playedAt),
      'selectedIngredientsIds': selectedIngredientsIds,
      'isBalanced': isBalanced,
      'healthyCount': healthyCount,
      'unhealthyCount': unhealthyCount,
      'stars': stars,
    };
  }

  factory GameResultModel.fromJson(Map<String, dynamic> json) {
    return GameResultModel(
      gameId: json['gameId'],
      playedAt: (json['playedAt'] as Timestamp).toDate(),
      selectedIngredientsIds: List<String>.from(json['selectedIngredientsIds']),
      isBalanced: json['isBalanced'],
      healthyCount: json['healthyCount'],
      unhealthyCount: json['unhealthyCount'],
      stars: json['stars'] ?? 0,
    );
  }
}
