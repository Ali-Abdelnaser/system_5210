part of 'step_tracker_cubit.dart';

abstract class StepTrackerState extends Equatable {
  const StepTrackerState();

  @override
  List<Object?> get props => [];
}

class StepTrackerInitial extends StepTrackerState {}

class StepTrackerLoading extends StepTrackerState {}

class StepTrackerLoaded extends StepTrackerState {
  final int steps;
  final Map<String, int> weeklySteps;
  final bool isGoalReached;
  final bool hasCelebrated;

  const StepTrackerLoaded({
    required this.steps,
    this.weeklySteps = const <String, int>{},
    this.isGoalReached = false,
    this.hasCelebrated = false,
  });

  @override
  List<Object?> get props => [steps, weeklySteps, isGoalReached, hasCelebrated];
}

class StepTrackerPermissionDenied extends StepTrackerState {}

class StepTrackerFailure extends StepTrackerState {
  final String message;
  const StepTrackerFailure(this.message);

  @override
  List<Object?> get props => [message];
}
