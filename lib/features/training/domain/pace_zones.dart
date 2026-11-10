import 'package:runner085/features/plans/domain/enums/training_zone.dart';
import 'package:runner085/features/settings/domain/distance_unit.dart';

/// Faixa de ritmo (pace) de uma zona, em segundos por quilômetro.
///
/// [fastSecPerKm] é o limite mais rápido (menos segundos) e [slowSecPerKm]
/// o mais lento.
class PaceRange {
  final int fastSecPerKm;
  final int slowSecPerKm;

  const PaceRange({required this.fastSecPerKm, required this.slowSecPerKm});

  /// Ex.: "5:12 – 5:45 /km".
  String format(DistanceUnit unit) =>
      '${PaceZones.formatPace(fastSecPerKm, unit)} – '
      '${PaceZones.formatPace(slowSecPerKm, unit)} /${unit.label}';
}

/// Zonas de ritmo calculadas a partir do teste de 3 km.
///
/// O ritmo médio do teste (tempo ÷ 3) fica próximo do ritmo de VO2máx.
/// Cada zona é uma faixa percentual desse ritmo — quanto maior o fator,
/// mais lento o ritmo.
class PaceZones {
  static const double testDistanceKm = 3;

  /// Tempos aceitos para o teste: 7:00 a 40:00.
  static const int minTestSeconds = 7 * 60;
  static const int maxTestSeconds = 40 * 60;

  /// Fatores (mais rápido, mais lento) aplicados ao ritmo do teste.
  static const Map<TrainingZone, (double, double)> factors = {
    TrainingZone.z1: (1.30, 1.45),
    TrainingZone.z2: (1.18, 1.30),
    TrainingZone.z3: (1.08, 1.18),
    TrainingZone.z4: (1.02, 1.08),
    TrainingZone.z5: (0.95, 1.02),
  };

  final int testSeconds;
  final DateTime testDate;

  PaceZones({required this.testSeconds, required this.testDate})
      : assert(isValidTestSeconds(testSeconds));

  static bool isValidTestSeconds(int seconds) =>
      seconds >= minTestSeconds && seconds <= maxTestSeconds;

  /// Ritmo médio do teste, em segundos por km.
  double get testPaceSecPerKm => testSeconds / testDistanceKm;

  PaceRange rangeFor(TrainingZone zone) {
    final (fast, slow) = factors[zone]!;
    return PaceRange(
      fastSecPerKm: (testPaceSecPerKm * fast).round(),
      slowSecPerKm: (testPaceSecPerKm * slow).round(),
    );
  }

  /// Formata um ritmo em s/km como "m:ss" na unidade escolhida.
  static String formatPace(num secPerKm, DistanceUnit unit) {
    final perUnit = switch (unit) {
      DistanceUnit.kilometers => secPerKm,
      DistanceUnit.miles => secPerKm / unit.fromKm(1),
    };
    return formatDuration(perUnit.round());
  }

  /// Formata segundos como "m:ss".
  static String formatDuration(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
