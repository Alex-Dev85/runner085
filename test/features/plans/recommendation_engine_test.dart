import 'package:flutter_test/flutter_test.dart';

import 'package:runner085/features/plans/domain/entities/training_plan.dart';
import 'package:runner085/features/plans/domain/enums/race_distance.dart';
import 'package:runner085/features/plans/domain/services/recommendation_engine.dart';

TrainingPlan _plan(String id, RaceDistance distance, RunnerLevel level) {
  return TrainingPlan(
    id: id,
    name: id,
    description: '',
    distance: distance,
    level: level,
    sessionsPerWeek: 3,
    weeks: const [],
  );
}

void main() {
  const engine = RecommendationEngine();

  final plans = [
    _plan('21k-adv', RaceDistance.halfMarathon, RunnerLevel.advanced),
    _plan('5k-beg', RaceDistance.fiveKm, RunnerLevel.beginner),
    _plan('5k-int', RaceDistance.fiveKm, RunnerLevel.intermediate),
    _plan('10k-beg', RaceDistance.tenKm, RunnerLevel.beginner),
    _plan('10k-int', RaceDistance.tenKm, RunnerLevel.intermediate),
  ];

  group('RecommendationEngine.recommend', () {
    test('ordena por pontuação de distância + nível', () {
      final result = engine.recommend(
        allPlans: plans,
        userLevel: RunnerLevel.intermediate,
        goalDistance: RaceDistance.tenKm,
      );

      expect(
        result.map((r) => r.plan.id).toList(),
        ['10k-int', '10k-beg', '5k-int', '5k-beg'],
      );
      // 50 (distância exata) + 40 (nível exato)
      expect(result[0].score, 90);
      // 50 (distância exata) + 20 (um nível abaixo)
      expect(result[1].score, 70);
      // 20 (um degrau de distância abaixo) + 40 (nível exato)
      expect(result[2].score, 60);
      // 20 + 20
      expect(result[3].score, 40);
    });

    test('marca apenas o melhor resultado como primário', () {
      final result = engine.recommend(
        allPlans: plans,
        userLevel: RunnerLevel.intermediate,
        goalDistance: RaceDistance.tenKm,
      );

      expect(result.first.isPrimary, isTrue);
      expect(result.skip(1).every((r) => !r.isPrimary), isTrue);
    });

    test('match exato recebe o motivo de nível e objetivo', () {
      final result = engine.recommend(
        allPlans: plans,
        userLevel: RunnerLevel.intermediate,
        goalDistance: RaceDistance.tenKm,
      );

      expect(
        result.first.reason,
        'Perfeito para seu nível e objetivo de 10 km.',
      );
    });

    test('plano um nível acima do usuário recebe apenas 10 pontos de nível',
        () {
      final result = engine.recommend(
        allPlans: [
          _plan('21k-adv', RaceDistance.halfMarathon, RunnerLevel.advanced),
        ],
        userLevel: RunnerLevel.intermediate,
        goalDistance: RaceDistance.halfMarathon,
      );

      // 50 (distância exata) + 10 (um nível acima)
      expect(result.single.score, 60);
    });

    test('respeita maxResults', () {
      final result = engine.recommend(
        allPlans: plans,
        userLevel: RunnerLevel.intermediate,
        goalDistance: RaceDistance.tenKm,
        maxResults: 2,
      );

      expect(result, hasLength(2));
      expect(result.first.plan.id, '10k-int');
    });

    test('retorna lista vazia quando não há planos', () {
      final result = engine.recommend(
        allPlans: const [],
        userLevel: RunnerLevel.beginner,
        goalDistance: RaceDistance.fiveKm,
      );

      expect(result, isEmpty);
    });
  });
}
