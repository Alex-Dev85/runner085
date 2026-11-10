import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:runner085/core/data/user_data/legacy_device_data.dart';
import 'package:runner085/core/data/user_data/user_data_store.dart';
import 'package:runner085/core/providers/user_data_providers.dart';
import 'package:runner085/features/plans/presentation/providers/active_plan_provider.dart';
import 'package:runner085/features/plans/domain/enums/race_distance.dart';
import 'package:runner085/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:runner085/features/progress/data/workout_progress_repository.dart';
import 'package:runner085/features/progress/presentation/providers/workout_progress_provider.dart';
import 'package:runner085/features/training/presentation/providers/pace_zones_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('isolamento entre contas', () {
    test('LocalUserDataStore separa os dados por uid', () async {
      final ana = WorkoutProgressRepository(LocalUserDataStore(uid: 'ana'));
      final bia = WorkoutProgressRepository(LocalUserDataStore(uid: 'bia'));

      await ana.markCompleted(
        workoutId: 'w1',
        durationMinutes: 30,
        date: DateTime(2026, 1, 5),
      );

      expect(await ana.getCompletedIds(), {'w1'});
      expect(await bia.getCompletedIds(), isEmpty);
      expect(await bia.getTotalMinutes(), 0);
    });

    test('trocar de conta recarrega plano, progresso, perfil e zonas',
        () async {
      // Simula o login: o uid atual é controlado pelo teste.
      final uid = StateProvider<String?>((ref) => 'ana');
      final container = ProviderContainer(
        overrides: [
          currentUserIdProvider.overrideWith((ref) => ref.watch(uid)),
          userDataStoreProvider.overrideWith((ref) {
            final id = ref.watch(currentUserIdProvider);
            return id == null
                ? InMemoryUserDataStore()
                : LocalUserDataStore(uid: id);
          }),
        ],
      );
      addTearDown(container.dispose);

      // Ana preenche os dados.
      await container.read(paceZonesProvider.future);
      await container.read(paceZonesProvider.notifier).saveTest(900);
      await container.read(userProfileProvider.future);
      await container.read(userProfileProvider.notifier).updateProfile(
            level: RunnerLevel.advanced,
            goalDistance: RaceDistance.tenKm,
          );
      await container.read(workoutProgressProvider.future);
      await container
          .read(workoutProgressProvider.notifier)
          .markCompleted(workoutId: 'w1', durationMinutes: 30);
      await container
          .read(activePlanRepositoryProvider)
          .setActivePlan('plan-x', DateTime(2026, 1, 5));

      // Bia entra no mesmo aparelho: não vê nada da Ana.
      container.read(uid.notifier).state = 'bia';
      expect(await container.read(paceZonesProvider.future), isNull);
      final biaProfile = await container.read(userProfileProvider.future);
      expect(biaProfile.goalDistance, isNull);
      final biaProgress = await container.read(workoutProgressProvider.future);
      expect(biaProgress.completedIds, isEmpty);
      expect(
        await container.read(activePlanRepositoryProvider).getActivePlanId(),
        isNull,
      );

      // Ana volta: os dados dela continuam lá.
      container.read(uid.notifier).state = 'ana';
      expect(
        (await container.read(paceZonesProvider.future))?.testSeconds,
        900,
      );
      final anaProfile = await container.read(userProfileProvider.future);
      expect(anaProfile.goalDistance, RaceDistance.tenKm);
      expect(anaProfile.level, RunnerLevel.advanced);
      final anaProgress = await container.read(workoutProgressProvider.future);
      expect(anaProgress.completedIds, {'w1'});
      expect(
        await container.read(activePlanRepositoryProvider).getActivePlanId(),
        'plan-x',
      );
    });
  });

  group('migração dos dados antigos do aparelho', () {
    test('primeira conta recebe os dados e as chaves globais somem', () async {
      SharedPreferences.setMockInitialValues({
        'active_plan_id': 'plan-5k',
        'active_plan_start_date': DateTime(2026, 1, 5).millisecondsSinceEpoch,
        'progress_completed_dates': '{"w1":"2026-01-05T18:00:00.000"}',
        'progress_total_minutes': 30,
        'progress_streak_days': 1,
        'progress_last_date': '2026-01-05T00:00:00.000',
        'user_profile_level': 'intermediate',
        'user_profile_goal_distance': 'tenKm',
        'zones_3km_test_seconds': 900,
        'zones_3km_test_date': '2026-01-01T00:00:00.000',
      });

      final ana = MigratingUserDataStore(LocalUserDataStore(uid: 'ana'));
      for (final doc in LegacyDeviceData.keysByDoc.keys) {
        expect(await ana.read(doc), isNotNull, reason: doc);
      }
      expect((await ana.read('active_plan'))!['planId'], 'plan-5k');
      expect((await ana.read('progress'))!['totalMinutes'], 30);
      expect((await ana.read('profile'))!['goalDistance'], 'tenKm');
      expect((await ana.read('pace_zones'))!['testSeconds'], 900);

      // Chaves globais apagadas; a próxima conta começa vazia.
      final prefs = await SharedPreferences.getInstance();
      for (final keys in LegacyDeviceData.keysByDoc.values) {
        for (final key in keys) {
          expect(prefs.containsKey(key), isFalse, reason: key);
        }
      }
      final bia = MigratingUserDataStore(LocalUserDataStore(uid: 'bia'));
      for (final doc in LegacyDeviceData.keysByDoc.keys) {
        expect(await bia.read(doc), isNull, reason: doc);
      }

      // Os dados migrados continuam legíveis pelo repositório.
      final progress = WorkoutProgressRepository(ana);
      expect(await progress.getCompletedIds(), {'w1'});
      expect(await progress.getStreakDays(), 1);
    });

    test('não sobrescreve dados que a conta já tem', () async {
      SharedPreferences.setMockInitialValues({
        'zones_3km_test_seconds': 900,
      });
      final inner = LocalUserDataStore(uid: 'ana');
      await inner.write('pace_zones', {'testSeconds': 1200});

      final ana = MigratingUserDataStore(inner);
      expect((await ana.read('pace_zones'))!['testSeconds'], 1200);
    });
  });
}
