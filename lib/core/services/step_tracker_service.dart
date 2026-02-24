import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class StepTrackerService {
  final Health _health = Health();

  // Define the types to get.
  final types = [HealthDataType.STEPS];

  // Permissions for the types.
  final permissions = [HealthDataAccess.READ];

  Future<bool> authorize() async {
    // 1. First, request Activity Recognition permission (Android specific but safe)
    final activityStatus = await Permission.activityRecognition.request();
    if (activityStatus.isDenied) return false;

    // 2. On Android, check if Health Connect is installed and handle it
    try {
      bool? hasPermissions = await _health.hasPermissions(
        types,
        permissions: permissions,
      );
      hasPermissions ??= false;

      if (!hasPermissions) {
        // Request authorization
        bool authorized = await _health.requestAuthorization(
          types,
          permissions: permissions,
        );
        return authorized;
      }
      return true;
    } catch (e) {
      print("Error in authorize: $e");
      return false;
    }
  }

  Future<int> getStepsToday() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    try {
      // Fetch health data from the last 24 hours
      int? steps = await _health.getTotalStepsInInterval(midnight, now);
      return steps ?? 0;
    } catch (error) {
      print("Exception in getStepsToday: $error");
      return 0;
    }
  }

  Future<List<HealthDataPoint>> getStepsWeekly() async {
    final now = DateTime.now();
    final lastWeek = now.subtract(const Duration(days: 7));

    try {
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        types: types,
        startTime: lastWeek,
        endTime: now,
      );
      return healthData;
    } catch (error) {
      print("Exception in getStepsWeekly: $error");
      return [];
    }
  }
}
