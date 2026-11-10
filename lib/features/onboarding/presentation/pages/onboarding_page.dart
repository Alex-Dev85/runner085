import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runner085/app/router/app_routes.dart';
import 'package:runner085/app/theme/app_colors.dart';
import 'package:runner085/core/providers/core_providers.dart';
import 'package:runner085/core/utils/extensions.dart';
import 'package:runner085/features/onboarding/data/onboarding_repository.dart';
import 'package:runner085/features/plans/domain/enums/race_distance.dart';
import 'package:runner085/features/profile/presentation/providers/user_profile_provider.dart';

// ── Constantes de layout ──────────────────────────────────────────────────────

const _kTotalPages = 4; // boas-vindas | nível | objetivo | pronto

// ── Page ─────────────────────────────────────────────────────────────────────

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Seleções do usuário
  RunnerLevel _selectedLevel = RunnerLevel.beginner;
  RaceDistance _selectedDistance = RaceDistance.fiveKm;
  bool _saving = false;

  // ── Navegação ───────────────────────────────────────────────────────────────

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    await ref.read(userProfileProvider.notifier).updateProfile(
          level: _selectedLevel,
          goalDistance: _selectedDistance,
        );
    await _markCompleted();
    if (mounted) context.go(AppRoutes.home);
  }

  /// Marca o onboarding como concluído para o usuário autenticado.
  Future<void> _markCompleted() async {
    final user = await ref.read(authRepositoryProvider).currentUser;
    await OnboardingRepository().markCompleted(userId: user?.id);
  }

  Future<void> _skip() async {
    // Salva perfil padrão para que a recomendação funcione.
    await ref.read(userProfileProvider.notifier).updateProfile(
          level: RunnerLevel.beginner,
          goalDistance: RaceDistance.fiveKm,
        );
    await _markCompleted();
    if (mounted) context.go(AppRoutes.home);
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _kTotalPages - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Barra de progresso + botão pular ──────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_currentPage + 1) / _kTotalPages,
                        minHeight: 4,
                        backgroundColor:
                            context.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  if (!isLastPage) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: _skip,
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('Pular'),
                    ),
                  ],
                ],
              ),
            ),

            // ── Conteúdo das páginas ───────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _WelcomePage(onNext: () => _goToPage(1)),
                  _LevelPage(
                    selected: _selectedLevel,
                    onChanged: (l) => setState(() => _selectedLevel = l),
                    onNext: () => _goToPage(2),
                    onBack: () => _goToPage(0),
                  ),
                  _GoalPage(
                    selected: _selectedDistance,
                    onChanged: (d) => setState(() => _selectedDistance = d),
                    onNext: () => _goToPage(3),
                    onBack: () => _goToPage(1),
                  ),
                  _ReadyPage(
                    level: _selectedLevel,
                    distance: _selectedDistance,
                    saving: _saving,
                    onFinish: _finish,
                    onBack: () => _goToPage(2),
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

/// Ocupa a altura toda quando há espaço (os `Spacer`s distribuem o
/// conteúdo) e vira rolagem quando a tela é baixa ou o teclado está aberto,
/// em vez de estourar o layout.
class _FillOrScroll extends StatelessWidget {
  final EdgeInsets padding;
  final Widget child;

  const _FillOrScroll({required this.padding, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: math.max(0, constraints.maxHeight - padding.vertical),
          ),
          child: IntrinsicHeight(child: child),
        ),
      ),
    );
  }
}

// ── Página 1: Boas-vindas ─────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  final VoidCallback onNext;

  const _WelcomePage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return _FillOrScroll(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: context.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_run,
              size: 64,
              color: context.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Bem-vindo ao\nRunner085',
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Vamos personalizar sua experiência em menos de 1 minuto.',
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          _FeatureRow(
            icon: Icons.tune,
            color: AppColors.primary,
            text: 'Planos adaptados ao seu nível',
          ),
          const SizedBox(height: 12),
          _FeatureRow(
            icon: Icons.flag_outlined,
            color: AppColors.secondary,
            text: 'Do 5km à maratona',
          ),
          const SizedBox(height: 12),
          _FeatureRow(
            icon: Icons.trending_up,
            color: AppColors.success,
            text: 'Acompanhe seu progresso',
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onNext,
              child: const Text('Vamos começar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _FeatureRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Página 2: Nível ───────────────────────────────────────────────────────────

class _LevelPage extends StatelessWidget {
  final RunnerLevel selected;
  final ValueChanged<RunnerLevel> onChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _LevelPage({
    required this.selected,
    required this.onChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Qual é o seu nível?',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Isso nos ajuda a recomendar o plano certo para você.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: RunnerLevel.values
                  .map(
                    (level) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _LevelCard(
                        level: level,
                        isSelected: selected == level,
                        onTap: () => onChanged(level),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          _NavButtons(
            onBack: onBack,
            onNext: onNext,
            nextLabel: 'Próximo',
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final RunnerLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  const _LevelCard({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  static const _descriptions = {
    RunnerLevel.beginner:
        'Estou começando a correr ou corro menos de 5 km por semana.',
    RunnerLevel.intermediate:
        'Corro regularmente e já completei provas de 5–10 km.',
    RunnerLevel.advanced:
        'Treino consistentemente e já corri meias maratonas ou mais.',
    RunnerLevel.elite:
        'Atleta competitivo com alto volume de treino semanal.',
  };

  static const _icons = {
    RunnerLevel.beginner: Icons.eco_outlined,
    RunnerLevel.intermediate: Icons.trending_up,
    RunnerLevel.advanced: Icons.local_fire_department_outlined,
    RunnerLevel.elite: Icons.military_tech_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final color =
        isSelected ? context.colorScheme.primary : context.colorScheme.outline;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? context.colorScheme.primaryContainer
            : context.colorScheme.surface,
        border: Border.all(color: color, width: isSelected ? 2 : 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colorScheme.primary
                      : context.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _icons[level],
                  color: isSelected
                      ? context.colorScheme.onPrimary
                      : context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.displayName,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? context.colorScheme.onPrimaryContainer
                            : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _descriptions[level]!,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? context.colorScheme.onPrimaryContainer
                                .withValues(alpha: 0.8)
                            : context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: context.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Página 3: Objetivo ────────────────────────────────────────────────────────

class _GoalPage extends StatelessWidget {
  final RaceDistance selected;
  final ValueChanged<RaceDistance> onChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _GoalPage({
    required this.selected,
    required this.onChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Qual é o seu objetivo?',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha a distância que você quer conquistar.',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: RaceDistance.values
                  .map(
                    (d) => _DistanceCard(
                      distance: d,
                      isSelected: selected == d,
                      onTap: () => onChanged(d),
                    ),
                  )
                  .toList(),
            ),
          ),
          _NavButtons(
            onBack: onBack,
            onNext: onNext,
            nextLabel: 'Próximo',
          ),
        ],
      ),
    );
  }
}

class _DistanceCard extends StatelessWidget {
  final RaceDistance distance;
  final bool isSelected;
  final VoidCallback onTap;

  const _DistanceCard({
    required this.distance,
    required this.isSelected,
    required this.onTap,
  });

  static const _subtitles = {
    RaceDistance.fiveKm: 'Ótimo ponto de partida',
    RaceDistance.tenKm: 'O clássico desafio',
    RaceDistance.halfMarathon: '21 km de superação',
    RaceDistance.marathon: 'O sonho dos corredores',
  };

  static const _icons = {
    RaceDistance.fiveKm: Icons.directions_run,
    RaceDistance.tenKm: Icons.speed,
    RaceDistance.halfMarathon: Icons.emoji_events_outlined,
    RaceDistance.marathon: Icons.military_tech_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? context.colorScheme.primaryContainer
            : context.colorScheme.surface,
        border: Border.all(
          color: isSelected
              ? context.colorScheme.primary
              : context.colorScheme.outline,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _icons[distance],
                size: 32,
                color: isSelected
                    ? context.colorScheme.primary
                    : context.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                distance.displayName,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? context.colorScheme.onPrimaryContainer
                      : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _subtitles[distance]!,
                style: context.textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? context.colorScheme.onPrimaryContainer
                          .withValues(alpha: 0.75)
                      : context.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Página 4: Pronto ──────────────────────────────────────────────────────────

class _ReadyPage extends StatelessWidget {
  final RunnerLevel level;
  final RaceDistance distance;
  final bool saving;
  final VoidCallback onFinish;
  final VoidCallback onBack;

  const _ReadyPage({
    required this.level,
    required this.distance,
    required this.saving,
    required this.onFinish,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return _FillOrScroll(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Tudo pronto!',
            style: context.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Seu perfil foi configurado. Vamos encontrar o plano ideal para você.',
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Resumo do perfil
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    icon: Icons.speed,
                    label: 'Nível',
                    value: level.displayName,
                  ),
                ),
                Container(
                  width: 1,
                  height: 48,
                  color: context.colorScheme.outlineVariant,
                ),
                Expanded(
                  child: _SummaryItem(
                    icon: Icons.flag_outlined,
                    label: 'Objetivo',
                    value: distance.displayName,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: saving ? null : onFinish,
              child: saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Ir para o app'),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: saving ? null : onBack,
            child: const Text('Voltar e editar'),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: context.colorScheme.primary),
        const SizedBox(height: 6),
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ── Botões de navegação reutilizáveis ─────────────────────────────────────────

class _NavButtons extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  final String nextLabel;

  const _NavButtons({
    required this.onBack,
    required this.onNext,
    required this.nextLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        OutlinedButton(
          onPressed: onBack,
          child: const Text('Voltar'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: onNext,
            child: Text(nextLabel),
          ),
        ),
      ],
    );
  }
}
