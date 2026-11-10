import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runner085/app/providers/theme_provider.dart';
import 'package:runner085/app/router/app_routes.dart';
import 'package:runner085/app/theme/app_colors.dart';
import 'package:runner085/core/utils/constants.dart';
import 'package:runner085/core/utils/extensions.dart';
import 'package:runner085/features/auth/presentation/providers/auth_provider.dart';
import 'package:runner085/features/notifications/presentation/widgets/notification_settings_tile.dart';
import 'package:runner085/features/plans/domain/enums/race_distance.dart';
import 'package:runner085/features/plans/presentation/providers/active_plan_provider.dart';
import 'package:runner085/features/plans/presentation/widgets/recommendation_section.dart';
import 'package:runner085/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:runner085/features/progress/presentation/providers/workout_progress_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 48,
                backgroundColor: context.colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  size: 48,
                  color: context.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?.displayName ?? 'Corredor',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),

              // ── Perfil de corredor ──────────────────────────────────────
              profileAsync.when(
                loading: () => const CircularProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
                data: (profile) => _RunnerProfileCard(
                  profile: profile,
                  onEdit: () => _showProfileSetup(context, ref, profile),
                ),
              ),

              const SizedBox(height: 12),

              // ── Estatísticas de progresso ───────────────────────────────
              _StatsCard(ref: ref),

              const SizedBox(height: 16),
              const Divider(),

              // ── Notificações ────────────────────────────────────────────
              const NotificationSettingsTile(),
              const SizedBox(height: 8),

              _buildMenuItem(
                context,
                icon: Icons.history,
                title: 'Histórico de treinos',
                onTap: () => context.push(AppRoutes.history),
              ),
              _buildMenuItem(
                context,
                icon: Icons.settings,
                title: 'Configurações',
                onTap: () => context.push(AppRoutes.settings),
              ),
              _buildMenuItem(
                context,
                icon: Icons.help_outline,
                title: 'Ajuda',
                onTap: () {},
              ),
              _buildMenuItem(
                context,
                icon: Icons.info_outline,
                title: 'Sobre',
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: AppConstants.appName,
                  applicationVersion: AppConstants.appVersion,
                  applicationIcon: Icon(
                    Icons.directions_run,
                    size: 40,
                    color: context.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authNotifierProvider.notifier).signOut();
                    if (context.mounted) {
                      context.go(AppRoutes.login);
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sair'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
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
      useRootNavigator: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: _ProfileSetupSheetProxy(currentProfile: profile),
      ),
    );
  }
}

// ── Card do perfil de corredor ────────────────────────────────────────────────

class _RunnerProfileCard extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onEdit;

  const _RunnerProfileCard({required this.profile, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Perfil de corredor',
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Editar'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ProfileStat(
                    icon: Icons.speed,
                    label: 'Nível',
                    value: profile.level.displayName,
                  ),
                ),
                Expanded(
                  child: _ProfileStat(
                    icon: Icons.flag_outlined,
                    label: 'Objetivo',
                    value: profile.goalDistance?.displayName ?? 'Não definido',
                  ),
                ),
              ],
            ),
            if (!profile.isComplete) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: context.colorScheme.onTertiaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Defina seu objetivo para receber recomendações de planos.',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onTertiaryContainer,
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
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: context.colorScheme.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Card de estatísticas ──────────────────────────────────────────────────────

class _StatsCard extends ConsumerWidget {
  final WidgetRef ref;

  const _StatsCard({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final progressAsync = widgetRef.watch(workoutProgressProvider);
    final activePlanAsync = widgetRef.watch(activePlanProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estatísticas',
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            progressAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Erro ao carregar'),
              data: (progress) {
                final activePlan = activePlanAsync.valueOrNull;
                final total = activePlan?.plan.totalSessions ?? 0;
                final percent = progress.completionPercent(total);

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatItem(
                            icon: Icons.check_circle_outline,
                            color: AppColors.success,
                            value: '${progress.completedIds.length}',
                            label: 'Treinos\nconcluídos',
                          ),
                        ),
                        Expanded(
                          child: _StatItem(
                            icon: Icons.local_fire_department,
                            color: AppColors.secondary,
                            value: '${progress.streakDays}',
                            label: 'Dias\nconsecutivos',
                          ),
                        ),
                        Expanded(
                          child: _StatItem(
                            icon: Icons.timer_outlined,
                            color: context.colorScheme.primary,
                            value: progress.totalMinutes >= 60
                                ? '${(progress.totalMinutes / 60).toStringAsFixed(1)}h'
                                : '${progress.totalMinutes}min',
                            label: 'Tempo\ntreinado',
                          ),
                        ),
                      ],
                    ),
                    if (activePlan != null && total > 0) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progresso do plano',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            '${progress.completedIds.length}/$total  •  ${percent.toStringAsFixed(0)}%',
                            style: context.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
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
                          backgroundColor:
                              context.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            percent >= 100
                                ? AppColors.success
                                : context.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Proxy para o bottom sheet ─────────────────────────────────────────────────

class _ProfileSetupSheetProxy extends ConsumerWidget {
  final UserProfile currentProfile;

  const _ProfileSetupSheetProxy({required this.currentProfile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Reutiliza o mesmo sheet da RecommendationSection via RecommendationSection
    // Aqui instanciamos diretamente para evitar dependência circular.
    return _InlineProfileSheet(currentProfile: currentProfile);
  }
}

class _InlineProfileSheet extends ConsumerStatefulWidget {
  final UserProfile currentProfile;

  const _InlineProfileSheet({required this.currentProfile});

  @override
  ConsumerState<_InlineProfileSheet> createState() =>
      _InlineProfileSheetState();
}

class _InlineProfileSheetState extends ConsumerState<_InlineProfileSheet> {
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
              return ChoiceChip(
                label: Text(level.displayName),
                selected: _selectedLevel == level,
                onSelected: (_) => setState(() => _selectedLevel = level),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
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
              return ChoiceChip(
                label: Text(dist.displayName),
                selected: _selectedDistance == dist,
                onSelected: (_) => setState(() => _selectedDistance = dist),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
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
