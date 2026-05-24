import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runner085/features/plans/domain/services/recommendation_engine.dart';
import 'package:runner085/features/plans/presentation/providers/plans_provider.dart';
import 'package:runner085/features/profile/presentation/providers/user_profile_provider.dart';

// ── Engine ────────────────────────────────────────────────────────────────────

final recommendationEngineProvider = Provider<RecommendationEngine>((ref) {
  return const RecommendationEngine();
});

// ── Recomendações ─────────────────────────────────────────────────────────────

/// Lista de planos recomendados para o perfil atual do usuário.
/// Retorna vazio se o perfil ainda não tiver objetivo definido.
final recommendedPlansProvider =
    FutureProvider<List<PlanRecommendation>>((ref) async {
  final profileAsync = ref.watch(userProfileProvider);
  final profile = profileAsync.valueOrNull;

  // Sem objetivo definido, não há como recomendar.
  if (profile == null || !profile.isComplete) return [];

  final plans = await ref.watch(plansProvider.future);
  final engine = ref.read(recommendationEngineProvider);

  return engine.recommend(
    allPlans: plans,
    userLevel: profile.level,
    goalDistance: profile.goalDistance!,
  );
});
