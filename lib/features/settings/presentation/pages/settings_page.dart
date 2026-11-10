import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runner085/app/providers/theme_provider.dart';
import 'package:runner085/core/utils/constants.dart';
import 'package:runner085/core/utils/extensions.dart';
import 'package:runner085/features/settings/domain/distance_unit.dart';
import 'package:runner085/features/settings/presentation/providers/app_settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: SafeArea(
        child: settingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(
            child: Text('Erro ao carregar configurações'),
          ),
          data: (settings) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _SectionTitle('Aparência'),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto),
                      label: Text('Sistema'),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode),
                      label: Text('Claro'),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode),
                      label: Text('Escuro'),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (selection) => ref
                      .read(themeModeProvider.notifier)
                      .setThemeMode(selection.first),
                ),
              ),
              const SizedBox(height: 24),
              const _SectionTitle('Unidade de distância'),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<DistanceUnit>(
                  segments: [
                    for (final unit in DistanceUnit.values)
                      ButtonSegment<DistanceUnit>(
                        value: unit,
                        label: Text('${unit.displayName} (${unit.label})'),
                      ),
                  ],
                  selected: {settings.distanceUnit},
                  onSelectionChanged: (selection) => ref
                      .read(appSettingsProvider.notifier)
                      .setDistanceUnit(selection.first),
                ),
              ),
              const SizedBox(height: 24),
              const _SectionTitle('Frequência semanal desejada'),
              const SizedBox(height: 4),
              Text(
                'Usada para avisar quando um plano exige mais treinos por '
                'semana do que você pretende fazer.',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int?>(
                value: settings.weeklyFrequency,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.event_repeat),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    child: Text('Sem preferência'),
                  ),
                  for (var n = 2; n <= AppConstants.maxSessionsPerWeek; n++)
                    DropdownMenuItem<int?>(
                      value: n,
                      child: Text('$n treinos por semana'),
                    ),
                ],
                onChanged: (value) => ref
                    .read(appSettingsProvider.notifier)
                    .setWeeklyFrequency(value),
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  '${AppConstants.appName} v${AppConstants.appVersion}',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
