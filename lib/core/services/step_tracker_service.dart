import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:system_5210/core/services/local_storage_service.dart';
import 'package:system_5210/core/services/notification_service.dart';

class StepTrackerService {
  final LocalStorageService _storage;
  final NotificationService _notifications;
  StreamSubscription<StepCount>? _stepCountSubscription;
  final _stepsController = StreamController<int>.broadcast();

  // Storage Keys
  static const String boxName = 'step_tracker_box';
  static const String keyMeta = 'steps_meta';
  static const String keyHistory = 'steps_history';

  static const int goalThreshold = 5210;

  StepTrackerService(this._storage, this._notifications);

  Stream<int> get stepsStream => _stepsController.stream;

  Future<bool> authorize() async {
    final status = await Permission.activityRecognition.request();
    if (status.isGranted) {
      _startListening();
      return true;
    }
    return false;
  }

  void _startListening() {
    _stepCountSubscription?.cancel();
    _stepCountSubscription = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: (e) => print("Pedometer Error: $e"),
    );
  }

  Future<void> _onStepCount(StepCount event) async {
    final now = DateTime.now();
    final today = DateTime(
      now.year,
      now.month,
      now.day,
    ).toIso8601String().split('T')[0];

    final data = await _storage.get(boxName, keyMeta) ?? {};

    int dayStartSteps = data['day_start_steps'] ?? event.steps;
    String lastDate = data['last_update_date'] ?? today;
    bool goalNotified = data['goal_notified_$today'] ?? false;

    // New day detection
    if (lastDate != today) {
      // Save yesterday's data to history before resetting
      await _saveToHistory(lastDate, data['current_daily_steps'] ?? 0);
      dayStartSteps = event.steps;
      lastDate = today;
      goalNotified = false;
    }
    // Sensor reset detection (e.g. phone reboot)
    else if (event.steps < (data['last_sensor_steps'] ?? 0)) {
      dayStartSteps = event.steps;
    }

    int todaySteps = event.steps - dayStartSteps;
    if (todaySteps < 0) todaySteps = 0;

    // Goal detection
    if (todaySteps >= goalThreshold && !goalNotified) {
      _notifyGoalReached();
      goalNotified = true;
    }

    // Save metadata
    await _storage.save(boxName, keyMeta, {
      'last_sensor_steps': event.steps,
      'day_start_steps': dayStartSteps,
      'last_update_date': lastDate,
      'current_daily_steps': todaySteps,
      'goal_notified_$today': goalNotified,
    });

    _stepsController.add(todaySteps);
  }

  Future<void> _saveToHistory(String date, int steps) async {
    final history = await _storage.get(boxName, keyHistory) ?? {};
    history[date] = steps;

    // Keep only last 10 days to save space
    final sortedKeys = history.keys.toList()..sort();
    if (sortedKeys.length > 10) {
      history.remove(sortedKeys.first);
    }

    await _storage.save(boxName, keyHistory, history);
  }

  Future<Map<String, int>> getWeeklyHistory() async {
    final historyData = await _storage.get(boxName, keyHistory);
    final Map<String, int> history = <String, int>{};

    if (historyData != null) {
      historyData.forEach((key, value) {
        if (value != null) {
          history[key.toString()] = int.tryParse(value.toString()) ?? 0;
        }
      });
    }

    // Add today to the history returned for the UI
    final today = DateTime.now().toIso8601String().split('T')[0];
    history[today] = await getStepsToday();

    return history;
  }

  Future<int> getStepsToday() async {
    final data = await _storage.get(boxName, keyMeta);
    return data?['current_daily_steps'] ?? 0;
  }

  void _notifyGoalReached() {
    _notifications.showImmediateNotification(
      title: "عاش يا بطل! 🎉",
      body: "لقد حققت هدف الـ 5210 خطوة لليوم. استمر في التحرك!",
    );
  }

  void dispose() {
    _stepCountSubscription?.cancel();
    _stepsController.close();
  }
}
