import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runner085/core/data/user_data/user_data_store.dart';
import 'package:runner085/core/providers/user_data_providers.dart';
import 'package:runner085/features/training/domain/pace_zones.dart';

/// Resultado do teste de 3 km do usuário, no documento `pace_zones`:
/// `{ testSeconds: int, testDate: ISO-8601 }`.
/// `null` enquanto o usuário não fez o teste.
class PaceZonesNotifier extends AsyncNotifier<PaceZones?> {
  static const doc = 'pace_zones';

  UserDataStore get _store => ref.read(userDataStoreProvider);

  @override
  Future<PaceZones?> build() async {
    // watch: recarrega as zonas ao trocar de conta.
    final data = await ref.watch(userDataStoreProvider).read(doc);
    final seconds = (data?['testSeconds'] as num?)?.toInt();
    if (seconds == null || !PaceZones.isValidTestSeconds(seconds)) return null;
    final date = DateTime.tryParse(data?['testDate'] as String? ?? '') ??
        DateTime.now();
    return PaceZones(testSeconds: seconds, testDate: date);
  }

  Future<void> saveTest(int seconds, {DateTime? date}) async {
    final zones = PaceZones(
      testSeconds: seconds,
      testDate: date ?? DateTime.now(),
    );
    await _store.write(doc, {
      'testSeconds': seconds,
      'testDate': zones.testDate.toIso8601String(),
    });
    state = AsyncValue.data(zones);
  }

  Future<void> clear() async {
    await _store.delete(doc);
    state = const AsyncValue.data(null);
  }
}

final paceZonesProvider =
    AsyncNotifierProvider<PaceZonesNotifier, PaceZones?>(PaceZonesNotifier.new);
