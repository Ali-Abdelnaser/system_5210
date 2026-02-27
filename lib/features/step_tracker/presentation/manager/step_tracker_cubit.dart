import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:system_5210/core/services/step_tracker_service.dart';

part 'step_tracker_state.dart';

class StepTrackerCubit extends Cubit<StepTrackerState> {
  final StepTrackerService _stepTrackerService;
  StreamSubscription<int>? _stepsSubscription;

  StepTrackerCubit(this._stepTrackerService) : super(StepTrackerInitial());

  Future<void> init() async {
    emit(StepTrackerLoading());
    try {
      final authorized = await _stepTrackerService.authorize();
      if (authorized) {
        final initialSteps = await _stepTrackerService.getStepsToday();
        final history = await _stepTrackerService.getWeeklyHistory();

        emit(
          StepTrackerLoaded(
            steps: initialSteps,
            weeklySteps: history,
            isGoalReached: initialSteps >= StepTrackerService.goalThreshold,
          ),
        );

        _stepsSubscription?.cancel();
        _stepsSubscription = _stepTrackerService.stepsStream.listen((steps) {
          if (state is StepTrackerLoaded) {
            final currentState = state as StepTrackerLoaded;
            final newHistory = Map<String, int>.from(currentState.weeklySteps);
            final today = DateTime.now().toIso8601String().split('T')[0];
            newHistory[today] = steps;

            emit(
              StepTrackerLoaded(
                steps: steps,
                weeklySteps: newHistory,
                isGoalReached: steps >= StepTrackerService.goalThreshold,
              ),
            );
          }
        });
      } else {
        emit(StepTrackerPermissionDenied());
      }
    } catch (e) {
      emit(StepTrackerPermissionDenied());
    }
  }

  Future<void> refreshSteps() async {
    final steps = await _stepTrackerService.getStepsToday();
    final history = await _stepTrackerService.getWeeklyHistory();
    emit(
      StepTrackerLoaded(
        steps: steps,
        weeklySteps: history,
        isGoalReached: steps >= StepTrackerService.goalThreshold,
      ),
    );
  }

  @override
  Future<void> close() {
    _stepsSubscription?.cancel();
    return super.close();
  }
}
