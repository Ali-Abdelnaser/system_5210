import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_5210/features/game_center/presentation/manager/user_points_cubit.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../data/models/daily_task_model.dart';
import 'daily_tasks_state.dart';

class DailyTasksCubit extends Cubit<DailyTasksState> {
  final LocalStorageService _storageService;
  final UserPointsCubit pointsCubit;
  static const String _boxName = 'daily_tasks_box';
  static const String _tasksKey = 'daily_tasks_list';
  static const String _startedKey = 'is_game_started';
  static const String _lastResetKey = 'last_reset_time';

  DailyTasksCubit(this._storageService, this.pointsCubit)
    : super(DailyTasksInitial());

  Future<void> init() async {
    emit(DailyTasksLoading());
    try {
      await _checkAndResetDaily();
      await _loadState();
    } catch (e) {
      emit(const DailyTasksFailure('Failed to load tasks'));
    }
  }

  Future<void> _checkAndResetDaily() async {
    final lastResetData = await _storageService.get(_boxName, _lastResetKey);
    final DateTime lastReset = lastResetData != null
        ? DateTime.fromMillisecondsSinceEpoch(lastResetData['time'])
        : DateTime(2000);

    final DateTime now = DateTime.now();
    final DateTime today12PM = DateTime(now.year, now.month, now.day, 12);

    bool needsReset = false;
    if (now.isAfter(today12PM)) {
      if (lastReset.isBefore(today12PM)) {
        needsReset = true;
      }
    } else {
      final DateTime yesterday12PM = today12PM.subtract(
        const Duration(days: 1),
      );
      if (lastReset.isBefore(yesterday12PM)) {
        needsReset = true;
      }
    }

    if (needsReset) {
      await _resetTasks();
      await _storageService.save(_boxName, _lastResetKey, {
        'time': now.millisecondsSinceEpoch,
      });
    }
  }

  Future<void> resetTasksManually() async {
    await _resetTasks();
    await _storageService.save(_boxName, _lastResetKey, {
      'time': DateTime.now().millisecondsSinceEpoch,
    });
    await _loadState();
  }

  Future<void> _resetTasks() async {
    final List<DailyTask> initialTasks = [
      DailyTask(type: DailyTaskType.breakfast, title: 'الفطار'),
      DailyTask(type: DailyTaskType.fruitGame, title: 'تجميع الفاكهة'),
      DailyTask(type: DailyTaskType.water, title: 'شرب الماء'),
      DailyTask(type: DailyTaskType.movement, title: 'الحركة'),
      DailyTask(type: DailyTaskType.lunch, title: 'الغداء'),
      DailyTask(type: DailyTaskType.sleep, title: 'النوم'),
    ];
    await _saveTasks(initialTasks);
    await _storageService.save(_boxName, _startedKey, {'started': false});
  }

  Future<void> _loadState() async {
    final tasksData = await _storageService.get(_boxName, _tasksKey);
    final startedData = await _storageService.get(_boxName, _startedKey);

    List<DailyTask> tasks;
    if (tasksData != null && tasksData['tasks'] != null) {
      tasks = (tasksData['tasks'] as List)
          .map((t) => DailyTask.fromMap(Map<String, dynamic>.from(t)))
          .toList();
    } else {
      tasks = [
        DailyTask(type: DailyTaskType.breakfast, title: 'الفطار'),
        DailyTask(type: DailyTaskType.fruitGame, title: 'تجميع الفاكهة'),
        DailyTask(type: DailyTaskType.water, title: 'شرب الماء'),
        DailyTask(type: DailyTaskType.movement, title: 'الحركة'),
        DailyTask(type: DailyTaskType.lunch, title: 'الغداء'),
        DailyTask(type: DailyTaskType.sleep, title: 'النوم'),
      ];
      await _saveTasks(tasks);
    }

    bool isStarted = startedData?['started'] ?? false;
    emit(DailyTasksLoaded(tasks: tasks, isGameStarted: isStarted));
  }

  Future<void> startGame() async {
    if (state is DailyTasksLoaded) {
      final currentState = state as DailyTasksLoaded;
      await _storageService.save(_boxName, _startedKey, {'started': true});
      emit(DailyTasksLoaded(tasks: currentState.tasks, isGameStarted: true));
    }
  }

  Future<void> updateTask(DailyTask updatedTask) async {
    if (state is DailyTasksLoaded) {
      final currentState = state as DailyTasksLoaded;
      final oldTask = currentState.tasks.firstWhere(
        (t) => t.type == updatedTask.type,
      );

      // Points Logic
      if (!oldTask.isCompleted && updatedTask.isCompleted) {
        bool shouldAddPoints = true;
        if (updatedTask.type == DailyTaskType.sleep) {
          if (updatedTask.sleepStartTime != null &&
              updatedTask.wakeUpTime != null) {
            final hours = updatedTask.wakeUpTime!
                .difference(updatedTask.sleepStartTime!)
                .inHours;
            if (hours < 6 || hours > 8) {
              shouldAddPoints = false;
            }
          } else {
            shouldAddPoints = false;
          }
        }

        if (shouldAddPoints) {
          pointsCubit.addPoints('daily_journey', 50);
        }
      }

      final newTasks = currentState.tasks.map((t) {
        return t.type == updatedTask.type ? updatedTask : t;
      }).toList();

      // Bonus Logic (All 6 completed)
      final wasAllCompleted = currentState.tasks.every((t) => t.isCompleted);
      final isAllCompleted = newTasks.every((t) => t.isCompleted);

      if (!wasAllCompleted && isAllCompleted) {
        final sleepTask = newTasks.firstWhere(
          (t) => t.type == DailyTaskType.sleep,
        );
        if (sleepTask.sleepStartTime != null && sleepTask.wakeUpTime != null) {
          final hours = sleepTask.wakeUpTime!
              .difference(sleepTask.sleepStartTime!)
              .inHours;
          if (hours >= 6 && hours <= 8) {
            pointsCubit.addPoints('daily_journey', 200);
          }
        }
      }

      await _saveTasks(newTasks);
      emit(
        DailyTasksLoaded(
          tasks: newTasks,
          isGameStarted: currentState.isGameStarted,
        ),
      );
    }
  }

  Future<void> _saveTasks(List<DailyTask> tasks) async {
    await _storageService.save(_boxName, _tasksKey, {
      'tasks': tasks.map((t) => t.toMap()).toList(),
    });
  }
}
