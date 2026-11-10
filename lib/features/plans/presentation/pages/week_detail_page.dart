import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runner085/app/router/app_routes.dart';
import 'package:runner085/core/utils/extensions.dart';
import 'package:runner085/core/widgets/app_error_widget.dart';
import 'package:runner085/core/widgets/app_loading.dart';
import 'package:runner085/features/plans/domain/entities/training_plan.dart';
import 'package:runner085/features/plans/domain/entities/training_week.dart';
import 'package:runner085/features/plans/presentation/providers/plans_provider.dart';
import 'package:runner085/features/plans/presentation/widgets/workout_tile.dart';
import 'package:runner085/features/settings/presentation/providers/app_settings_provider.dart';

class WeekDetailPage extends ConsumerWidget {
  final String planId;
  final int weekNumber;

  const WeekDetailPage({
    super.key,
    required this.planId,
    required this.weekNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(planByIdProvider(planId));

    return planAsync.when(
      data: (plan) {
        if (plan == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Plano não encontrado')),
          );
        }
        final week = plan.weeks.firstWhere(
          (w) => w.number == weekNumber,
          orElse: () => plan.weeks.first,
        );
        return _WeekContent(plan: plan, week: week);
      },
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: 'Erro ao carregar semana: $e',
          onRetry: () => ref.invalidate(planByIdProvider(planId)),
        ),
      ),
    );
  }
}

class _WeekContent extends ConsumerWidget {
  final TrainingPlan plan;
  final TrainingWeek week;

  const _WeekContent({required this.plan, required this.week});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(distanceUnitProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Semana ${week.number}'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.colorScheme.primary,
                    context.colorScheme.primaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    week.focus,
                    style: context.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plan.name,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _InlineStat(
                        icon: Icons.fitness_center,
                        label: '${week.sessionsCount} treinos',
                      ),
                      const SizedBox(width: 16),
                      _InlineStat(
                        icon: Icons.straighten,
                        label: unit.format(week.totalKm, decimals: 0),
                      ),
                      const SizedBox(width: 16),
                      _InlineStat(
                        icon: Icons.timer_outlined,
                        label: '${week.totalMinutes} min',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (week.notes != null) ...[
              const SizedBox(height: 16),
              Card(
                color: context.colorScheme.tertiaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: context.colorScheme.onTertiaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          week.notes!,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Treinos',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._buildWeekSchedule(context, plan, week),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildWeekSchedule(
    BuildContext context,
    TrainingPlan plan,
    TrainingWeek week,
  ) {
    // Build a complete 7-day view, marking rest days where no workout exists.
    final byDay = {for (final w in week.workouts) w.dayOfWeek: w};
    return [
      for (int day = 1; day <= 7; day++)
        if (byDay[day] != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: WorkoutTile(
              workout: byDay[day]!,
              onTap: () => context.push(
                '${AppRoutes.plans}/${plan.id}/week/${week.number}/workout/${byDay[day]!.id}',
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _RestDayTile(dayOfWeek: day),
          ),
    ];
  }
}

class _InlineStat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InlineStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _RestDayTile extends StatelessWidget {
  final int dayOfWeek;

  const _RestDayTile({required this.dayOfWeek});

  String get _dayLabel => switch (dayOfWeek) {
        1 => 'Segunda',
        2 => 'Terça',
        3 => 'Quarta',
        4 => 'Quinta',
        5 => 'Sexta',
        6 => 'Sábado',
        7 => 'Domingo',
        _ => 'Dia $dayOfWeek',
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.colorScheme.surfaceContainerHighest,
      elevation: 0,
      child: ListTile(
        leading: const Icon(Icons.bedtime_outlined),
        title: Text(_dayLabel),
        subtitle: const Text('Descanso'),
      ),
    );
  }
}
