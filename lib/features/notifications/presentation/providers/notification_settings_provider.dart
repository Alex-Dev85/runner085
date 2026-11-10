import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runner085/core/data/user_data/user_data_store.dart';
import 'package:runner085/core/providers/user_data_providers.dart';
import 'package:runner085/core/services/notification_service.dart';
import 'package:runner085/features/auth/presentation/providers/auth_provider.dart';

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

  factory NotificationSettings.fromJson(Map<String, dynamic>? json) =>
      NotificationSettings(
        enabled: json?['enabled'] as bool? ?? false,
        hour: (json?['hour'] as num?)?.toInt() ?? _defaultHour,
        minute: (json?['minute'] as num?)?.toInt() ?? _defaultMinute,
      );

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'hour': hour,
        'minute': minute,
      };

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

/// Lembrete diário do usuário, no documento `reminder`:
/// `{ enabled: bool, hour: int, minute: int }`.
///
/// O alarme fica no aparelho, mas a preferência é da conta: ao trocar de
/// conta o lembrete é reagendado com o horário dela (ou cancelado, se ela
/// não usa), e ao sair ele é cancelado — o lembrete de uma conta não
/// continua disparando para a próxima.
class NotificationSettingsNotifier
    extends AsyncNotifier<NotificationSettings> {
  static const doc = 'reminder';

  UserDataStore get _store => ref.read(userDataStoreProvider);

  @override
  Future<NotificationSettings> build() async {
    // watch: recarrega e reagenda ao trocar de conta.
    final store = ref.watch(userDataStoreProvider);
    // Se a leitura falhar (ex.: offline e nunca sincronizado), o erro vai
    // para o estado e o alarme atual do aparelho fica como está.
    final settings = NotificationSettings.fromJson(await store.read(doc));

    // Enquanto o login ainda está sendo verificado (abertura do app) não se
    // sabe de quem é o lembrete: não mexe no alarme. Sem isso, "carregando"
    // era tratado como "deslogado" e o alarme era cancelado. Quando o login
    // resolve, o uid muda e este build roda de novo.
    final auth = ref.read(authStateProvider);
    final authResolving = auth.isLoading && !auth.hasValue;
    if (!authResolving) unawaited(_syncDeviceAlarm(settings));
    return settings;
  }

  /// Deixa o alarme do aparelho igual à preferência da conta atual.
  Future<void> _syncDeviceAlarm(
    NotificationSettings settings, {
    String? body,
  }) async {
    final service = NotificationService.instance;
    if (!settings.enabled) {
      await service.cancelDailyReminder();
      return;
    }
    if (body == null) {
      await service.scheduleDailyReminder(
        hour: settings.hour,
        minute: settings.minute,
      );
    } else {
      await service.scheduleDailyReminder(
        hour: settings.hour,
        minute: settings.minute,
        body: body,
      );
    }
  }

  /// Ativa ou desativa o lembrete diário.
  Future<void> setEnabled(bool enabled) async {
    final current = state.valueOrNull ?? const NotificationSettings.defaults();

    if (enabled) {
      // Pede permissão antes de ativar.
      final granted = await NotificationService.instance.requestPermission();
      if (!granted) return; // usuário negou — não altera o estado
    }

    final updated = current.copyWith(enabled: enabled);
    state = AsyncValue.data(updated);
    await _syncDeviceAlarm(updated);
    await _store.write(doc, updated.toJson());
  }

  /// Atualiza o horário do lembrete.
  Future<void> setTime(int hour, int minute) async {
    final current = state.valueOrNull ?? const NotificationSettings.defaults();
    final updated = current.copyWith(hour: hour, minute: minute);
    state = AsyncValue.data(updated);
    await _syncDeviceAlarm(updated);
    await _store.write(doc, updated.toJson());
  }

  /// Força reagendamento com body personalizado (ex.: nome do treino de hoje).
  Future<void> rescheduleWithBody(String body) async {
    final current = state.valueOrNull;
    if (current == null || !current.enabled) return;
    await _syncDeviceAlarm(current, body: body);
  }
}

final notificationSettingsProvider =
    AsyncNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  NotificationSettingsNotifier.new,
);
