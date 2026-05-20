import 'package:runner085/features/plans/domain/entities/training_week.dart';
import 'package:runner085/features/plans/domain/enums/race_distance.dart';

/// Um plano de treino completo.
class TrainingPlan {
  final String id;
  final String name;
  final String description;
  final RaceDistance distance;
  final RunnerLevel level;
  final int sessionsPerWeek;
  final List<TrainingWeek> weeks;

  const TrainingPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.distance,
    required this.level,
    required this.sessionsPerWeek,
    required this.weeks,
  });

  int get durationWeeks => weeks.length;

  int get totalSessions =>
      weeks.fold<int>(0, (sum, w) => sum + w.sessionsCount);

  double get totalKm =>
      weeks.fold<double>(0, (sum, w) => sum + w.totalKm);
}
