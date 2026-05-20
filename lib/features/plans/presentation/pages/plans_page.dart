import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runner085/app/router/app_routes.dart';
import 'package:runner085/core/utils/extensions.dart';
import 'package:runner085/core/widgets/app_error_widget.dart';
import 'package:runner085/core/widgets/app_loading.dart';
import 'package:runner085/features/plans/domain/entities/training_plan.dart';
import 'package:runner085/features/plans/domain/enums/race_distance.dart';
import 'package:runner085/features/plans/presentation/providers/plans_provider.dart';
import 'package:runner085/features/plans/presentation/widgets/plan_card.dart';

class PlansPage extends ConsumerWidget {
  const PlansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAsync = ref.watch(filteredPlansProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planos de Treino'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                'Escolha seu desafio',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const _DistanceFilters(),
            const SizedBox(height: 8),
            const _LevelFilters(),
            const SizedBox(height: 8),
            Expanded(
              child: filteredAsync.when(
                data: (plans) {
                  if (plans.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Nenhum plano para esses filtros.',
                          style: context.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return _PlansList(plans: plans);
                },
                loading: () => const AppLoading(),
                error: (e, _) => AppErrorWidget(
                  message: 'Erro ao carregar planos: $e',
                  onRetry: () => ref.invalidate(plansProvider),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DistanceFilters extends ConsumerWidget {
  const _DistanceFilters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedDistanceFilterProvider);
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _Chip(
            label: 'Todas',
            isSelected: selected == null,
            onTap: () =>
                ref.read(selectedDistanceFilterProvider.notifier).state = null,
          ),
          for (final d in RaceDistance.values)
            _Chip(
              label: d.displayName,
              isSelected: selected == d,
              onTap: () =>
                  ref.read(selectedDistanceFilterProvider.notifier).state = d,
            ),
        ],
      ),
    );
  }
}

class _LevelFilters extends ConsumerWidget {
  const _LevelFilters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedLevelFilterProvider);
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _Chip(
            label: 'Todos os níveis',
            isSelected: selected == null,
            onTap: () =>
                ref.read(selectedLevelFilterProvider.notifier).state = null,
          ),
          for (final l in RunnerLevel.values)
            _Chip(
              label: l.displayName,
              isSelected: selected == l,
              onTap: () =>
                  ref.read(selectedLevelFilterProvider.notifier).state = l,
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _PlansList extends StatelessWidget {
  final List<TrainingPlan> plans;

  const _PlansList({required this.plans});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: plans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final plan = plans[index];
        return PlanCard(
          plan: plan,
          onTap: () => context.push('${AppRoutes.plans}/${plan.id}'),
        );
      },
    );
  }
}
