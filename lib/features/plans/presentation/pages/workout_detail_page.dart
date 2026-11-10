import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runner085/app/router/app_routes.dart';
import 'package:runner085/app/theme/app_colors.dart';
import 'package:runner085/core/utils/extensions.dart';
import 'package:runner085/core/widgets/app_error_widget.dart';
import 'package:runner085/core/widgets/app_loading.dart';
import 'package:runner085/features/plans/domain/entities/workout.dart';
import 'package:runner085/features/plans/presentation/providers/plans_provider.dart';
import 'package:runner085/features/progress/presentation/providers/workout_progress_provider.dart';
import 'package:runner085/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:runner085/features/training/presentation/providers/pace_zones_provider.dart';

class WorkoutDetailPage extends ConsumerWidget {
  final String planId;
  final int weekNumber;
  final String workoutId;

  const WorkoutDetailPage({
    super.key,
    required this.planId,
    required this.weekNumber,
    required this.workoutId,
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
        final workout = week.workouts.firstWhere(
          (w) => w.id == workoutId,
          orElse: () => week.workouts.first,
        );
        return _WorkoutContent(workout: workout);
      },
      loading: () => const Scaffold(body: AppLoading()),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: 'Erro ao carregar treino: $e',
          onRetry: () => ref.invalidate(planByIdProvider(planId)),
        ),
      ),
    );
  }
}

class _WorkoutContent extends ConsumerWidget {
  final Workout workout;

  const _WorkoutContent({required this.workout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = ref.watch(isWorkoutCompletedProvider(workout.id));
    final progressAsync = ref.watch(workoutProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(workout.dayLabel),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Hero(workout: workout),
            const SizedBox(height: 16),
            _MetricsRow(workout: workout),
            const SizedBox(height: 16),
            _Section(
              title: 'Tipo de treino',
              child: _InfoCard(
                icon: Icons.directions_run,
                title: workout.type.displayName,
                subtitle: workout.type.description,
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Zona alvo',
              child: _ZoneCard(workout: workout),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Como fazer',
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workout.description,
                        style: context.textTheme.bodyMedium,
                      ),
                      if (workout.structure != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.list_alt_outlined, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  workout.structure!,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (isCompleted)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Treino concluído!',
                          style: context.textTheme.titleSmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: progressAsync.isLoading
                          ? null
                          : () => ref
                              .read(workoutProgressProvider.notifier)
                              .markUncompleted(
                                workoutId: workout.id,
                                durationMinutes: workout.durationMinutes,
                              ),
                      icon: const Icon(Icons.undo, size: 18),
                      label: const Text('Desfazer conclusão'),
                    ),
                  ),
                ],
              )
            else
              FilledButton.icon(
                onPressed: progressAsync.isLoading
                    ? null
                    : () async {
                        await ref
                            .read(workoutProgressProvider.notifier)
                            .markCompleted(
                              workoutId: workout.id,
                              durationMinutes: workout.durationMinutes,
                            );
                        if (context.mounted) {
                          context.showSnackBar('Treino marcado como concluído!');
                        }
                      },
                icon: progressAsync.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: const Text('Marcar como concluído'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: AppColors.success,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final Workout workout;

  const _Hero({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            workout.zone.color.withValues(alpha: 0.85),
            workout.zone.color.withValues(alpha: 0.55),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            workout.dayLabel.toUpperCase(),
            style: context.textTheme.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            workout.title,
            style: context.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsRow extends ConsumerWidget {
  final Workout workout;

  const _MetricsRow({required this.workout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(distanceUnitProvider);
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.timer_outlined,
            value: '${workout.durationMinutes}',
            label: 'minutos',
          ),
        ),
        const SizedBox(width: 8),
        if (workout.distanceKm != null)
          Expanded(
            child: _MetricCard(
              icon: Icons.straighten,
              value: unit.fromKm(workout.distanceKm!).toStringAsFixed(1),
              label: unit.label,
            ),
          ),
        if (workout.distanceKm == null) const Spacer(),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: context.colorScheme.primary),
            const SizedBox(height: 6),
            Text(
              value,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: context.colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoneCard extends ConsumerWidget {
  final Workout workout;

  const _ZoneCard({required this.workout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zones = ref.watch(paceZonesProvider).valueOrNull;
    final unit = ref.watch(distanceUnitProvider);
    final pace = zones?.rangeFor(workout.zone).format(unit);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 56,
              decoration: BoxDecoration(
                color: workout.zone.color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        workout.zone.label,
                        style: context.textTheme.labelLarge?.copyWith(
                          color: workout.zone.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        workout.zone.displayName,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (pace != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.speed, size: 16, color: workout.zone.color),
                          const SizedBox(width: 4),
                          Text(
                            'Ritmo: $pace',
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    workout.zone.hrRange,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(workout.zone.description),
                  if (pace == null) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => context.go(AppRoutes.training),
                      child: Text(
                        'Faça o teste de 3 km para ver seu ritmo nesta zona →',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
