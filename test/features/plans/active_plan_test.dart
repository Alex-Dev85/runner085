import 'package:flutter_test/flutter_test.dart';

import 'package:runner085/features/plans/domain/entities/active_plan.dart';
import 'package:runner085/features/plans/domain/entities/training_plan.dart';
import 'package:runner085/features/plans/domain/entities/training_week.dart';
import 'package:runner085/features/plans/domain/entities/workout.dart';
import 'package:runner085/features/plans/domain/enums/race_distance.dart';
import 'package:runner085/features/plans/domain/enums/training_zone.dart';
import 'package:runner085/features/plans/domain/enums/workout_type.dart';

Workout _workout(String id, int dayOfWeek, {bool rest = false}) {
  return Workout(
    id: id,
    dayOfWeek: dayOfWeek,
    title: id,
    type: rest ? WorkoutType.rest : WorkoutType.easy,
    zone: TrainingZone.z2,
    durationMinutes: 30,
    description: '',
  );
}

/// Plano de 2 semanas:
///   semana 1 → segunda (w1-mon), quarta (descanso), sábado (w1-sat)
///   semana 2 → segunda (w2-mon)
final _plan = TrainingPlan(
  id: 'test-plan',
  name: 'Plano de teste',
  description: '',
  distance: RaceDistance.fiveKm,
  level: RunnerLevel.beginner,
  sessionsPerWeek: 2,
  weeks: [
    TrainingWeek(
      number: 1,
      focus: 'Base',
      workouts: [
        _workout('w1-mon', 1),
        _workout('w1-wed-rest', 3, rest: true),
        _workout('w1-sat', 6),
      ],
    ),
    TrainingWeek(
      number: 2,
      focus: 'Progressão',
      workouts: [
        _workout('w2-mon', 1),
      ],
    ),
  ],
);

void main() {
  group('ActivePlan iniciando numa segunda-feira', () {
    // 5 de janeiro de 2026 é uma segunda-feira.
    final activePlan = ActivePlan(plan: _plan, startDate: DateTime(2026, 1, 5));

    test('retorna o treino do dia de início', () {
      expect(activePlan.workoutForDate(DateTime(2026, 1, 5))?.id, 'w1-mon');
    });

    test('ignora a hora do dia', () {
      expect(
        activePlan.workoutForDate(DateTime(2026, 1, 5, 23, 59))?.id,
        'w1-mon',
      );
    });

    test('retorna null em dia sem treino', () {
      expect(activePlan.workoutForDate(DateTime(2026, 1, 6)), isNull);
    });

    test('retorna null em dia de descanso', () {
      expect(activePlan.workoutForDate(DateTime(2026, 1, 7)), isNull);
    });

    test('retorna treinos posteriores da mesma semana e da seguinte', () {
      expect(activePlan.workoutForDate(DateTime(2026, 1, 10))?.id, 'w1-sat');
      expect(activePlan.workoutForDate(DateTime(2026, 1, 12))?.id, 'w2-mon');
    });

    test('retorna null antes do início e depois do fim do plano', () {
      expect(activePlan.workoutForDate(DateTime(2026, 1, 4)), isNull);
      expect(activePlan.workoutForDate(DateTime(2026, 1, 19)), isNull);
    });

    test('endDate é o último dia da última semana', () {
      expect(activePlan.endDate, DateTime(2026, 1, 18));
    });

    test('trainingDays lista apenas dias com treino (sem descanso)', () {
      expect(activePlan.trainingDays, {
        DateTime(2026, 1, 5),
        DateTime(2026, 1, 10),
        DateTime(2026, 1, 12),
      });
    });
  });

  group('ActivePlan iniciando no meio da semana', () {
    // 7 de janeiro de 2026 é uma quarta-feira.
    final activePlan = ActivePlan(plan: _plan, startDate: DateTime(2026, 1, 7));

    test('nenhum dia de treino cai antes da data de início', () {
      final start = DateTime(2026, 1, 7);
      expect(
        activePlan.trainingDays.every((d) => !d.isBefore(start)),
        isTrue,
      );
    });

    test('trainingDays é consistente com workoutForDate', () {
      expect(activePlan.trainingDays, {
        DateTime(2026, 1, 10), // sábado da 1ª janela → w1-sat
        DateTime(2026, 1, 12), // segunda da 1ª janela → w1-mon
        DateTime(2026, 1, 19), // segunda da 2ª janela → w2-mon
      });
      for (final day in activePlan.trainingDays) {
        expect(
          activePlan.workoutForDate(day),
          isNotNull,
          reason: 'esperava treino em $day',
        );
      }
      expect(activePlan.workoutForDate(DateTime(2026, 1, 10))?.id, 'w1-sat');
      expect(activePlan.workoutForDate(DateTime(2026, 1, 12))?.id, 'w1-mon');
      expect(activePlan.workoutForDate(DateTime(2026, 1, 19))?.id, 'w2-mon');
    });
  });
}
