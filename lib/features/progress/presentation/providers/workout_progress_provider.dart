import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runner085/features/plans/presentation/providers/active_plan_provider.dart';
import 'package:runner085/features/progress/data/workout_progress_repository.dart';

// ── Repositório ───────────────────────────────────────────────────────────────

final workoutProgressRepositoryProvider =
    Provider<WorkoutProgressRepository>((ref) {
  return WorkoutProgressRepository();
});

// ── Estado ────────────────────────────────────────────────────────────────────

class WorkoutProgressState {
  final Set<String> completedIds;
  final Map<String, DateTime> completedDates;
  final int totalMinutes;
  final int streakDays;
  final DateTime? lastTrainingDate;

  const WorkoutProgressState({
    required this.completedIds,
    required this.completedDates,
    required this.totalMinutes,
    required this.streakDays,
    this.lastTrainingDate,
  });

  const WorkoutProgressState.empty()
      : completedIds = const {},
        completedDates = const {},
        totalMinutes = 0,
        streakDays = 0,
        lastTrainingDate = null;

  bool isCompleted(String workoutId) => completedIds.contains(workoutId);

  /// Sequência ainda válida em [now]: continua valendo se o último treino
  /// foi hoje ou ontem; caso contrário a sequência foi perdida e vale 0.
  int currentStreak(DateTime now) {
    final last = lastTrainingDate;
    if (last == null) return 0;
    final daysSinceLast = DateTime.utc(now.year, now.month, now.day)
        .difference(DateTime.utc(last.year, last.month, last.day))
        .inDays;
    return daysSinceLast <= 1 ? streakDays : 0;
  }

  /// Havia uma sequência registrada, mas ela foi perdida.
  bool isStreakBroken(DateTime now) =>
      streakDays > 0 && lastTrainingDate != null && currentStreak(now) == 0;

  /// Percentual de conclusão em relação ao total de sessões do plano.
  double completionPercent(int totalSessions) =>
      totalSessions > 0 ? (completedIds.length / totalSessions) * 100 : 0;

  WorkoutProgressState copyWith({
    Set<String>? completedIds,
    Map<String, DateTime>? completedDates,
    int? totalMinutes,
    int? streakDays,
    DateTime? lastTrainingDate,
  }) {
    return WorkoutProgressState(
      completedIds: completedIds ?? this.completedIds,
      completedDates: completedDates ?? this.completedDates,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      streakDays: streakDays ?? this.streakDays,
      lastTrainingDate: lastTrainingDate ?? this.lastTrainingDate,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class WorkoutProgressNotifier
    extends AsyncNotifier<WorkoutProgressState> {
  @override
  Future<WorkoutProgressState> build() async {
    return _load();
  }

  Future<WorkoutProgressState> _load() async {
    final repo = ref.read(workoutProgressRepositoryProvider);
    final results = await Future.wait([
      repo.getCompletedIds(),
      repo.getCompletedDates(),
      repo.getTotalMinutes(),
      repo.getStreakDays(),
      repo.getLastTrainingDate(),
    ]);

    return WorkoutProgressState(
      completedIds: results[0] as Set<String>,
      completedDates: results[1] as Map<String, DateTime>,
      totalMinutes: results[2] as int,
      streakDays: results[3] as int,
      lastTrainingDate: results[4] as DateTime?,
    );
  }

  Future<void> markCompleted({
    required String workoutId,
    required int durationMinutes,
  }) async {
    final repo = ref.read(workoutProgressRepositoryProvider);
    await repo.markCompleted(
      workoutId: workoutId,
      durationMinutes: durationMinutes,
      date: DateTime.now(),
    );
    state = AsyncValue.data(await _load());
  }

  Future<void> markUncompleted({
    required String workoutId,
    required int durationMinutes,
  }) async {
    final repo = ref.read(workoutProgressRepositoryProvider);
    await repo.markUncompleted(
      workoutId: workoutId,
      durationMinutes: durationMinutes,
    );
    state = AsyncValue.data(await _load());
  }

  /// Limpa o progresso ao ativar um novo plano.
  Future<void> reset() async {
    await ref.read(workoutProgressRepositoryProvider).clearAll();
    state = const AsyncValue.data(WorkoutProgressState.empty());
  }
}

final workoutProgressProvider =
    AsyncNotifierProvider<WorkoutProgressNotifier, WorkoutProgressState>(
  WorkoutProgressNotifier.new,
);

// ── Helpers derivados ─────────────────────────────────────────────────────────

/// Conjunto de datas em que treinos foram concluídos.
final completedTrainingDaysProvider = Provider<Set<DateTime>>((ref) {
  final progress = ref.watch(workoutProgressProvider).valueOrNull;
  if (progress == null) return {};
  return progress.completedDates.values
      .map((d) => DateTime(d.year, d.month, d.day))
      .toSet();
});

/// Se um workout específico está concluído.
final isWorkoutCompletedProvider =
    Provider.family<bool, String>((ref, workoutId) {
  final progress = ref.watch(workoutProgressProvider).valueOrNull;
  return progress?.isCompleted(workoutId) ?? false;
});
