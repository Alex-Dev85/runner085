import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:runner085/app/router/app_routes.dart';
import 'package:runner085/app/router/shell_scaffold.dart';
import 'package:runner085/features/auth/presentation/pages/login_page.dart';
import 'package:runner085/features/auth/presentation/pages/signup_page.dart';
import 'package:runner085/features/calendar/presentation/pages/calendar_page.dart';
import 'package:runner085/features/home/presentation/pages/home_page.dart';
import 'package:runner085/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:runner085/features/plans/presentation/pages/plan_detail_page.dart';
import 'package:runner085/features/plans/presentation/pages/plans_page.dart';
import 'package:runner085/features/plans/presentation/pages/week_detail_page.dart';
import 'package:runner085/features/plans/presentation/pages/workout_detail_page.dart';
import 'package:runner085/features/progress/presentation/pages/history_page.dart';
import 'package:runner085/features/profile/presentation/pages/profile_page.dart';
import 'package:runner085/features/settings/presentation/pages/settings_page.dart';
import 'package:runner085/features/splash/presentation/pages/splash_page.dart';
import 'package:runner085/features/training/presentation/pages/training_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    errorBuilder: (context, state) => const _ErrorPage(),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        pageBuilder: (context, state) =>
            _fadePage(state, const SplashPage()),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) =>
            _fadePage(state, const LoginPage()),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: 'signup',
        pageBuilder: (context, state) =>
            _fadePage(state, const SignUpPage()),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) =>
            _fadePage(state, const OnboardingPage()),
      ),
      // Plans detail routes (outside the shell so they don't show bottom nav)
      GoRoute(
        path: '${AppRoutes.plans}/:planId',
        name: 'plan-detail',
        builder: (context, state) {
          final id = state.pathParameters['planId']!;
          return PlanDetailPage(planId: id);
        },
        routes: [
          GoRoute(
            path: 'week/:weekNumber',
            name: 'week-detail',
            builder: (context, state) {
              final id = state.pathParameters['planId']!;
              final week = int.parse(state.pathParameters['weekNumber']!);
              return WeekDetailPage(planId: id, weekNumber: week);
            },
            routes: [
              GoRoute(
                path: 'workout/:workoutId',
                name: 'workout-detail',
                builder: (context, state) {
                  final id = state.pathParameters['planId']!;
                  final week = int.parse(state.pathParameters['weekNumber']!);
                  final workoutId = state.pathParameters['workoutId']!;
                  return WorkoutDetailPage(
                    planId: id,
                    weekNumber: week,
                    workoutId: workoutId,
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.history,
        name: 'history',
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            pageBuilder: (context, state) =>
                _fadePage(state, const HomePage()),
          ),
          GoRoute(
            path: AppRoutes.plans,
            name: 'plans',
            pageBuilder: (context, state) =>
                _fadePage(state, const PlansPage()),
          ),
          GoRoute(
            path: AppRoutes.training,
            name: 'training',
            pageBuilder: (context, state) =>
                _fadePage(state, const TrainingPage()),
          ),
          GoRoute(
            path: AppRoutes.calendar,
            name: 'calendar',
            pageBuilder: (context, state) =>
                _fadePage(state, const CalendarPage()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            pageBuilder: (context, state) =>
                _fadePage(state, const ProfilePage()),
          ),
        ],
      ),
    ],
  );
});

/// Transição em fade usada nas abas e no fluxo de entrada (splash, login,
/// cadastro, onboarding). As telas de detalhe mantêm a transição nativa da
/// plataforma, preservando o gesto de voltar do iOS.
CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}

class _ErrorPage extends StatelessWidget {
  const _ErrorPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Página não encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Voltar ao início'),
            ),
          ],
        ),
      ),
    );
  }
}
