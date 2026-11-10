import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runner085/core/utils/extensions.dart';
import 'package:runner085/features/plans/domain/enums/training_zone.dart';
import 'package:runner085/features/settings/domain/distance_unit.dart';
import 'package:runner085/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:runner085/features/training/domain/pace_zones.dart';
import 'package:runner085/features/training/presentation/providers/pace_zones_provider.dart';
import 'package:runner085/features/training/presentation/widgets/three_km_test_sheet.dart';

class TrainingPage extends ConsumerWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zones = ref.watch(paceZonesProvider).valueOrNull;
    final unit = ref.watch(distanceUnitProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Treino'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Zonas de Treinamento',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              zones == null
                  ? 'Conheça as faixas de intensidade e descubra o seu ritmo '
                      'em cada uma.'
                  : 'Ritmos personalizados com base no seu teste de 3 km.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _TestCard(zones: zones, unit: unit),
            const SizedBox(height: 12),
            const _InstructionsCard(),
            const SizedBox(height: 16),
            ...TrainingZone.values.map(
              (zone) => _ZoneCard(
                zone: zone,
                pace: zones?.rangeFor(zone).format(unit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card com o resultado do teste de 3 km ou o convite para fazê-lo.
class _TestCard extends ConsumerWidget {
  final PaceZones? zones;
  final DistanceUnit unit;

  const _TestCard({required this.zones, required this.unit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zones = this.zones;
    final scheme = context.colorScheme;

    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer_outlined, color: scheme.onPrimaryContainer),
                const SizedBox(width: 8),
                Text(
                  'Teste de 3 km',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (zones == null)
              Text(
                'Você ainda não registrou o teste. Corra 3 km no seu melhor '
                'ritmo sustentável e informe o tempo para calcular suas zonas.',
                style: TextStyle(color: scheme.onPrimaryContainer),
              )
            else ...[
              Text(
                'Tempo: ${PaceZones.formatDuration(zones.testSeconds)}  •  '
                'Ritmo: ${PaceZones.formatPace(zones.testPaceSecPerKm, unit)} '
                '/${unit.label}',
                style: context.textTheme.titleSmall?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Registrado em ${zones.testDate.formattedDate}. '
                'Refaça o teste a cada 4–6 semanas.',
                style: context.textTheme.bodySmall?.copyWith(
                  color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => showThreeKmTestSheet(context),
                    icon: Icon(zones == null ? Icons.add : Icons.edit),
                    label: Text(
                      zones == null ? 'Registrar teste' : 'Atualizar teste',
                    ),
                  ),
                ),
                if (zones != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Remover teste',
                    onPressed: () => _confirmClear(context, ref),
                    icon: Icon(
                      Icons.delete_outline,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover teste?'),
        content: const Text(
          'As zonas voltarão a mostrar apenas a frequência cardíaca.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (ok == true) await ref.read(paceZonesProvider.notifier).clear();
  }
}

/// Explica o que são as zonas e como descobrir as suas.
class _InstructionsCard extends StatelessWidget {
  const _InstructionsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(Icons.help_outline, color: context.colorScheme.primary),
        title: const Text('Como descobrir minhas zonas?'),
        subtitle: const Text('Entenda as zonas e como fazer o teste'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _InfoBlock(
            title: 'O que são as zonas',
            body: 'Cada zona é uma faixa de intensidade. O treino do dia diz '
                'em qual zona correr: Z1 e Z2 são leves (você conversa), '
                'Z3 é moderado, Z4 é o limiar (desconfortável, mas '
                'sustentável por 20–40 min) e Z5 é o esforço máximo, '
                'usado em tiros curtos.',
          ),
          _InfoBlock(
            title: 'Como fazer o teste de 3 km',
            body: '1. Escolha um percurso plano ou uma pista (7,5 voltas '
                'na pista de 400 m).\n'
                '2. Aqueça por 10–15 min com trote leve e algumas '
                'acelerações curtas.\n'
                '3. Corra os 3 km no ritmo mais forte que você consegue '
                'manter do início ao fim — sem largar rápido demais.\n'
                '4. Anote o tempo total no relógio ou app de corrida.\n'
                '5. Desaqueça com 10 min de trote leve.\n'
                '6. Toque em "Registrar teste" e informe o tempo.',
          ),
          _InfoBlock(
            title: 'Como as zonas são calculadas',
            body: 'O app divide o tempo por 3 para achar o seu ritmo médio '
                'do teste e aplica uma faixa percentual para cada zona: '
                'Z5 ≈ 95–102%, Z4 ≈ 102–108%, Z3 ≈ 108–118%, '
                'Z2 ≈ 118–130% e Z1 ≈ 130–145% do ritmo do teste '
                '(quanto maior, mais lento).',
          ),
          _InfoBlock(
            title: 'Usando frequência cardíaca',
            body: 'Se você treina com monitor cardíaco, use as faixas em % '
                'da FCmáx. Uma estimativa simples é FCmáx ≈ 220 − idade; '
                'o maior valor visto no fim do teste de 3 km costuma ser '
                'uma referência mais precisa.',
          ),
          _InfoBlock(
            title: 'Dicas',
            body: 'Faça o teste descansado, sem treino forte no dia '
                'anterior. Refaça a cada 4–6 semanas para acompanhar sua '
                'evolução. Em dias de calor ou subida, guie-se mais pela '
                'sensação de esforço do que pelo ritmo.',
            last: true,
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String title;
  final String body;
  final bool last;

  const _InfoBlock({
    required this.title,
    required this.body,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(body, style: context.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final TrainingZone zone;

  /// Faixa de ritmo personalizada; `null` se o teste não foi feito.
  final String? pace;

  const _ZoneCard({required this.zone, this.pace});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 8,
                decoration: BoxDecoration(
                  color: zone.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          zone.label,
                          style: context.textTheme.labelLarge?.copyWith(
                            color: zone.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            zone.displayName,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (pace != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.speed, size: 16, color: zone.color),
                          const SizedBox(width: 4),
                          Text(
                            pace!,
                            style: context.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      zone.hrRange,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      zone.description,
                      style: context.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
