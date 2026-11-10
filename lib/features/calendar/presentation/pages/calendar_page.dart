import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runner085/app/router/app_routes.dart';
import 'package:runner085/app/theme/app_colors.dart';
import 'package:runner085/core/utils/extensions.dart';
import 'package:runner085/features/plans/domain/entities/workout.dart';
import 'package:runner085/features/plans/presentation/providers/active_plan_provider.dart';
import 'package:runner085/features/plans/presentation/providers/plans_provider.dart';
import 'package:runner085/features/progress/presentation/providers/workout_progress_provider.dart';
import 'package:runner085/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:runner085/features/training/presentation/providers/pace_zones_provider.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final activePlanAsync = ref.watch(activePlanProvider);
    final trainingDays = ref.watch(trainingDaysProvider);
    final completedDays = ref.watch(completedTrainingDaysProvider);
    final workoutToday = ref.watch(workoutForDateProvider(_selectedDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendário'),
        actions: [
          activePlanAsync.valueOrNull != null
              ? TextButton.icon(
                  onPressed: _confirmDeactivate,
                  icon: const Icon(Icons.stop_circle_outlined, size: 18),
                  label: const Text('Desativar'),
                  style: TextButton.styleFrom(
                    foregroundColor: context.colorScheme.error,
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
      body: SafeArea(
        child: activePlanAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erro: $e')),
          data: (activePlan) => Column(
            children: [
              // ── Banner do plano ativo ──────────────────────────────────
              if (activePlan != null)
                _ActivePlanBanner(activePlan: activePlan)
              else
                _NoPlanBanner(onSelectPlan: () => context.push(AppRoutes.plans)),

              // ── Calendário ────────────────────────────────────────────
              _MonthCalendar(
                focusedMonth: _focusedMonth,
                selectedDate: _selectedDate,
                trainingDays: trainingDays,
                completedDays: completedDays,
                onDateSelected: (date) {
                  setState(() => _selectedDate = date);
                },
                onMonthChanged: (month) {
                  setState(() => _focusedMonth = month);
                },
              ),

              const Divider(height: 1),

              // ── Treino do dia selecionado ──────────────────────────────
              Expanded(
                child: _DayWorkoutPanel(
                  date: _selectedDate,
                  workout: workoutToday,
                  activePlan: activePlan,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeactivate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desativar plano?'),
        content: const Text(
          'O plano ativo será removido. Você poderá escolher outro na aba Planos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: context.colorScheme.error,
            ),
            child: const Text('Desativar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(activePlanProvider.notifier).deactivate();
    }
  }
}

// ── Banner: plano ativo ───────────────────────────────────────────────────────

class _ActivePlanBanner extends StatelessWidget {
  final dynamic activePlan; // ActivePlan

  const _ActivePlanBanner({required this.activePlan});

  @override
  Widget build(BuildContext context) {
    final plan = activePlan.plan;
    final start = activePlan.startDate as DateTime;
    final end = activePlan.endDate as DateTime;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colorScheme.primary,
            context.colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_run, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name as String,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${start.formattedDate} → ${end.formattedDate}  •  ${plan.durationWeeks} semanas',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Banner: sem plano ─────────────────────────────────────────────────────────

class _NoPlanBanner extends StatelessWidget {
  final VoidCallback onSelectPlan;

  const _NoPlanBanner({required this.onSelectPlan});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: context.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Nenhum plano ativo. Escolha um plano para ver seus treinos aqui.',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onSelectPlan,
            child: const Text('Ver planos'),
          ),
        ],
      ),
    );
  }
}

// ── Calendário mensal ─────────────────────────────────────────────────────────

class _MonthCalendar extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDate;
  final Set<DateTime> trainingDays;
  final Set<DateTime> completedDays;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime> onMonthChanged;

  const _MonthCalendar({
    required this.focusedMonth,
    required this.selectedDate,
    required this.trainingDays,
    required this.completedDays,
    required this.onDateSelected,
    required this.onMonthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Cabeçalho do mês
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => onMonthChanged(
                  DateTime(focusedMonth.year, focusedMonth.month - 1),
                ),
              ),
              Expanded(
                child: Text(
                  _monthLabel(focusedMonth),
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => onMonthChanged(
                  DateTime(focusedMonth.year, focusedMonth.month + 1),
                ),
              ),
            ],
          ),
        ),
        // Dias da semana
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom']
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 4),
        // Grade de dias
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _buildGrid(context),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildGrid(BuildContext context) {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    // weekday: 1=seg, 7=dom → offset para alinhar na grade
    final startOffset = firstDay.weekday - 1;
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (rowIdx) {
        return Row(
          children: List.generate(7, (colIdx) {
            final cellIdx = rowIdx * 7 + colIdx;
            final dayNum = cellIdx - startOffset + 1;
            if (dayNum < 1 || dayNum > daysInMonth) {
              return const Expanded(child: SizedBox(height: 40));
            }
            final date = DateTime(focusedMonth.year, focusedMonth.month, dayNum);
            final isSelected = _isSameDay(date, selectedDate);
            final isToday = _isSameDay(date, DateTime.now());
            final dateOnly = DateTime(date.year, date.month, date.day);
            final hasTraining = trainingDays.contains(dateOnly);
            final isCompleted = completedDays.contains(dateOnly);

            return Expanded(
              child: GestureDetector(
                onTap: () => onDateSelected(date),
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.colorScheme.primary
                        : isToday
                            ? context.colorScheme.primaryContainer
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? context.colorScheme.onPrimary
                              : isToday
                                  ? context.colorScheme.onPrimaryContainer
                                  : context.colorScheme.onSurface,
                        ),
                      ),
                      if (hasTraining || isCompleted)
                        Positioned(
                          bottom: 4,
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : isCompleted
                                      ? AppColors.success
                                      : AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthLabel(DateTime dt) {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }
}

// ── Painel do treino do dia ───────────────────────────────────────────────────

class _DayWorkoutPanel extends ConsumerWidget {
  final DateTime date;
  final Workout? workout;
  final dynamic activePlan; // ActivePlan?

  const _DayWorkoutPanel({
    required this.date,
    required this.workout,
    required this.activePlan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _dateLabel(date),
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (activePlan == null)
            _EmptyState(
              icon: Icons.calendar_today_outlined,
              message: 'Ative um plano para ver seus treinos aqui.',
            )
          else if (workout == null)
            _EmptyState(
              icon: Icons.bedtime_outlined,
              message: 'Dia de descanso. Aproveite para recuperar!',
            )
          else
            _WorkoutCard(workout: workout!, planId: activePlan!.plan.id as String),
        ],
      ),
    );
  }

  String _dateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);
    if (d == today) return 'Hoje — ${dt.formattedDate}';
    if (d == today.add(const Duration(days: 1))) {
      return 'Amanhã — ${dt.formattedDate}';
    }
    if (d == today.subtract(const Duration(days: 1))) {
      return 'Ontem — ${dt.formattedDate}';
    }
    return dt.formattedDate;
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutCard extends ConsumerWidget {
  final Workout workout;
  final String planId;

  const _WorkoutCard({required this.workout, required this.planId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(distanceUnitProvider);
    final isCompleted = ref.watch(isWorkoutCompletedProvider(workout.id));
    final progressAsync = ref.watch(workoutProgressProvider);
    final isLoading = progressAsync.isLoading;
    final pace = workout.isRest
        ? null
        : ref
            .watch(paceZonesProvider)
            .valueOrNull
            ?.rangeFor(workout.zone)
            .format(unit);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho colorido
            Row(
              children: [
                Container(
                  width: 6,
                  height: 40,
                  decoration: BoxDecoration(
                    color: workout.zone.color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.title,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        workout.type.displayName,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: workout.zone.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Concluído',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Métricas
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                _Metric(
                  icon: Icons.timer_outlined,
                  value: '${workout.durationMinutes} min',
                ),
                if (workout.distanceKm != null)
                  _Metric(
                    icon: Icons.straighten,
                    value: unit.format(workout.distanceKm!),
                  ),
                if (pace != null)
                  _Metric(
                    icon: Icons.speed,
                    value: '${workout.zone.label} • $pace',
                  ),
                _Metric(
                  icon: Icons.favorite_outline,
                  value: workout.zone.hrRange,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              workout.description,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            if (workout.structure != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.list_alt_outlined, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        workout.structure!,
                        style: context.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Botão marcar como concluído / desfazer
            SizedBox(
              width: double.infinity,
              child: isCompleted
                  ? OutlinedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => ref
                              .read(workoutProgressProvider.notifier)
                              .markUncompleted(
                                workoutId: workout.id,
                                durationMinutes: workout.durationMinutes,
                              ),
                      icon: const Icon(Icons.undo, size: 18),
                      label: const Text('Desfazer conclusão'),
                    )
                  : FilledButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => ref
                              .read(workoutProgressProvider.notifier)
                              .markCompleted(
                                workoutId: workout.id,
                                durationMinutes: workout.durationMinutes,
                              ),
                      icon: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Marcar como concluído'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String value;

  const _Metric({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          value,
          style: context.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
