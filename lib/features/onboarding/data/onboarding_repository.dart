import 'package:shared_preferences/shared_preferences.dart';

import 'package:runner085/core/utils/constants.dart';

/// Persiste se o onboarding já foi concluído.
///
/// O flag é guardado por usuário: ao trocar de conta, o onboarding
/// reaparece para quem ainda não o concluiu. Sem [userId] usa a chave
/// global antiga (mantida apenas como fallback).
class OnboardingRepository {
  static String _key(String? userId) => userId == null
      ? AppConstants.keyOnboardingCompleted
      : '${AppConstants.keyOnboardingCompleted}_$userId';

  Future<bool> isCompleted({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(userId)) ?? false;
  }

  Future<void> markCompleted({String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(userId), true);
  }
}
