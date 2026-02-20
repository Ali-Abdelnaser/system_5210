import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../data/models/daily_task_model.dart';
import 'daily_tasks_state.dart';

class DailyTasksCubit extends Cubit<DailyTasksState> {
  final LocalStorageService _storageService;
  static const String _boxName = 'daily_tasks_box';
  static const String _tasksKey = 'daily_tasks_list';
  static const String _startedKey = 'is_game_started';
  static const String _lastResetKey = 'last_reset_time';

  DailyTasksCubit(this._storageService) : super(DailyTasksInitial());

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
    final DateTime today9AM = DateTime(now.year, now.month, now.day, 9);

    bool needsReset = false;
    if (now.isAfter(today9AM)) {
      if (lastReset.isBefore(today9AM)) {
        needsReset = true;
      }
    } else {
      final DateTime yesterday9AM = today9AM.subtract(const Duration(days: 1));
      if (lastReset.isBefore(yesterday9AM)) {
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
      final newTasks = currentState.tasks.map((t) {
        return t.type == updatedTask.type ? updatedTask : t;
      }).toList();

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
