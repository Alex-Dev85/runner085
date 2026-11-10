import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:runner085/features/training/domain/pace_zones.dart';

/// Resultado do teste de 3 km, persistido via SharedPreferences.
/// `null` enquanto o usuário não fez o teste.
class PaceZonesNotifier extends AsyncNotifier<PaceZones?> {
  static const _keySeconds = 'zones_3km_test_seconds';
  static const _keyDate = 'zones_3km_test_date';

  @override
  Future<PaceZones?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final seconds = prefs.getInt(_keySeconds);
    if (seconds == null || !PaceZones.isValidTestSeconds(seconds)) return null;
    final date =
        DateTime.tryParse(prefs.getString(_keyDate) ?? '') ?? DateTime.now();
    return PaceZones(testSeconds: seconds, testDate: date);
  }

  Future<void> saveTest(int seconds, {DateTime? date}) async {
    final zones = PaceZones(
      testSeconds: seconds,
      testDate: date ?? DateTime.now(),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySeconds, seconds);
    await prefs.setString(_keyDate, zones.testDate.toIso8601String());
    state = AsyncValue.data(zones);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySeconds);
    await prefs.remove(_keyDate);
    state = const AsyncValue.data(null);
  }
}

final paceZonesProvider =
    AsyncNotifierProvider<PaceZonesNotifier, PaceZones?>(PaceZonesNotifier.new);
