import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:runner085/features/settings/domain/distance_unit.dart';

/// Preferências gerais do app, persistidas via SharedPreferences.
class AppSettings {
  final DistanceUnit distanceUnit;

  /// Quantos treinos por semana o usuário deseja fazer.
  /// `null` significa "sem preferência".
  final int? weeklyFrequency;

  const AppSettings({
    this.distanceUnit = DistanceUnit.kilometers,
    this.weeklyFrequency,
  });
}

class AppSettingsNotifier extends AsyncNotifier<AppSettings> {
  static const _keyDistanceUnit = 'settings_distance_unit';
  static const _keyWeeklyFrequency = 'settings_weekly_frequency';

  @override
  Future<AppSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    final unitName = prefs.getString(_keyDistanceUnit);
    final unit = DistanceUnit.values.firstWhere(
      (u) => u.name == unitName,
      orElse: () => DistanceUnit.kilometers,
    );
    return AppSettings(
      distanceUnit: unit,
      weeklyFrequency: prefs.getInt(_keyWeeklyFrequency),
    );
  }

  Future<void> setDistanceUnit(DistanceUnit unit) async {
    final current = state.valueOrNull ?? const AppSettings();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDistanceUnit, unit.name);
    state = AsyncValue.data(
      AppSettings(
        distanceUnit: unit,
        weeklyFrequency: current.weeklyFrequency,
      ),
    );
  }

  /// Define a frequência semanal desejada. `null` remove a preferência.
  Future<void> setWeeklyFrequency(int? frequency) async {
    final current = state.valueOrNull ?? const AppSettings();
    final prefs = await SharedPreferences.getInstance();
    if (frequency == null) {
      await prefs.remove(_keyWeeklyFrequency);
    } else {
      await prefs.setInt(_keyWeeklyFrequency, frequency);
    }
    state = AsyncValue.data(
      AppSettings(
        distanceUnit: current.distanceUnit,
        weeklyFrequency: frequency,
      ),
    );
  }
}

final appSettingsProvider =
    AsyncNotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);

/// Unidade de distância atual (km enquanto as preferências carregam).
final distanceUnitProvider = Provider<DistanceUnit>((ref) {
  return ref.watch(appSettingsProvider).valueOrNull?.distanceUnit ??
      DistanceUnit.kilometers;
});
