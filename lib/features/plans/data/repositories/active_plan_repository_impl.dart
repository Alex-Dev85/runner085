import 'package:shared_preferences/shared_preferences.dart';

import 'package:runner085/features/plans/domain/repositories/active_plan_repository.dart';

class ActivePlanRepositoryImpl implements ActivePlanRepository {
  static const String _keyPlanId = 'active_plan_id';
  static const String _keyStartDate = 'active_plan_start_date';

  @override
  Future<String?> getActivePlanId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPlanId);
  }

  @override
  Future<DateTime?> getStartDate() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_keyStartDate);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  @override
  Future<void> setActivePlan(String planId, DateTime startDate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPlanId, planId);
    await prefs.setInt(_keyStartDate, startDate.millisecondsSinceEpoch);
  }

  @override
  Future<void> clearActivePlan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPlanId);
    await prefs.remove(_keyStartDate);
  }
}
