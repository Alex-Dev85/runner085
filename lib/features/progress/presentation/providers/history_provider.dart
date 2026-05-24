import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runner085/features/plans/presentation/providers/active_plan_provider.dart';
import 'package:runner085/features/progress/domain/history_entry.dart';
import 'package:runner085/features/progress/presentation/providers/workout_progress_provider.dart';

/// Lista de treinos concluídos, ordenada do mais recente ao mais antigo.
/// Cruza os IDs do WorkoutProgressState com os workouts do plano ativo.
final historyProvider = Provider<List<HistoryEntry>>((ref) {
  final progress = ref.watch(workoutProgressProvider).valueOrNull;
  final activePlan = ref.watch(activePlanProvider).valueOrNull;

  if (progress == null || activePlan == null) return [];
  if (progress.completedDates.isEmpty) return [];

  // Monta um mapa rápido workoutId → Workout a partir de todas as semanas.
  final workoutMap = <String, dynamic>{};
  for (final week in activePlan.plan.weeks) {
    for (final workout in week.workouts) {
      workoutMap[workout.id] = workout;
    }
  }

  final entries = <HistoryEntry>[];
  for (final entry in progress.completedDates.entries) {
    final workout = workoutMap[entry.key];
    if (workout == null) continue; // ID não pertence ao plano atual
    entries.add(HistoryEntry(workout: workout, completedAt: entry.value));
  }

  // Mais recente primeiro.
  entries.sort((a, b) => b.completedAt.compareTo(a.completedAt));
  return entries;
});

/// Histórico agrupado por mês: { 'Maio 2026': [entries] }
final historyByMonthProvider =
    Provider<Map<String, List<HistoryEntry>>>((ref) {
  final entries = ref.watch(historyProvider);
  final grouped = <String, List<HistoryEntry>>{};

  for (final entry in entries) {
    final key = _monthKey(entry.completedAt);
    grouped.putIfAbsent(key, () => []).add(entry);
  }

  return grouped;
});

String _monthKey(DateTime dt) {
  const months = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];
  return '${months[dt.month - 1]} ${dt.year}';
}
