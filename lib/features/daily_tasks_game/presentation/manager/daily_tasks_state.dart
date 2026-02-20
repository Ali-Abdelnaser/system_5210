import 'package:equatable/equatable.dart';
import '../../data/models/daily_task_model.dart';

abstract class DailyTasksState extends Equatable {
  const DailyTasksState();

  @override
  List<Object?> get props => [];
}

class DailyTasksInitial extends DailyTasksState {}

class DailyTasksLoading extends DailyTasksState {}

class DailyTasksLoaded extends DailyTasksState {
  final List<DailyTask> tasks;
  final bool isGameStarted; // Represents "Start Your Day" being clicked

  const DailyTasksLoaded({required this.tasks, required this.isGameStarted});

  int get completedCount => tasks.where((t) => t.isCompleted).length;
  double get totalProgress => tasks.isEmpty ? 0 : completedCount / tasks.length;

  @override
  List<Object?> get props => [tasks, isGameStarted];
}

class DailyTasksFailure extends DailyTasksState {
  final String message;

  const DailyTasksFailure(this.message);

  @override
  List<Object?> get props => [message];
}
