import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:runner085/core/services/notification_service.dart';

// ── Chaves SharedPreferences ──────────────────────────────────────────────────

const _keyEnabled = 'notif_enabled';
const _keyHour = 'notif_hour';
const _keyMinute = 'notif_minute';

const _defaultHour = 7;
const _defaultMinute = 0;

// ── Estado ────────────────────────────────────────────────────────────────────

class NotificationSettings {
  final bool enabled;
  final int hour;
  final int minute;

  const NotificationSettings({
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  const NotificationSettings.defaults()
      : enabled = false,
        hour = _defaultHour,
        minute = _defaultMinute;

  NotificationSettings copyWith({
    bool? enabled,
    int? hour,
    int? minute,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  /// Horário formatado para exibição (ex.: "07:00").
  String get timeLabel =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class NotificationSettingsNotifier
    extends AsyncNotifier<NotificationSettings> {
  @override
  Future<NotificationSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationSettings(
      enabled: prefs.getBool(_keyEnabled) ?? false,
      hour: prefs.getInt(_keyHour) ?? _defaultHour,
      minute: prefs.getInt(_keyMinute) ?? _defaultMinute,
    );
  }

  /// Ativa ou desativa o lembrete diário.
  Future<void> setEnabled(bool enabled) async {
    final current = state.valueOrNull ?? const NotificationSettings.defaults();

    if (enabled) {
      // Pede permissão antes de ativar.
      final granted =
          await NotificationService.instance.requestPermission();
      if (!granted) return; // usuário negou — não altera o estado

      await NotificationService.instance.scheduleDailyReminder(
        hour: current.hour,
        minute: current.minute,
      );
    } else {
      await NotificationService.instance.cancelDailyReminder();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyEnabled, enabled);
    state = AsyncValue.data(current.copyWith(enabled: enabled));
  }

  /// Atualiza o horário do lembrete.
  Future<void> setTime(int hour, int minute) async {
    final current = state.valueOrNull ?? const NotificationSettings.defaults();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyHour, hour);
    await prefs.setInt(_keyMinute, minute);

    final updated = current.copyWith(hour: hour, minute: minute);
    state = AsyncValue.data(updated);

    // Reagenda se estiver ativo.
    if (updated.enabled) {
      await NotificationService.instance.scheduleDailyReminder(
        hour: hour,
        minute: minute,
      );
    }
  }

  /// Força reagendamento com body personalizado (ex.: nome do treino de hoje).
  Future<void> rescheduleWithBody(String body) async {
    final current = state.valueOrNull;
    if (current == null || !current.enabled) return;
    await NotificationService.instance.scheduleDailyReminder(
      hour: current.hour,
      minute: current.minute,
      body: body,
    );
  }
}

final notificationSettingsProvider =
    AsyncNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  NotificationSettingsNotifier.new,
);
