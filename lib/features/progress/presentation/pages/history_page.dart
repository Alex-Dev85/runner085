import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runner085/app/theme/app_colors.dart';
import 'package:runner085/core/utils/extensions.dart';
import 'package:runner085/features/plans/domain/entities/workout.dart';
import 'package:runner085/features/plans/presentation/providers/active_plan_provider.dart';
import 'package:runner085/features/progress/domain/history_entry.dart';
import 'package:runner085/features/progress/presentation/providers/history_provider.dart';
import 'package:runner085/features/progress/presentation/providers/workout_progress_provider.dart';
import 'package:runner085/features/settings/presentation/providers/app_settings_provider.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePlanAsync = ref.watch(activePlanProvider);
    final progressAsync = ref.watch(workoutProgressProvider);
    final byMonth = ref.watch(historyByMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico'),
      ),
      body: SafeArea(
        child: activePlanAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Erro: $e')),
          data: (activePlan) {
            if (activePlan == null) {
              return _EmptyState(
                icon: Icons.history_outlined,
                title: 'Nenhum plano ativo',
                subtitle:
                    'Ative um plano de treino para começar a registrar seu histórico.',
              );
            }

            return progressAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erro: $e')),
              data: (progress) {
                if (byMonth.isEmpty) {
                  return _EmptyState(
                    icon: Icons.directions_run_outlined,
                    title: 'Nenhum treino concluído',
                    subtitle:
                        'Complete seu primeiro treino para ver o histórico aqui.',
                  );
                }

                final totalSessions = activePlan.plan.totalSessions;
                return CustomScrollView(
                  slivers: [
                    // ── Resumo no topo ──────────────────────────────────
                    SliverToBoxAdapter(
                      child: _SummaryHeader(
                        completed: progress.completedIds.length,
                        total: totalSessions,
                        totalMinutes: progress.totalMinutes,
                        streakDays: progress.streakDays,
                        percent: progress.completionPercent(totalSessions),
                      ),
                    ),

                    // ── Lista agrupada por mês ──────────────────────────
                    for (final month in byMonth.keys) ...[
                      SliverToBoxAdapter(
                        child: _MonthHeader(month: month),
                      ),
                      SliverList.separated(
                        itemCount: byMonth[month]!.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final entry = byMonth[month]![index];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: _HistoryCard(entry: entry, ref: ref),
                          );
                        },
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 8)),
                    ],

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ── Resumo ────────────────────────────────────────────────────────────────────

class _SummaryHeader extends StatelessWidget {
  final int completed;
  final int total;
  final int totalMinutes;
  final int streakDays;
  final double percent;

  const _SummaryHeader({
    required this.completed,
    required this.total,
    required this.totalMinutes,
    required this.streakDays,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colorScheme.primary,
            context.colorScheme.primaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seu progresso',
            style: context.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatBadge(
                  value: '$completed/$total',
                  label: 'Treinos',
                  icon: Icons.check_circle_outline,
                ),
              ),
              Expanded(
                child: _StatBadge(
                  value: totalMinutes >= 60
                      ? '${(totalMinutes / 60).toStringAsFixed(1)}h'
                      : '${totalMinutes}min',
                  label: 'Tempo total',
                  icon: Icons.timer_outlined,
                ),
              ),
              Expanded(
                child: _StatBadge(
                  value: '$streakDays',
                  label: 'Sequência',
                  icon: Icons.local_fire_department_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${percent.toStringAsFixed(0)}% concluído',
                style: context.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              Text(
                '${total - completed} restantes',
                style: context.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatBadge({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}

// ── Cabeçalho de mês ──────────────────────────────────────────────────────────

class _MonthHeader extends StatelessWidget {
  final String month;

  const _MonthHeader({required this.month});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        month,
        style: context.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: context.colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ── Card de treino ────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  final HistoryEntry entry;
  final WidgetRef ref;

  const _HistoryCard({required this.entry, required this.ref});

  @override
  Widget build(BuildContext context) {
    final unit = ref.watch(distanceUnitProvider);
    final workout = entry.workout;
    final date = entry.completedAt;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // ── Indicador de zona ───────────────────────────────────────
            Container(
              width: 4,
              height: 56,
              decoration: BoxDecoration(
                color: workout.zone.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),

            // ── Ícone do tipo ───────────────────────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: workout.zone.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _iconForType(workout),
                color: workout.zone.color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // ── Informações ─────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.title,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    workout.type.displayName,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: workout.zone.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      _Chip(
                        icon: Icons.timer_outlined,
                        label: '${workout.durationMinutes} min',
                      ),
                      if (workout.distanceKm != null)
                        _Chip(
                          icon: Icons.straighten,
                          label: unit.format(workout.distanceKm!),
                        ),
                      _Chip(
                        icon: Icons.favorite_outline,
                        label: workout.zone.label,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── Data + botão desfazer ───────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 12,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _shortDate(date),
                        style: context.textTheme.labelSmall?.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _confirmUndo(context),
                  child: Text(
                    'Desfazer',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmUndo(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desfazer conclusão?'),
        content: Text(
          'O treino "${entry.workout.title}" será removido do histórico.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Desfazer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(workoutProgressProvider.notifier).markUncompleted(
            workoutId: entry.workout.id,
            durationMinutes: entry.workout.durationMinutes,
          );
    }
  }

  IconData _iconForType(Workout workout) {
    return switch (workout.type.name) {
      'easy' => Icons.directions_run,
      'recovery' => Icons.self_improvement,
      'longRun' => Icons.route_outlined,
      'tempo' => Icons.speed,
      'interval' => Icons.repeat,
      'fartlek' => Icons.shuffle,
      'hillRepeat' => Icons.terrain,
      'raceSimulation' => Icons.emoji_events_outlined,
      _ => Icons.fitness_center,
    };
  }

  String _shortDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);
    if (d == today) return 'Hoje';
    if (d == today.subtract(const Duration(days: 1))) return 'Ontem';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: context.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ── Estado vazio ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 72,
              color: context.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: context.textTheme.bodyMedium?.copyWith(
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
