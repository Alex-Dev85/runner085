import 'package:runner085/features/plans/domain/entities/workout.dart';

/// Um item do histórico: treino concluído + data em que foi feito.
class HistoryEntry {
  final Workout workout;
  final DateTime completedAt;

  const HistoryEntry({
    required this.workout,
    required this.completedAt,
  });
}
