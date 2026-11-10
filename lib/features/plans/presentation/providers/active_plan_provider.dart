import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runner085/core/providers/user_data_providers.dart';
import 'package:runner085/features/notifications/presentation/providers/notification_settings_provider.dart';
import 'package:runner085/features/plans/data/repositories/active_plan_repository_impl.dart';
import 'package:runner085/features/plans/domain/entities/active_plan.dart';
import 'package:runner085/features/plans/domain/entities/workout.dart';
import 'package:runner085/features/plans/domain/repositories/active_plan_repository.dart';
import 'package:runner085/features/plans/presentation/providers/plans_provider.dart';
import 'package:runner085/features/progress/presentation/providers/workout_progress_provider.dart';

// ── Repositório ──────────────────────────────────────────────────────────────

/// Recriado quando a conta muda (depende do armazenamento do usuário).
final activePlanRepositoryProvider = Provider<ActivePlanRepository>((ref) {
  return ActivePlanRepositoryImpl(ref.watch(userDataStoreProvider));
});

// ── Notifier ─────────────────────────────────────────────────────────────────

class ActivePlanNotifier extends AsyncNotifier<ActivePlan?> {
  @override
  Future<ActivePlan?> build() async {
    // watch: recarrega o plano ao trocar de conta.
    ref.watch(activePlanRepositoryProvider);
    return _load();
  }

  Future<ActivePlan?> _load() async {
    final repo = ref.read(activePlanRepositoryProvider);
    final planId = await repo.getActivePlanId();
    if (planId == null) return null;

    final startDate = await repo.getStartDate();
    if (startDate == null) return null;

    final plan = await ref.read(getPlanByIdUsecaseProvider)(planId);
    if (plan == null) return null;

    return ActivePlan(plan: plan, startDate: startDate);
  }

  /// Ativa um plano a partir de hoje. Limpa o progresso e reagenda notificação.
  Future<void> activate(String planId) async {
    state = const AsyncValue.loading();
    final repo = ref.read(activePlanRepositoryProvider);
    final today = DateTime.now();
    final startDate = DateTime(today.year, today.month, today.day);
    await repo.setActivePlan(planId, startDate);
    await ref.read(workoutProgressRepositoryProvider).clearAll();
    // Garante que o progresso em memória reflita a limpeza.
    ref.invalidate(workoutProgressProvider);
    final loaded = await _load();
    state = AsyncValue.data(loaded);
    if (!kIsWeb) {
      _rescheduleIfEnabled(loaded);
    }
  }

  /// Remove o plano ativo e cancela notificações relacionadas.
  Future<void> deactivate() async {
    state = const AsyncValue.loading();
    await ref.read(activePlanRepositoryProvider).clearActivePlan();
    state = const AsyncValue.data(null);
  }

  void _rescheduleIfEnabled(ActivePlan? activePlan) {
    if (activePlan == null || kIsWeb) return;
    final todayWorkout = activePlan.workoutForDate(DateTime.now());
    final body = todayWorkout != null
        ? 'Hoje: ${todayWorkout.title} — ${todayWorkout.durationMinutes} min 💪'
        : 'Não perca seu treino de hoje!';
    ref
        .read(notificationSettingsProvider.notifier)
        .rescheduleWithBody(body);
  }
}

final activePlanProvider =
    AsyncNotifierProvider<ActivePlanNotifier, ActivePlan?>(
  ActivePlanNotifier.new,
);

// ── Helpers derivados ────────────────────────────────────────────────────────

/// Treino agendado para hoje, derivado do plano ativo.
final todayWorkoutProvider = Provider<Workout?>((ref) {
  final activePlanAsync = ref.watch(activePlanProvider);
  return activePlanAsync.valueOrNull?.workoutForDate(DateTime.now());
});

/// Conjunto de datas que têm treino no plano ativo.
final trainingDaysProvider = Provider<Set<DateTime>>((ref) {
  final activePlanAsync = ref.watch(activePlanProvider);
  return activePlanAsync.valueOrNull?.trainingDays ?? {};
});

/// Treino para uma data específica.
final workoutForDateProvider = Provider.family<Workout?, DateTime>((ref, date) {
  final activePlanAsync = ref.watch(activePlanProvider);
  return activePlanAsync.valueOrNull?.workoutForDate(date);
});
