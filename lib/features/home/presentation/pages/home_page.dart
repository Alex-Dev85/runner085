import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runner085/app/router/app_routes.dart';
import 'package:runner085/app/theme/app_colors.dart';
import 'package:runner085/core/utils/extensions.dart';
import 'package:runner085/features/auth/presentation/providers/auth_provider.dart';
import 'package:runner085/features/home/presentation/widgets/week_overview_card.dart';
import 'package:runner085/features/plans/presentation/providers/active_plan_provider.dart';
import 'package:runner085/features/plans/presentation/widgets/recommendation_section.dart';
import 'package:runner085/features/progress/presentation/providers/workout_progress_provider.dart';
import 'package:runner085/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:runner085/features/training/presentation/providers/pace_zones_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final activePlanAsync = ref.watch(activePlanProvider);
    final todayWorkout = ref.watch(todayWorkoutProvider);
    final progressAsync = ref.watch(workoutProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Runner085'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Olá, ${user?.displayName ?? 'Corredor'}!',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pronto para treinar hoje?',
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // ── Treino de hoje ──────────────────────────────────────────
            activePlanAsync.when(
              loading: () => const _SectionCard(
                icon: Icons.fitness_center,
                title: 'Treino de Hoje',
                subtitle: 'Carregando...',
              ),
              error: (_, __) => const _SectionCard(
                icon: Icons.fitness_center,
                title: 'Treino de Hoje',
                subtitle: 'Erro ao carregar',
              ),
              data: (activePlan) {
                if (activePlan == null) {
                  return _SectionCard(
                    icon: Icons.fitness_center,
                    title: 'Treino de Hoje',
                    subtitle: 'Nenhum plano ativo',
                    onTap: () => context.go(AppRoutes.plans),
                  );
                }
                if (todayWorkout == null) {
                  return const _SectionCard(
                    icon: Icons.bedtime_outlined,
                    title: 'Treino de Hoje',
                    subtitle: 'Dia de descanso — recupere-se bem!',
                  );
                }
                final isCompleted = progressAsync.valueOrNull
                        ?.isCompleted(todayWorkout.id) ??
                    false;
                final pace = ref
                    .watch(paceZonesProvider)
                    .valueOrNull
                    ?.rangeFor(todayWorkout.zone)
                    .format(ref.watch(distanceUnitProvider));
                return _TodayWorkoutCard(
                  title: todayWorkout.title,
                  subtitle:
                      '${todayWorkout.durationMinutes} min  •  ${todayWorkout.type.displayName}'
                      '\n${todayWorkout.zone.label} ${todayWorkout.zone.displayName}'
                      '${pace != null ? '  •  $pace' : ''}',
                  isCompleted: isCompleted,
                  onTap: () => context.go(AppRoutes.calendar),
                );
              },
            ),
            const SizedBox(height: 12),

            // ── Semana atual (some se não houver plano ativo) ───────────
            const WeekOverviewCard(),

            // ── Progresso do plano ──────────────────────────────────────
            activePlanAsync.when(
              loading: () => const _SectionCard(
                icon: Icons.trending_up,
                title: 'Progresso',
                subtitle: 'Carregando...',
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (activePlan) {
                if (activePlan == null) {
                  return _SectionCard(
                    icon: Icons.trending_up,
                    title: 'Plano Ativo',
                    subtitle: 'Comece um plano para acompanhar',
                    onTap: () => context.go(AppRoutes.plans),
                  );
                }
                final progress = progressAsync.valueOrNull;
                final completed = progress?.completedIds.length ?? 0;
                final total = activePlan.plan.totalSessions;
                final percent = progress?.completionPercent(total) ?? 0;
                return _ProgressCard(
                  planName: activePlan.plan.name,
                  completed: completed,
                  total: total,
                  percent: percent,
                  onTap: () => context.go(AppRoutes.calendar),
                );
              },
            ),
            const SizedBox(height: 12),

            // ── Streak ──────────────────────────────────────────────────
            progressAsync.when(
              loading: () => const _SectionCard(
                icon: Icons.emoji_events,
                title: 'Sequência',
                subtitle: 'Carregando...',
              ),
              error: (_, __) => const _SectionCard(
                icon: Icons.emoji_events,
                title: 'Sequência',
                subtitle: '0 dias consecutivos',
              ),
              data: (progress) {
                final now = DateTime.now();
                final streak = progress.currentStreak(now);
                final plural = streak > 1 ? 's' : '';
                final String subtitle;
                if (progress.isStreakBroken(now)) {
                  final lost = progress.streakDays;
                  subtitle =
                      'Sequência de $lost dia${lost > 1 ? 's' : ''} perdida — '
                      'treine hoje para recomeçar';
                } else if (streak == 0) {
                  subtitle = 'Nenhum treino ainda';
                } else {
                  subtitle = '$streak dia$plural consecutivo$plural  •  '
                      '${progress.totalMinutes} min treinados';
                }
                return _SectionCard(
                  icon: progress.isStreakBroken(now)
                      ? Icons.local_fire_department_outlined
                      : Icons.local_fire_department,
                  iconColor: progress.isStreakBroken(now)
                      ? context.colorScheme.onSurfaceVariant
                      : (streak > 0 ? AppColors.secondary : null),
                  title: 'Sequência',
                  subtitle: subtitle,
                  onTap: () => context.push(AppRoutes.history),
                );
              },
            ),
            const SizedBox(height: 24),

            // ── Recomendação ────────────────────────────────────────────
            const RecommendationSection(compact: true),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? context.colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
        onTap: onTap,
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String planName;
  final int completed;
  final int total;
  final double percent;
  final VoidCallback onTap;

  const _ProgressCard({
    required this.planName,
    required this.completed,
    required this.total,
    required this.percent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.trending_up, color: context.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      planName,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '$completed/$total treinos',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percent / 100,
                  minHeight: 8,
                  backgroundColor:
                      context.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percent >= 100
                        ? AppColors.success
                        : context.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${percent.toStringAsFixed(0)}% concluído',
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayWorkoutCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final VoidCallback onTap;

  const _TodayWorkoutCard({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isCompleted
        ? AppColors.success.withValues(alpha: 0.15)
        : context.colorScheme.primaryContainer;
    final fg = isCompleted
        ? AppColors.success
        : context.colorScheme.onPrimaryContainer;

    return Card(
      color: bg,
      child: ListTile(
        leading: Icon(
          isCompleted ? Icons.check_circle : Icons.directions_run,
          color: fg,
        ),
        title: Text(
          title,
          style: TextStyle(color: fg, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          isCompleted ? 'Concluído  •  $subtitle' : subtitle,
          style: TextStyle(color: fg.withValues(alpha: 0.8)),
        ),
        trailing: Icon(Icons.chevron_right, color: fg),
        onTap: onTap,
      ),
    );
  }
}
