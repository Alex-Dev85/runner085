import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runner085/core/utils/extensions.dart';
import 'package:runner085/features/notifications/presentation/providers/notification_settings_provider.dart';

/// Tile de configuração de notificações para a ProfilePage.
/// Oculto automaticamente no web (não suportado).
class NotificationSettingsTile extends ConsumerWidget {
  const NotificationSettingsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Notificações locais não funcionam no web.
    if (kIsWeb) return const SizedBox.shrink();

    final settingsAsync = ref.watch(notificationSettingsProvider);

    return settingsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (settings) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Toggle principal ──────────────────────────────────────
              Row(
                children: [
                  const Icon(Icons.notifications_outlined),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lembrete de treino',
                          style: context.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          settings.enabled
                              ? 'Ativo às ${settings.timeLabel}'
                              : 'Desativado',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: settings.enabled,
                    onChanged: (value) => ref
                        .read(notificationSettingsProvider.notifier)
                        .setEnabled(value),
                  ),
                ],
              ),

              // ── Seletor de horário (visível só quando ativo) ──────────
              if (settings.enabled) ...[
                const Divider(height: 16),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _pickTime(context, ref, settings),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, size: 20),
                        const SizedBox(width: 16),
                        Text(
                          'Horário do lembrete',
                          style: context.textTheme.bodyMedium,
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: context.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            settings.timeLabel,
                            style: context.textTheme.titleSmall?.copyWith(
                              color: context.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: settings.hour, minute: settings.minute),
      helpText: 'Horário do lembrete',
    );
    if (picked == null) return;
    await ref
        .read(notificationSettingsProvider.notifier)
        .setTime(picked.hour, picked.minute);
  }
}
