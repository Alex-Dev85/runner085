import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runner085/app/router/app_routes.dart';
import 'package:runner085/app/theme/app_colors.dart';
import 'package:runner085/core/utils/extensions.dart';
import 'package:runner085/features/plans/domain/enums/race_distance.dart';
import 'package:runner085/features/plans/domain/services/recommendation_engine.dart';
import 'package:runner085/features/plans/presentation/providers/recommendation_provider.dart';
import 'package:runner085/features/profile/presentation/providers/user_profile_provider.dart';

/// Seção de recomendação automática de planos.
/// Pode ser embutida na HomePage ou na PlansPage.
class RecommendationSection extends ConsumerWidget {
  /// Se true, mostra apenas o plano principal (para a HomePage).
  final bool compact;

  const RecommendationSection({super.key, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final recommendationsAsync = ref.watch(recommendedPlansProvider);

    return profileAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (profile) {
        // Perfil incompleto: convida o usuário a configurar.
        if (!profile.isComplete) {
          return _SetupProfileCard(
            onTap: () => _showProfileSetup(context, ref, profile),
          );
        }

        return recommendationsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (recs) {
            if (recs.isEmpty) return const SizedBox.shrink();
            final toShow = compact ? recs.take(1).toList() : recs;
            return _RecommendationList(
              recommendations: toShow,
              profile: profile,
              compact: compact,
              onEditProfile: () => _showProfileSetup(context, ref, profile),
            );
          },
        );
      },
    );
  }

  Future<void> _showProfileSetup(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: _ProfileSetupSheet(currentProfile: profile),
      ),
    );
  }
}

// ── Card: perfil incompleto ───────────────────────────────────────────────────

class _SetupProfileCard extends StatelessWidget {
  final VoidCallback onTap;

  const _SetupProfileCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.colorScheme.secondaryContainer,
      child: ListTile(
        leading: Icon(
          Icons.tune,
          color: context.colorScheme.onSecondaryContainer,
        ),
        title: Text(
          'Configure seu perfil',
          style: TextStyle(
            color: context.colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Informe seu nível e objetivo para receber recomendações.',
          style: TextStyle(
            color: context.colorScheme.onSecondaryContainer.withValues(
              alpha: 0.8,
            ),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: context.colorScheme.onSecondaryContainer,
        ),
        onTap: onTap,
      ),
    );
  }
}

// ── Lista de recomendações ────────────────────────────────────────────────────

class _RecommendationList extends StatelessWidget {
  final List<PlanRecommendation> recommendations;
  final UserProfile profile;
  final bool compact;
  final VoidCallback onEditProfile;

  const _RecommendationList({
    required this.recommendations,
    required this.profile,
    required this.compact,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    compact ? 'Recomendado para você' : 'Recomendações',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${profile.level.displayName}  •  ${profile.goalDistance?.displayName ?? ''}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: onEditProfile,
              icon: const Icon(Icons.tune, size: 16),
              label: const Text('Editar'),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Cards
        ...recommendations.map(
          (rec) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _RecommendationCard(recommendation: rec),
          ),
        ),
      ],
    );
  }
}

// ── Card individual ───────────────────────────────────────────────────────────

class _RecommendationCard extends StatelessWidget {
  final PlanRecommendation recommendation;

  const _RecommendationCard({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    final plan = recommendation.plan;
    final isPrimary = recommendation.isPrimary;

    return Card(
      color: isPrimary ? context.colorScheme.primaryContainer : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('${AppRoutes.plans}/${plan.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Ícone / badge de score
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isPrimary
                      ? context.colorScheme.primary
                      : context.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: isPrimary
                      ? Icon(
                          Icons.star_rounded,
                          color: context.colorScheme.onPrimary,
                        )
                      : Text(
                          plan.distance.displayName,
                          style: context.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            plan.name,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isPrimary
                                  ? context.colorScheme.onPrimaryContainer
                                  : null,
                            ),
                          ),
                        ),
                        if (isPrimary)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Ideal',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      recommendation.reason,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: isPrimary
                            ? context.colorScheme.onPrimaryContainer
                                .withValues(alpha: 0.8)
                            : context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _Tag(
                          label: plan.distance.displayName,
                          isPrimary: isPrimary,
                        ),
                        const SizedBox(width: 6),
                        _Tag(
                          label: plan.level.displayName,
                          isPrimary: isPrimary,
                        ),
                        const SizedBox(width: 6),
                        _Tag(
                          label: '${plan.durationWeeks} sem.',
                          isPrimary: isPrimary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isPrimary
                    ? context.colorScheme.onPrimaryContainer
                    : context.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final bool isPrimary;

  const _Tag({required this.label, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isPrimary
            ? context.colorScheme.primary.withValues(alpha: 0.15)
            : context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: context.textTheme.labelSmall?.copyWith(
          color: isPrimary
              ? context.colorScheme.onPrimaryContainer
              : context.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ── Bottom sheet: configurar perfil ──────────────────────────────────────────

class _ProfileSetupSheet extends ConsumerStatefulWidget {
  final UserProfile currentProfile;

  const _ProfileSetupSheet({required this.currentProfile});

  @override
  ConsumerState<_ProfileSetupSheet> createState() => _ProfileSetupSheetState();
}

class _ProfileSetupSheetState extends ConsumerState<_ProfileSetupSheet> {
  late RunnerLevel _selectedLevel;
  late RaceDistance? _selectedDistance;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.currentProfile.level;
    _selectedDistance = widget.currentProfile.goalDistance;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Seu perfil de corredor',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Usamos isso para recomendar o plano certo para você.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Nível
          Text(
            'Qual é o seu nível?',
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: RunnerLevel.values.map((level) {
              final selected = _selectedLevel == level;
              return ChoiceChip(
                label: Text(level.displayName),
                selected: selected,
                onSelected: (_) => setState(() => _selectedLevel = level),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Objetivo
          Text(
            'Qual é o seu objetivo?',
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: RaceDistance.values.map((dist) {
              final selected = _selectedDistance == dist;
              return ChoiceChip(
                label: Text(dist.displayName),
                selected: selected,
                onSelected: (_) =>
                    setState(() => _selectedDistance = dist),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Botão salvar
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _selectedDistance == null || _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Salvar perfil'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_selectedDistance == null) return;
    setState(() => _saving = true);
    await ref.read(userProfileProvider.notifier).updateProfile(
          level: _selectedLevel,
          goalDistance: _selectedDistance!,
        );
    if (mounted) Navigator.pop(context);
  }
}
