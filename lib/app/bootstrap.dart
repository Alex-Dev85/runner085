import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import 'package:runner085/app/config/environment.dart';
import 'package:runner085/app/config/firebase_options_dev.dart' as dev;
import 'package:runner085/app/config/firebase_options_prod.dart' as prod;
import 'package:runner085/core/services/notification_service.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
  ),
);

class AppBootstrap {
  /// When true, the app skips Firebase initialization and uses a fake
  /// in-memory auth repository so you can validate the UI without setting
  /// up Firebase. Switch to `false` after running `flutterfire configure`.
  static const bool demoMode = true;

  static late Environment _environment;

  static Environment get environment => _environment;

  static Future<void> initialize(Environment env) async {
    _environment = env;

    // Lock orientation to portrait
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Initialize Firebase (skipped in demo mode)
    if (!demoMode) {
      await _initializeFirebase(env);
    } else {
      logger.w('App rodando em DEMO MODE — Firebase desabilitado');
    }

    // Inicializa o serviço de notificações (não-web).
    if (!kIsWeb) {
      await NotificationService.instance.initialize();
    }

    // Global error handling
    _setupErrorHandling();
  }

  static Future<void> _initializeFirebase(Environment env) async {
    final options = switch (env) {
      Environment.dev => dev.DefaultFirebaseOptions.currentPlatform,
      Environment.prod => prod.DefaultFirebaseOptions.currentPlatform,
    };

    await Firebase.initializeApp(options: options);
  }

  static void _setupErrorHandling() {
    FlutterError.onError = (details) {
      logger.e(
        'Flutter Error',
        error: details.exception,
        stackTrace: details.stack,
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      logger.e(
        'Platform Error',
        error: error,
        stackTrace: stack,
      );
      return true;
    };
  }
}
