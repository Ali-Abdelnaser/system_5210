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

  // Calculation helpers
  static double calculateDistanceKm(int steps, double heightCm) {
    final strideLengthCm = heightCm * 0.413;
    return (steps * strideLengthCm) / 100000;
  }

  static double calculateCalories(int steps, double heightCm, double weightKg) {
    final distanceKm = calculateDistanceKm(steps, heightCm);
    return weightKg * distanceKm * 0.75;
  }

  static int calculateActiveMinutes(int steps) {
    return (steps / 100).round();
  }

  Future<bool> authorize() async {
    // activityRecognition is Android-specific for permission_handler
    // On iOS, Pedometer will work if "Motion Usage Description" is in Info.plist
    // We can check platform but permission_handler handles it gracefully
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
    final today = formatDate(now);

    final data = await _storage.get(boxName, keyMeta) ?? {};

    int dayStartSteps = data['day_start_steps'] ?? event.steps;
    String lastDate = data['last_update_date'] ?? today;
    bool goalNotified = data['goal_notified_$today'] ?? false;
    int sensorAtLastUpdate = data['last_sensor_steps'] ?? event.steps;

    // Detect sensor reset (phone reboot or overflow)
    // We check if steps decreased significantly without a date change
    if (event.steps < (sensorAtLastUpdate - 100)) {
      // Sensor reset: we need to adjust dayStartSteps offset
      // If we are on the same day, we want todaySteps to stay roughly the same
      int currentTodaySteps = data['current_daily_steps'] ?? 0;
      dayStartSteps = event.steps - currentTodaySteps;
      if (dayStartSteps < 0) dayStartSteps = 0;
    }

    // New day detection (Gap handling)
    if (lastDate != today) {
      // Save last known steps to history if they don't exist
      await _saveToHistory(lastDate, data['current_daily_steps'] ?? 0);

      // Update dayStartSteps for the new day
      dayStartSteps = event.steps;
      lastDate = today;
      goalNotified = false;
    }

    int todaySteps = event.steps - dayStartSteps;
    if (todaySteps < 0) todaySteps = 0;

    // Goal detection (using unified threshold)
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

  static String formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<void> _saveToHistory(String date, int steps) async {
    final history = await _storage.get(boxName, keyHistory) ?? {};

    // Only save if this date isn't already in history or if steps are higher
    if (history[date] == null || (history[date] as int) < steps) {
      history[date] = steps;
    }

    // Keep only last 14 days for a better weekly analysis UI
    final sortedKeys = history.keys.toList()..sort();
    if (sortedKeys.length > 14) {
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

    // Ensure today is in the map for UI
    final today = formatDate(DateTime.now());
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
