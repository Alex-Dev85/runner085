import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runner085/app/router/app_routes.dart';
import 'package:runner085/app/theme/app_colors.dart';
import 'package:runner085/core/utils/extensions.dart';
import 'package:runner085/features/plans/presentation/providers/active_plan_provider.dart';
import 'package:runner085/features/progress/presentation/providers/workout_progress_provider.dart';

enum _DayStatus { rest, done, missed, today, upcoming }

/// Visão dos 7 dias da semana corrente (segunda a domingo) com o status
/// de cada dia no plano ativo. Não renderiza nada se não houver plano ativo.
class WeekOverviewCard extends ConsumerWidget {
  const WeekOverviewCard({super.key});

  static const _dayLabels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
  static const _dayNames = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePlan = ref.watch(activePlanProvider).valueOrNull;
    if (activePlan == null) return const SizedBox.shrink();

    final progress = ref.watch(workoutProgressProvider).valueOrNull;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = DateTime(
      today.year,
      today.month,
      today.day - (today.weekday - 1),
    );

    final statuses = <_DayStatus>[];
    final days = <DateTime>[];
    var planned = 0;
    var done = 0;

    for (var i = 0; i < 7; i++) {
      final day = DateTime(monday.year, monday.month, monday.day + i);
      days.add(day);
      final workout = activePlan.workoutForDate(day);
      if (workout == null) {
        statuses.add(_DayStatus.rest);
        continue;
      }
      planned++;
      final completed = progress?.isCompleted(workout.id) ?? false;
      if (completed) {
        done++;
        statuses.add(_DayStatus.done);
      } else if (day.isBefore(today)) {
        statuses.add(_DayStatus.missed);
      } else if (day == today) {
        statuses.add(_DayStatus.today);
      } else {
        statuses.add(_DayStatus.upcoming);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.go(AppRoutes.calendar),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.date_range,
                        color: context.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Esta semana',
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        planned == 0
                            ? 'Sem treinos'
                            : '$done/$planned treinos',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    for (var i = 0; i < 7; i++)
                      Expanded(
                        child: _DayCell(
                          label: _dayLabels[i],
                          dayName: _dayNames[i],
                          dayOfMonth: days[i].day,
                          status: statuses[i],
                          isToday: days[i] == today,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final String label;
  final String dayName;
  final int dayOfMonth;
  final _DayStatus status;
  final bool isToday;

  const _DayCell({
    required this.label,
    required this.dayName,
    required this.dayOfMonth,
    required this.status,
    required this.isToday,
  });

  String get _statusText => switch (status) {
        _DayStatus.rest => 'descanso',
        _DayStatus.done => 'treino concluído',
        _DayStatus.missed => 'treino não realizado',
        _DayStatus.today => 'treino de hoje pendente',
        _DayStatus.upcoming => 'treino agendado',
      };

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    final (Color background, Color foreground, IconData icon) =
        switch (status) {
      _DayStatus.rest => (
          Colors.transparent,
          scheme.onSurfaceVariant.withValues(alpha: 0.6),
          Icons.remove,
        ),
      _DayStatus.done => (
          AppColors.success.withValues(alpha: 0.18),
          AppColors.success,
          Icons.check,
        ),
      _DayStatus.missed => (
          AppColors.secondary.withValues(alpha: 0.18),
          AppColors.secondary,
          Icons.close,
        ),
      _DayStatus.today => (
          scheme.primary,
          scheme.onPrimary,
          Icons.directions_run,
        ),
      _DayStatus.upcoming => (
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant,
          Icons.directions_run,
        ),
    };

    final labelColor = isToday ? scheme.primary : scheme.onSurfaceVariant;
    final labelWeight = isToday ? FontWeight.bold : FontWeight.normal;

    return Semantics(
      label: '$dayName, dia $dayOfMonth, $_statusText',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: labelColor,
              fontWeight: labelWeight,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
              border: isToday && status != _DayStatus.today
                  ? Border.all(color: scheme.primary, width: 2)
                  : null,
            ),
            child: Icon(icon, size: 18, color: foreground),
          ),
          const SizedBox(height: 6),
          Text(
            '$dayOfMonth',
            style: context.textTheme.labelSmall?.copyWith(
              color: labelColor,
              fontWeight: labelWeight,
            ),
          ),
        ],
      ),
    );
  }
}
