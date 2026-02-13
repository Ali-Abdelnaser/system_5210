import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/game_repository.dart';
import 'game_stats_state.dart';

class GameStatsCubit extends Cubit<GameStatsState> {
  final GameRepository repository;
  final FirebaseAuth auth;

  GameStatsCubit({required this.repository, required this.auth})
    : super(GameStatsInitial());

  Future<void> loadStats() async {
    final user = auth.currentUser;
    if (user == null) {
      emit(const GameStatsFailure('User not logged in'));
      return;
    }

    emit(GameStatsLoading());

    final statsResult = await repository.getGameStats(user.uid);
    final historyResult = await repository.getGameHistory(user.uid);

    statsResult.fold((failure) => emit(GameStatsFailure(failure)), (stats) {
      historyResult.fold(
        (failure) => emit(GameStatsFailure(failure)),
        (history) => emit(GameStatsLoaded(stats: stats, history: history)),
      );
    });
  }
}
