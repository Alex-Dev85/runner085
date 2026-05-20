import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runner085/app/app.dart';
import 'package:runner085/app/bootstrap.dart';
import 'package:runner085/app/config/environment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppBootstrap.initialize(Environment.dev);

  runApp(
    const ProviderScope(
      child: RunnerApp(),
    ),
  );
}
