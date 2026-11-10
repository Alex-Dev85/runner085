import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runner085/app/router/app_routes.dart';
import 'package:runner085/core/utils/extensions.dart';
import 'package:runner085/core/widgets/app_error_widget.dart';
import 'package:runner085/core/widgets/app_loading.dart';
import 'package:runner085/features/plans/domain/entities/training_plan.dart';
import 'package:runner085/features/plans/domain/entities/training_week.dart';
import 'package:runner085/features/plans/presentation/providers/active_plan_provider.dart';
import 'package:runner085/features/plans/presentation/providers/plans_provider.dart';
import 'package:runner085/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:runner085/features/settings/presentation/providers/app_settings_provider.dart';

class PlanDetailPage extends ConsumerWidget {
  final String planId;

  const PlanDetailPage({super.key, required this.planId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(planByIdProvider(planId));

    return Scaffold(
      body: planAsync.when(
        data: (plan) {
          if (plan == null) {
            return const _NotFound();
          }
          return _PlanDetailContent(plan: plan);
        },
        loading: () => const Scaffold(body: AppLoading()),
        error: (e, _) => Scaffold(
          appBar: AppBar(),
          body: AppErrorWidget(
            message: 'Erro ao carregar plano: $e',
            onRetry: () => ref.invalidate(planByIdProvider(planId)),
          ),
        ),
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text('Plano não encontrado')),
    );
  }
}

class _PlanDetailContent extends ConsumerWidget {
  final TrainingPlan plan;

  const _PlanDetailContent({required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = context.colorScheme;
    final activePlanAsync = ref.watch(activePlanProvider);
    final isActive = activePlanAsync.valueOrNull?.plan.id == plan.id;
    final isLoading = activePlanAsync.isLoading;
    // Mantém perfil e preferências carregados para o aviso de compatibilidade.
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final desiredFrequency =
        ref.watch(appSettingsProvider).valueOrNull?.weeklyFrequency;
    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          pinned: true,
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              plan.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [scheme.primary, scheme.primaryContainer],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.distance.fullName,
                        style: TextStyle(
                          color: scheme.onPrimary.withValues(alpha: 0.85),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatsRow(plan: plan),
                const SizedBox(height: 16),
                Text(
                  'Sobre o plano',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  plan.description,
                  style: context.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Text(
                  'Cronograma',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        SliverList.separated(
          itemCount: plan.weeks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final week = plan.weeks[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _WeekRow(
                plan: plan,
                week: week,
              ),
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: isActive
                ? OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () async {
                            await ref
                                .read(activePlanProvider.notifier)
                                .deactivate();
                            if (context.mounted) {
                              context.showSnackBar('Plano desativado.');
                            }
                          },
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text('Desativar plano'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      foregroundColor: scheme.error,
                    ),
                  )
                : FilledButton.icon(
                    onPressed: isLoading
                        ? null
                        : () async {
                            final warnings = <String>[
                              if (profile != null &&
                                  plan.level.index > profile.level.index)
                                'Este plano é de nível '
                                    '${plan.level.displayName} e seu perfil '
                                    'está como ${profile.level.displayName}.',
                              if (desiredFrequency != null &&
                                  plan.sessionsPerWeek > desiredFrequency)
                                'O plano tem ${plan.sessionsPerWeek} treinos '
                                    'por semana, acima da sua frequência '
                                    'desejada (${desiredFrequency}x).',
                            ];
                            if (warnings.isNotEmpty) {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  icon: const Icon(
                                    Icons.warning_amber_rounded,
                                  ),
                                  title: const Text(
                                    'Plano acima do seu perfil',
                                  ),
                                  content: Text(
                                    '${warnings.join('\n\n')}\n\n'
                                    'Deseja ativar mesmo assim?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(dialogContext)
                                              .pop(false),
                                      child: const Text('Cancelar'),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.of(dialogContext)
                                              .pop(true),
                                      child: const Text('Ativar mesmo assim'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed != true) return;
                            }
                            await ref
                                .read(activePlanProvider.notifier)
                                .activate(plan.id);
                            if (context.mounted) {
                              context.showSnackBar(
                                'Plano ativado! Veja seus treinos no Calendário.',
                              );
                              context.go(AppRoutes.calendar);
                            }
                          },
                    icon: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_circle_outline),
                    label: const Text('Ativar este plano'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends ConsumerWidget {
  final TrainingPlan plan;

  const _StatsRow({required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(distanceUnitProvider);
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.calendar_today,
            value: '${plan.durationWeeks}',
            label: 'semanas',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.fitness_center,
            value: '${plan.totalSessions}',
            label: 'treinos',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.straighten,
            value: unit.fromKm(plan.totalKm).toStringAsFixed(0),
            label: '${unit.label} totais',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: context.colorScheme.primary),
            const SizedBox(height: 6),
            Text(
              value,
              style: context.textTheme.titleLarge?.copyWith(
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

class _WeekRow extends ConsumerWidget {
  final TrainingPlan plan;
  final TrainingWeek week;

  const _WeekRow({required this.plan, required this.week});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(distanceUnitProvider);
    final scheme = context.colorScheme;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Text(
            '${week.number}',
            style: TextStyle(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          'Semana ${week.number}',
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${week.focus} • ${week.sessionsCount} treinos • ${unit.format(week.totalKm, decimals: 0)}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(
          '${AppRoutes.plans}/${plan.id}/week/${week.number}',
        ),
      ),
    );
  }
}
