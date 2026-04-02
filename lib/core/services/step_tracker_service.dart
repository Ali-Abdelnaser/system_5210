import 'dart:async';

/// StepTrackerService is disabled to comply with Google Play Store policies
/// regarding health apps and individual developer requirements.
class StepTrackerService {
  // final LocalStorageService _storage;
  // final NotificationService _notifications;
  final _stepsController = StreamController<int>.broadcast();

  static const String boxName = 'step_tracker_box';
  static const String keyMeta = 'steps_meta';
  static const String keyHistory = 'steps_history';
  static const int goalThreshold = 5210;

  StepTrackerService(dynamic _, dynamic __);

  Stream<int> get stepsStream => _stepsController.stream;

  static double calculateDistanceKm(int steps, double heightCm) => 0.0;
  static double calculateCalories(int steps, double heightCm, double weightKg) => 0.0;
  static int calculateActiveMinutes(int steps) => 0;
  static String formatDate(DateTime date) => "${date.year}-${date.month}-${date.day}";

  Future<bool> authorize() async => false;
  Future<Map<String, int>> getWeeklyHistory() async => {};
  Future<int> getStepsToday() async => 0;

  void dispose() {
    _stepsController.close();
  }
}
