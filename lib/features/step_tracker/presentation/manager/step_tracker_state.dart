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
  const StepTrackerLoaded({required this.steps});

  @override
  List<Object?> get props => [steps];
}

class StepTrackerFailure extends StepTrackerState {
  final String message;
  const StepTrackerFailure(this.message);

  @override
  List<Object?> get props => [message];
}
