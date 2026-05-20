import 'package:runner085/features/plans/domain/entities/workout.dart';

/// Uma semana de treino.
class TrainingWeek {
  final int number;
  final String focus;
  final String? notes;
  final List<Workout> workouts;

  const TrainingWeek({
    required this.number,
    required this.focus,
    required this.workouts,
    this.notes,
  });

  /// Soma de minutos de todos os treinos da semana (excluindo descanso).
  int get totalMinutes => workouts
      .where((w) => !w.isRest)
      .fold<int>(0, (sum, w) => sum + w.durationMinutes);

  /// Soma de quilômetros estimados na semana.
  double get totalKm => workouts
      .where((w) => w.distanceKm != null)
      .fold<double>(0, (sum, w) => sum + (w.distanceKm ?? 0));

  /// Quantidade de sessões reais (sem contar dias de descanso).
  int get sessionsCount => workouts.where((w) => !w.isRest).length;
}
