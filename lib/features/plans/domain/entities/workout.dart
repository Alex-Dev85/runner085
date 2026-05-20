import 'package:runner085/features/plans/domain/enums/training_zone.dart';
import 'package:runner085/features/plans/domain/enums/workout_type.dart';

/// Um treino individual (uma sessão).
class Workout {
  final String id;
  final int dayOfWeek; // 1 = segunda, 7 = domingo
  final String title;
  final WorkoutType type;
  final TrainingZone zone;
  final int durationMinutes;
  final double? distanceKm;
  final String description;
  final String? structure; // Ex.: "10min aquecimento + 6x400m + 10min volta"

  const Workout({
    required this.id,
    required this.dayOfWeek,
    required this.title,
    required this.type,
    required this.zone,
    required this.durationMinutes,
    required this.description,
    this.distanceKm,
    this.structure,
  });

  String get dayLabel => switch (dayOfWeek) {
        1 => 'Segunda',
        2 => 'Terça',
        3 => 'Quarta',
        4 => 'Quinta',
        5 => 'Sexta',
        6 => 'Sábado',
        7 => 'Domingo',
        _ => 'Dia $dayOfWeek',
      };

  String get shortDayLabel => switch (dayOfWeek) {
        1 => 'Seg',
        2 => 'Ter',
        3 => 'Qua',
        4 => 'Qui',
        5 => 'Sex',
        6 => 'Sáb',
        7 => 'Dom',
        _ => 'D$dayOfWeek',
      };

  bool get isRest => type == WorkoutType.rest;
}
