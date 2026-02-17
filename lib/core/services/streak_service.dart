import 'package:system_5210/features/user_setup/data/models/user_profile_model.dart';
import 'package:system_5210/features/user_setup/domain/repositories/user_setup_repository.dart';
class StreakService {
  final UserSetupRepository repository;

  StreakService(this.repository);

  /// Logic to update streak based on last login
  /// Returns a map with { 'status': 'updated' | 'frozen' | 'reset', 'previousStreak': int }
  Future<Map<String, dynamic>> checkAndUpdateStreak(
    UserProfileModel profile,
  ) async {
    final now = DateTime.now();
    final lastLogin = profile.lastLoginDate;

    if (lastLogin == null) {
      // First time ever
      final updatedProfile = profile.copyWith(
        currentStreak: 1,
        maxStreak: 1,
        lastLoginDate: now,
        streakStatus: 'active',
      );
      await repository.saveUserProfile(updatedProfile);
      return {'status': 'updated', 'previousStreak': 0};
    }

    final difference = now
        .difference(DateTime(lastLogin.year, lastLogin.month, lastLogin.day))
        .inDays;

    if (difference == 0) {
      // Already logged in today
      return {'status': 'none', 'previousStreak': profile.currentStreak};
    } else if (difference == 1) {
      // Logged in yesterday, increment
      final newStreak = profile.currentStreak + 1;
      final updatedProfile = profile.copyWith(
        currentStreak: newStreak,
        maxStreak: newStreak > profile.maxStreak
            ? newStreak
            : profile.maxStreak,
        lastLoginDate: now,
        streakStatus: 'active',
      );
      await repository.saveUserProfile(updatedProfile);
      return {'status': 'updated', 'previousStreak': profile.currentStreak};
    } else if (difference <= 3) {
      // Missed 1 or 2 days, status stays or becomes frozen
      final updatedProfile = profile.copyWith(
        lastLoginDate: now,
        streakStatus: 'frozen',
      );
      await repository.saveUserProfile(updatedProfile);
      return {'status': 'frozen', 'previousStreak': profile.currentStreak};
    } else {
      // Missed 3 or more days, reset
      final previousStreak = profile.currentStreak;
      final updatedProfile = profile.copyWith(
        currentStreak: 1,
        lastLoginDate: now,
        streakStatus: 'active',
      );
      await repository.saveUserProfile(updatedProfile);
      return {'status': 'reset', 'previousStreak': previousStreak};
    }
  }
}
