import 'package:shared_preferences/shared_preferences.dart';

import 'package:runner085/core/utils/constants.dart';

/// Persiste se o onboarding já foi concluído.
class OnboardingRepository {
  Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyOnboardingCompleted) ?? false;
  }

  Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboardingCompleted, true);
  }
}
