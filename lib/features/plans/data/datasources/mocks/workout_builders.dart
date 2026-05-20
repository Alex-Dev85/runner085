import 'package:runner085/features/plans/domain/entities/workout.dart';
import 'package:runner085/features/plans/domain/enums/training_zone.dart';
import 'package:runner085/features/plans/domain/enums/workout_type.dart';

/// Shorthand builders for common workout templates.
/// Centralizing these here keeps the mock plan files compact and consistent.
class WB {
  WB._();

  static String _id(String planId, int week, int day) => '$planId-w$week-d$day';

  static Workout easy({
    required String planId,
    required int week,
    required int day,
    required int min,
    required double km,
    String? title,
  }) =>
      Workout(
        id: _id(planId, week, day),
        dayOfWeek: day,
        title: title ?? 'Trote leve',
        type: WorkoutType.easy,
        zone: TrainingZone.z2,
        durationMinutes: min,
        distanceKm: km,
        description: 'Ritmo conversável para construir base aeróbica.',
      );

  static Workout recovery({
    required String planId,
    required int week,
    required int day,
    required int min,
    required double km,
  }) =>
      Workout(
        id: _id(planId, week, day),
        dayOfWeek: day,
        title: 'Recuperação',
        type: WorkoutType.recovery,
        zone: TrainingZone.z1,
        durationMinutes: min,
        distanceKm: km,
        description: 'Trote bem leve para recuperar do treino anterior.',
      );

  static Workout longRun({
    required String planId,
    required int week,
    required int day,
    required int min,
    required double km,
    String title = 'Longão',
    TrainingZone zone = TrainingZone.z2,
    String? structure,
    String? description,
  }) =>
      Workout(
        id: _id(planId, week, day),
        dayOfWeek: day,
        title: title,
        type: WorkoutType.longRun,
        zone: zone,
        durationMinutes: min,
        distanceKm: km,
        description: description ?? 'Construindo resistência específica.',
        structure: structure,
      );

  static Workout tempo({
    required String planId,
    required int week,
    required int day,
    required int min,
    required double km,
    required String structure,
    String title = 'Tempo run',
  }) =>
      Workout(
        id: _id(planId, week, day),
        dayOfWeek: day,
        title: title,
        type: WorkoutType.tempo,
        zone: TrainingZone.z3,
        durationMinutes: min,
        distanceKm: km,
        description: 'Ritmo "confortavelmente difícil" próximo ao limiar.',
        structure: structure,
      );

  static Workout interval({
    required String planId,
    required int week,
    required int day,
    required int min,
    required double km,
    required String structure,
    String title = 'Intervalado',
  }) =>
      Workout(
        id: _id(planId, week, day),
        dayOfWeek: day,
        title: title,
        type: WorkoutType.interval,
        zone: TrainingZone.z4,
        durationMinutes: min,
        distanceKm: km,
        description: 'Tiros rápidos com recuperação entre eles.',
        structure: structure,
      );

  static Workout fartlek({
    required String planId,
    required int week,
    required int day,
    required int min,
    required double km,
    required String structure,
  }) =>
      Workout(
        id: _id(planId, week, day),
        dayOfWeek: day,
        title: 'Fartlek',
        type: WorkoutType.fartlek,
        zone: TrainingZone.z3,
        durationMinutes: min,
        distanceKm: km,
        description: 'Brincadeira com ritmos: alterne fortes e moderados.',
        structure: structure,
      );

  static Workout hill({
    required String planId,
    required int week,
    required int day,
    required int min,
    required double km,
    required String structure,
  }) =>
      Workout(
        id: _id(planId, week, day),
        dayOfWeek: day,
        title: 'Subidas',
        type: WorkoutType.hillRepeat,
        zone: TrainingZone.z4,
        durationMinutes: min,
        distanceKm: km,
        description: 'Repetições em subida para força e potência.',
        structure: structure,
      );

  static Workout race({
    required String planId,
    required int week,
    required int day,
    required int min,
    required double km,
    required String title,
    String? structure,
  }) =>
      Workout(
        id: _id(planId, week, day),
        dayOfWeek: day,
        title: title,
        type: WorkoutType.raceSimulation,
        zone: TrainingZone.z3,
        durationMinutes: min,
        distanceKm: km,
        description: 'Simulação ou prova oficial.',
        structure: structure,
      );
}
