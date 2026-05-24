import 'package:runner085/features/plans/domain/entities/training_plan.dart';
import 'package:runner085/features/plans/domain/enums/race_distance.dart';

/// Resultado de uma recomendação de plano.
class PlanRecommendation {
  final TrainingPlan plan;

  /// Pontuação de 0–100 indicando o quão bem o plano se encaixa no perfil.
  final int score;

  /// Motivo principal da recomendação (exibido na UI).
  final String reason;

  /// Se é a recomendação principal (melhor match).
  final bool isPrimary;

  const PlanRecommendation({
    required this.plan,
    required this.score,
    required this.reason,
    this.isPrimary = false,
  });
}

/// Motor de recomendação de planos baseado em nível e objetivo do corredor.
///
/// Critérios de pontuação:
///   +50  — distância bate exatamente com o objetivo
///   +20  — distância é um degrau abaixo (progressão segura)
///   +40  — nível bate exatamente
///   +20  — nível é um degrau abaixo (desafio acessível)
///   +10  — nível é um degrau acima (plano mais leve como recuperação)
class RecommendationEngine {
  const RecommendationEngine();

  /// Retorna os planos ordenados por relevância para o perfil informado.
  /// [maxResults] limita quantos planos são retornados.
  List<PlanRecommendation> recommend({
    required List<TrainingPlan> allPlans,
    required RunnerLevel userLevel,
    required RaceDistance goalDistance,
    int maxResults = 4,
  }) {
    final scored = allPlans.map((plan) {
      final score = _score(plan, userLevel, goalDistance);
      final reason = _reason(plan, userLevel, goalDistance);
      return PlanRecommendation(plan: plan, score: score, reason: reason);
    }).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    final top = scored.take(maxResults).toList();

    // Marca o melhor como primário.
    if (top.isNotEmpty) {
      return [
        PlanRecommendation(
          plan: top.first.plan,
          score: top.first.score,
          reason: top.first.reason,
          isPrimary: true,
        ),
        ...top.skip(1),
      ];
    }
    return top;
  }

  int _score(TrainingPlan plan, RunnerLevel level, RaceDistance goal) {
    var score = 0;

    // ── Pontuação por distância ──────────────────────────────────────────────
    if (plan.distance == goal) {
      score += 50;
    } else if (_distanceIndex(plan.distance) == _distanceIndex(goal) - 1) {
      // Um degrau abaixo: bom ponto de partida antes do objetivo
      score += 20;
    }

    // ── Pontuação por nível ──────────────────────────────────────────────────
    final planLevelIdx = _levelIndex(plan.level);
    final userLevelIdx = _levelIndex(level);

    if (planLevelIdx == userLevelIdx) {
      score += 40;
    } else if (planLevelIdx == userLevelIdx - 1) {
      // Plano um nível abaixo: desafio acessível
      score += 20;
    } else if (planLevelIdx == userLevelIdx + 1) {
      // Plano um nível acima: mais leve, bom para recuperação
      score += 10;
    }

    return score;
  }

  String _reason(TrainingPlan plan, RunnerLevel level, RaceDistance goal) {
    final distanceMatch = plan.distance == goal;
    final levelMatch = plan.level == level;

    if (distanceMatch && levelMatch) {
      return 'Perfeito para seu nível e objetivo de ${goal.displayName}.';
    }
    if (distanceMatch && _levelIndex(plan.level) < _levelIndex(level)) {
      return 'Ideal para ${goal.displayName} com progressão segura.';
    }
    if (distanceMatch) {
      return 'Alinhado com seu objetivo de ${goal.displayName}.';
    }
    if (_distanceIndex(plan.distance) == _distanceIndex(goal) - 1) {
      return 'Boa base antes de avançar para ${goal.displayName}.';
    }
    if (levelMatch) {
      return 'Compatível com seu nível ${level.displayName}.';
    }
    return 'Plano alternativo para variar o treino.';
  }

  int _distanceIndex(RaceDistance d) => switch (d) {
        RaceDistance.fiveKm => 0,
        RaceDistance.tenKm => 1,
        RaceDistance.halfMarathon => 2,
        RaceDistance.marathon => 3,
      };

  int _levelIndex(RunnerLevel l) => switch (l) {
        RunnerLevel.beginner => 0,
        RunnerLevel.intermediate => 1,
        RunnerLevel.advanced => 2,
        RunnerLevel.elite => 3,
      };
}
