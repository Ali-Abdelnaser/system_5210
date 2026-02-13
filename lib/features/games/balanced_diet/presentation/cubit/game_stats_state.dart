import 'package:equatable/equatable.dart';
import '../../data/models/game_result_model.dart';
import '../../data/models/game_stats_model.dart';

abstract class GameStatsState extends Equatable {
  const GameStatsState();

  @override
  List<Object?> get props => [];
}

class GameStatsInitial extends GameStatsState {}

class GameStatsLoading extends GameStatsState {}

class GameStatsLoaded extends GameStatsState {
  final GameStatsModel stats;
  final List<GameResultModel> history;

  const GameStatsLoaded({required this.stats, required this.history});

  @override
  List<Object?> get props => [stats, history];
}

class GameStatsFailure extends GameStatsState {
  final String message;

  const GameStatsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
