import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runner085/core/providers/user_data_providers.dart';
import 'package:runner085/features/settings/data/user_settings_repository.dart';
import 'package:runner085/features/settings/domain/distance_unit.dart';

/// Recriado quando a conta muda (depende do armazenamento do usuário).
final userSettingsRepositoryProvider = Provider<UserSettingsRepository>((ref) {
  return UserSettingsRepository(ref.watch(userDataStoreProvider));
});

/// Preferências gerais do usuário, salvas na conta (documento `settings`).
class AppSettings {
  final DistanceUnit distanceUnit;

  /// Quantos treinos por semana o usuário deseja fazer.
  /// `null` significa "sem preferência".
  final int? weeklyFrequency;

  const AppSettings({
    this.distanceUnit = DistanceUnit.kilometers,
    this.weeklyFrequency,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        distanceUnit: DistanceUnit.values.firstWhere(
          (u) => u.name == json['distanceUnit'],
          orElse: () => DistanceUnit.kilometers,
        ),
        weeklyFrequency: (json['weeklyFrequency'] as num?)?.toInt(),
      );
}

class AppSettingsNotifier extends AsyncNotifier<AppSettings> {
  UserSettingsRepository get _repo => ref.read(userSettingsRepositoryProvider);

  @override
  Future<AppSettings> build() async {
    // watch: recarrega as preferências ao trocar de conta.
    final repo = ref.watch(userSettingsRepositoryProvider);
    return AppSettings.fromJson(await repo.read());
  }

  Future<void> setDistanceUnit(DistanceUnit unit) async {
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncValue.data(
      AppSettings(
        distanceUnit: unit,
        weeklyFrequency: current.weeklyFrequency,
      ),
    );
    await _repo.update({'distanceUnit': unit.name});
  }

  /// Define a frequência semanal desejada. `null` remove a preferência.
  Future<void> setWeeklyFrequency(int? frequency) async {
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncValue.data(
      AppSettings(
        distanceUnit: current.distanceUnit,
        weeklyFrequency: frequency,
      ),
    );
    await _repo.update({'weeklyFrequency': frequency});
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
