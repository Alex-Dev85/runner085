import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// IDs fixos para cada tipo de notificação.
class NotificationIds {
  static const int dailyReminder = 1;
  static const int workoutToday = 2;
}

/// Serviço central de notificações locais.
/// Responsável por inicializar o plugin, pedir permissão e agendar lembretes.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // ── Inicialização ─────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;

    // Inicializa fusos horários (necessário para notificações agendadas).
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    // Navegação ao tocar na notificação pode ser adicionada aqui
    // via GlobalKey<NavigatorState> ou GoRouter quando necessário.
  }

  // ── Permissões ────────────────────────────────────────────────────────────

  /// Solicita permissão de notificação ao usuário.
  /// Retorna true se concedida.
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;

    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  /// Verifica se a permissão já foi concedida (Android 13+).
  Future<bool> hasPermission() async {
    if (kIsWeb) return false;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.areNotificationsEnabled();
      return granted ?? false;
    }
    return true; // iOS: assume concedido se não conseguir verificar
  }

  // ── Agendamento ───────────────────────────────────────────────────────────

  /// Agenda um lembrete diário no horário especificado.
  /// Cancela qualquer lembrete anterior antes de agendar o novo.
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    String title = 'Hora de treinar! 🏃',
    String body = 'Seu treino de hoje está esperando por você.',
  }) async {
    if (kIsWeb) return;
    await cancelDailyReminder();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Se o horário já passou hoje, agenda para amanhã.
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Lembrete de treino',
      channelDescription: 'Lembrete diário para não perder o treino.',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      NotificationIds.dailyReminder,
      title,
      body,
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // repete diariamente
    );
  }

  /// Envia uma notificação imediata informando o treino do dia.
  Future<void> showTodayWorkoutNotification({
    required String workoutTitle,
    required int durationMinutes,
  }) async {
    if (kIsWeb) return;

    const androidDetails = AndroidNotificationDetails(
      'workout_today',
      'Treino de hoje',
      channelDescription: 'Informações sobre o treino do dia.',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      NotificationIds.workoutToday,
      'Treino de hoje: $workoutTitle',
      '$durationMinutes minutos — Você consegue! 💪',
      details,
    );
  }

  // ── Cancelamento ──────────────────────────────────────────────────────────

  Future<void> cancelDailyReminder() async {
    if (kIsWeb) return;
    await _plugin.cancel(NotificationIds.dailyReminder);
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }
}
