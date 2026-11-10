import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:runner085/core/data/user_data/user_data_store.dart';

/// Dados que versões anteriores salvavam em chaves globais do aparelho
/// (sem distinguir o usuário).
///
/// Cada documento é migrado uma única vez: na primeira leitura de um usuário
/// que ainda não tem aquele documento, os dados antigos são copiados para
/// ele e as chaves globais são apagadas — assim não vazam para a próxima
/// conta que entrar no aparelho.
class LegacyDeviceData {
  static const activePlanKeys = ['active_plan_id', 'active_plan_start_date'];
  static const progressKeys = [
    'progress_completed_ids',
    'progress_completed_dates',
    'progress_total_minutes',
    'progress_streak_days',
    'progress_last_date',
  ];
  static const profileKeys = [
    'user_profile_level',
    'user_profile_goal_distance',
  ];
  static const paceZonesKeys = [
    'zones_3km_test_seconds',
    'zones_3km_test_date',
  ];

  /// `theme_mode` não entra aqui: continua no aparelho como cópia do último
  /// tema usado (para as telas antes do login) e não é apagado.
  static const settingsKeys = [
    'settings_distance_unit',
    'settings_weekly_frequency',
  ];

  static const reminderKeys = ['notif_enabled', 'notif_hour', 'notif_minute'];

  static const Map<String, List<String>> keysByDoc = {
    'reminder': reminderKeys,
    'active_plan': activePlanKeys,
    'progress': progressKeys,
    'profile': profileKeys,
    'pace_zones': paceZonesKeys,
    'settings': settingsKeys,
  };

  /// Converte as chaves antigas no formato do documento novo, ou `null`
  /// se não houver dado antigo para [doc].
  static Map<String, dynamic>? extract(SharedPreferences prefs, String doc) {
    switch (doc) {
      case 'active_plan':
        final planId = prefs.getString('active_plan_id');
        final startMs = prefs.getInt('active_plan_start_date');
        if (planId == null || startMs == null) return null;
        return {
          'planId': planId,
          'startDate':
              DateTime.fromMillisecondsSinceEpoch(startMs).toIso8601String(),
        };
      case 'progress':
        final datesRaw = prefs.getString('progress_completed_dates');
        final total = prefs.getInt('progress_total_minutes');
        if (datesRaw == null && total == null) return null;
        return {
          'completedDates': datesRaw == null
              ? <String, String>{}
              : (jsonDecode(datesRaw) as Map).cast<String, String>(),
          'totalMinutes': total ?? 0,
          'streakDays': prefs.getInt('progress_streak_days') ?? 0,
          'lastDate': prefs.getString('progress_last_date'),
        };
      case 'profile':
        final level = prefs.getString('user_profile_level');
        final goal = prefs.getString('user_profile_goal_distance');
        if (level == null && goal == null) return null;
        return {'level': level, 'goalDistance': goal};
      case 'reminder':
        final enabled = prefs.getBool('notif_enabled');
        final hour = prefs.getInt('notif_hour');
        final minute = prefs.getInt('notif_minute');
        if (enabled == null && hour == null && minute == null) return null;
        return {
          'enabled': enabled ?? false,
          if (hour != null) 'hour': hour,
          if (minute != null) 'minute': minute,
        };
      case 'settings':
        final unit = prefs.getString('settings_distance_unit');
        final frequency = prefs.getInt('settings_weekly_frequency');
        if (unit == null && frequency == null) return null;
        return {
          if (unit != null) 'distanceUnit': unit,
          if (frequency != null) 'weeklyFrequency': frequency,
          // Leva junto o tema que estava em uso neste aparelho.
          if (prefs.getString('theme_mode') case final theme?)
            'themeMode': theme,
        };
      case 'pace_zones':
        final seconds = prefs.getInt('zones_3km_test_seconds');
        if (seconds == null) return null;
        return {
          'testSeconds': seconds,
          'testDate': prefs.getString('zones_3km_test_date'),
        };
    }
    return null;
  }

  static Future<void> remove(SharedPreferences prefs, String doc) async {
    for (final key in keysByDoc[doc] ?? const <String>[]) {
      await prefs.remove(key);
    }
  }
}

/// Envolve um [UserDataStore] e migra os dados antigos do aparelho na
/// primeira leitura de cada documento.
class MigratingUserDataStore implements UserDataStore {
  final UserDataStore inner;

  MigratingUserDataStore(this.inner);

  @override
  Future<Map<String, dynamic>?> read(String doc) async {
    final current = await inner.read(doc);
    if (current != null) return current;

    final prefs = await SharedPreferences.getInstance();
    final legacy = LegacyDeviceData.extract(prefs, doc);
    if (legacy == null) return null;

    await inner.write(doc, legacy);
    await LegacyDeviceData.remove(prefs, doc);
    return legacy;
  }

  @override
  Future<void> write(String doc, Map<String, dynamic> data) =>
      inner.write(doc, data);

  @override
  Future<void> delete(String doc) async {
    await inner.delete(doc);
    // Garante que um "apagar" não seja desfeito por dados antigos.
    final prefs = await SharedPreferences.getInstance();
    await LegacyDeviceData.remove(prefs, doc);
  }
}
