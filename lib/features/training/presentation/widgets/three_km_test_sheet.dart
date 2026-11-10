import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runner085/core/utils/extensions.dart';
import 'package:runner085/features/plans/domain/enums/training_zone.dart';
import 'package:runner085/features/settings/presentation/providers/app_settings_provider.dart';
import 'package:runner085/features/training/domain/pace_zones.dart';
import 'package:runner085/features/training/presentation/providers/pace_zones_provider.dart';

/// Abre a ferramenta do teste de 3 km como bottom sheet.
Future<void> showThreeKmTestSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => const ThreeKmTestSheet(),
  );
}

class ThreeKmTestSheet extends ConsumerStatefulWidget {
  const ThreeKmTestSheet({super.key});

  @override
  ConsumerState<ThreeKmTestSheet> createState() => _ThreeKmTestSheetState();
}

class _ThreeKmTestSheetState extends ConsumerState<ThreeKmTestSheet> {
  final _minutesCtrl = TextEditingController();
  final _secondsCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final current = ref.read(paceZonesProvider).valueOrNull;
    if (current != null) {
      _minutesCtrl.text = '${current.testSeconds ~/ 60}';
      _secondsCtrl.text =
          (current.testSeconds % 60).toString().padLeft(2, '0');
    }
  }

  @override
  void dispose() {
    _minutesCtrl.dispose();
    _secondsCtrl.dispose();
    super.dispose();
  }

  int? get _totalSeconds {
    final m = int.tryParse(_minutesCtrl.text);
    final s = int.tryParse(_secondsCtrl.text.isEmpty ? '0' : _secondsCtrl.text);
    if (m == null || s == null || s > 59) return null;
    return m * 60 + s;
  }

  String? get _error {
    if (_minutesCtrl.text.isEmpty) return null;
    final total = _totalSeconds;
    if (total == null) return 'Segundos devem ficar entre 00 e 59.';
    if (!PaceZones.isValidTestSeconds(total)) {
      return 'Informe um tempo entre 7:00 e 40:00.';
    }
    return null;
  }

  Future<void> _save() async {
    final total = _totalSeconds;
    if (total == null || !PaceZones.isValidTestSeconds(total)) return;
    setState(() => _saving = true);
    await ref.read(paceZonesProvider.notifier).saveTest(total);
    if (!mounted) return;
    Navigator.of(context).pop();
    context.showSnackBar('Zonas atualizadas com o seu teste de 3 km!');
  }

  @override
  Widget build(BuildContext context) {
    final unit = ref.watch(distanceUnitProvider);
    final total = _totalSeconds;
    final error = _error;
    final preview = (total != null && error == null && _minutesCtrl.text.isNotEmpty)
        ? PaceZones(testSeconds: total, testDate: DateTime.now())
        : null;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Teste de 3 km',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Digite o tempo total que você levou para correr os 3 km.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('test_minutes'),
                    controller: _minutesCtrl,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      labelText: 'Minutos',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Text(':', style: context.textTheme.headlineSmall),
                ),
                Expanded(
                  child: TextField(
                    key: const Key('test_seconds'),
                    controller: _secondsCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      labelText: 'Segundos',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _save(),
                  ),
                ),
              ],
            ),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(
                error,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.error,
                ),
              ),
            ],
            if (preview != null) ...[
              const SizedBox(height: 16),
              Text(
                'Ritmo médio do teste: '
                '${PaceZones.formatPace(preview.testPaceSecPerKm, unit)} /${unit.label}',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              for (final zone in TrainingZone.values)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: zone.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 28,
                        child: Text(
                          zone.label,
                          style: context.textTheme.labelLarge?.copyWith(
                            color: zone.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(child: Text(zone.displayName)),
                      Text(
                        preview.rangeFor(zone).format(unit),
                        style: const TextStyle(
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: preview == null || _saving ? null : _save,
              icon: const Icon(Icons.check),
              label: const Text('Salvar e atualizar zonas'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
