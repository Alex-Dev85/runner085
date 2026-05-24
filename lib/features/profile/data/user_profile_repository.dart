import 'package:shared_preferences/shared_preferences.dart';

import 'package:runner085/features/plans/domain/enums/race_distance.dart';

/// Persiste nível e objetivo do corredor localmente via SharedPreferences.
/// Usado em demo mode; em produção seria substituído por Firestore.
class UserProfileRepository {
  static const String _keyLevel = 'user_profile_level';
  static const String _keyGoalDistance = 'user_profile_goal_distance';

  Future<RunnerLevel?> getLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyLevel);
    if (value == null) return null;
    return RunnerLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RunnerLevel.beginner,
    );
  }

  Future<RaceDistance?> getGoalDistance() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyGoalDistance);
    if (value == null) return null;
    return RaceDistance.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RaceDistance.fiveKm,
    );
  }

  Future<void> saveLevel(RunnerLevel level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLevel, level.name);
  }

  Future<void> saveGoalDistance(RaceDistance distance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGoalDistance, distance.name);
  }

  Future<void> saveProfile({
    required RunnerLevel level,
    required RaceDistance goalDistance,
  }) async {
    await saveLevel(level);
    await saveGoalDistance(goalDistance);
  }
}
