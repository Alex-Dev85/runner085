import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:runner085/features/plans/domain/enums/training_zone.dart';
import 'package:runner085/features/settings/domain/distance_unit.dart';
import 'package:runner085/features/training/domain/pace_zones.dart';
import 'package:runner085/features/training/presentation/providers/pace_zones_provider.dart';

void main() {
  group('PaceZones', () {
    // 15:00 nos 3 km → 5:00/km (300 s/km).
    final zones = PaceZones(testSeconds: 900, testDate: DateTime(2026, 11, 10));

    test('ritmo do teste é o tempo dividido por 3', () {
      expect(zones.testPaceSecPerKm, 300);
    });

    test('calcula as faixas de cada zona a partir do ritmo do teste', () {
      PaceRange r(TrainingZone z) => zones.rangeFor(z);
      expect(r(TrainingZone.z5).fastSecPerKm, 285); // 4:45
      expect(r(TrainingZone.z5).slowSecPerKm, 306); // 5:06
      expect(r(TrainingZone.z4).slowSecPerKm, 324); // 5:24
      expect(r(TrainingZone.z3).slowSecPerKm, 354); // 5:54
      expect(r(TrainingZone.z2).slowSecPerKm, 390); // 6:30
      expect(r(TrainingZone.z1).slowSecPerKm, 435); // 7:15
    });

    test('zonas são contíguas e ficam mais lentas de Z5 para Z1', () {
      final ordered = TrainingZone.values.reversed.toList();
      for (var i = 0; i < ordered.length - 1; i++) {
        expect(
          zones.rangeFor(ordered[i]).slowSecPerKm,
          zones.rangeFor(ordered[i + 1]).fastSecPerKm,
        );
      }
    });

    test('formata em km e em milhas', () {
      expect(
        zones.rangeFor(TrainingZone.z2).format(DistanceUnit.kilometers),
        '5:54 – 6:30 /km',
      );
      expect(PaceZones.formatPace(300, DistanceUnit.miles), '8:03');
    });

    test('valida limites do tempo do teste', () {
      expect(PaceZones.isValidTestSeconds(419), isFalse);
      expect(PaceZones.isValidTestSeconds(420), isTrue);
      expect(PaceZones.isValidTestSeconds(2400), isTrue);
      expect(PaceZones.isValidTestSeconds(2401), isFalse);
    });
  });

  group('PaceZonesNotifier', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('salva, recarrega e remove o teste', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(await container.read(paceZonesProvider.future), isNull);

      await container.read(paceZonesProvider.notifier).saveTest(1080);
      expect(container.read(paceZonesProvider).value?.testSeconds, 1080);

      final fresh = ProviderContainer();
      addTearDown(fresh.dispose);
      expect((await fresh.read(paceZonesProvider.future))?.testSeconds, 1080);

      await fresh.read(paceZonesProvider.notifier).clear();
      expect(fresh.read(paceZonesProvider).value, isNull);
    });
  });
}
