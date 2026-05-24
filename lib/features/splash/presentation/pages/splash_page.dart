import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runner085/app/router/app_routes.dart';
import 'package:runner085/core/providers/core_providers.dart';
import 'package:runner085/features/onboarding/data/onboarding_repository.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Duração mínima para branding.
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final onboardingDone = await OnboardingRepository().isCompleted();

    // Onboarding não concluído → sempre vai para onboarding primeiro.
    if (!onboardingDone) {
      if (mounted) context.go(AppRoutes.onboarding);
      return;
    }

    // Onboarding concluído → verifica autenticação.
    final user = await ref.read(authRepositoryProvider).currentUser;
    if (!mounted) return;

    if (user != null) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_run,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Runner085',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Seu treino de corrida',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
