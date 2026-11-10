import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runner085/app/providers/theme_provider.dart';
import 'package:runner085/app/router/app_router.dart';
import 'package:runner085/app/theme/app_theme.dart';
import 'package:runner085/core/services/notification_service.dart';
import 'package:runner085/features/notifications/presentation/providers/notification_settings_provider.dart';
import 'package:runner085/features/plans/presentation/providers/active_plan_provider.dart';

class RunnerApp extends ConsumerWidget {
  const RunnerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Runner085',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) => _AppLifecycleObserver(child: child!),
    );
  }
}

/// Observa o ciclo de vida do app para reagendar notificações
/// quando o app volta ao foreground.
class _AppLifecycleObserver extends ConsumerStatefulWidget {
  final Widget child;

  const _AppLifecycleObserver({required this.child});

  @override
  ConsumerState<_AppLifecycleObserver> createState() =>
      _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends ConsumerState<_AppLifecycleObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Reagenda ao abrir o app: corrige lembretes agendados antes com fuso
    // errado e mantém o texto do treino do dia atualizado.
    if (!kIsWeb) {
      ref.read(notificationSettingsProvider.future).then((settings) {
        if (!mounted || !settings.enabled) return;
        NotificationService.instance.scheduleDailyReminder(
          hour: settings.hour,
          minute: settings.minute,
        );
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !kIsWeb) {
      _onAppResumed();
    }
  }

  void _onAppResumed() {
    final settings = ref.read(notificationSettingsProvider).valueOrNull;
    if (settings == null || !settings.enabled) return;

    final activePlan = ref.read(activePlanProvider).valueOrNull;
    if (activePlan == null) return;

    final todayWorkout = activePlan.workoutForDate(DateTime.now());
    final body = todayWorkout != null
        ? 'Hoje: ${todayWorkout.title} — ${todayWorkout.durationMinutes} min 💪'
        : 'Não perca seu treino de hoje!';

    // Reagenda para garantir que o body está atualizado.
    NotificationService.instance.scheduleDailyReminder(
      hour: settings.hour,
      minute: settings.minute,
      body: body,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
