import 'package:runner085/features/plans/data/datasources/mocks/workout_builders.dart';
import 'package:runner085/features/plans/domain/entities/training_plan.dart';
import 'package:runner085/features/plans/domain/entities/training_week.dart';
import 'package:runner085/features/plans/domain/enums/race_distance.dart';

const _id = 'plan-5km-intermediate';

/// 5 km — Intermediário (6 semanas, 4 treinos/sem).
/// Foco: melhorar tempo. Inclui intervalado, tempo run e longão.
final TrainingPlan plan5kmIntermediate = TrainingPlan(
  id: _id,
  name: '5 km Intermediário',
  description:
      'Plano de 6 semanas para corredores que já fazem 5 km e querem '
      'melhorar a marca. Inclui treinos de qualidade.',
  distance: RaceDistance.fiveKm,
  level: RunnerLevel.intermediate,
  sessionsPerWeek: 4,
  weeks: [
    TrainingWeek(
      number: 1,
      focus: 'Reativando intensidade',
      workouts: [
        WB.easy(planId: _id, week: 1, day: 2, min: 35, km: 6),
        WB.fartlek(
          planId: _id,
          week: 1,
          day: 4,
          min: 40,
          km: 7,
          structure: '10min aquec. + 8x (1min forte / 1min trote) + 10min volta',
        ),
        WB.recovery(planId: _id, week: 1, day: 5, min: 30, km: 5),
        WB.longRun(planId: _id, week: 1, day: 7, min: 50, km: 8),
      ],
    ),
    TrainingWeek(
      number: 2,
      focus: 'Tempo introdutório',
      workouts: [
        WB.easy(planId: _id, week: 2, day: 2, min: 40, km: 7),
        WB.tempo(
          planId: _id,
          week: 2,
          day: 4,
          min: 40,
          km: 7,
          structure: '10min aquec. + 15min tempo + 10min volta',
        ),
        WB.recovery(planId: _id, week: 2, day: 5, min: 30, km: 5),
        WB.longRun(planId: _id, week: 2, day: 7, min: 55, km: 9),
      ],
    ),
    TrainingWeek(
      number: 3,
      focus: 'Intervalado curto',
      workouts: [
        WB.easy(planId: _id, week: 3, day: 2, min: 40, km: 7),
        WB.interval(
          planId: _id,
          week: 3,
          day: 4,
          min: 45,
          km: 7,
          structure:
              '15min aquec. + 8x400m forte (rec. 200m trote) + 10min volta',
        ),
        WB.recovery(planId: _id, week: 3, day: 5, min: 30, km: 5),
        WB.longRun(planId: _id, week: 3, day: 7, min: 60, km: 10),
      ],
    ),
    TrainingWeek(
      number: 4,
      focus: 'Tempo + tiros',
      workouts: [
        WB.easy(planId: _id, week: 4, day: 2, min: 40, km: 7),
        WB.tempo(
          planId: _id,
          week: 4,
          day: 4,
          min: 50,
          km: 8,
          structure:
              '10min aquec. + 2x (10min tempo / 3min trote) + 10min volta',
        ),
        WB.recovery(planId: _id, week: 4, day: 5, min: 30, km: 5),
        WB.longRun(planId: _id, week: 4, day: 7, min: 60, km: 10),
      ],
    ),
    TrainingWeek(
      number: 5,
      focus: 'Específico de prova',
      workouts: [
        WB.easy(planId: _id, week: 5, day: 2, min: 35, km: 6),
        WB.interval(
          planId: _id,
          week: 5,
          day: 4,
          min: 50,
          km: 8,
          structure: '15min aquec. + 5x1km (rec. 400m trote) + 10min volta',
        ),
        WB.recovery(planId: _id, week: 5, day: 5, min: 30, km: 5),
        WB.race(
          planId: _id,
          week: 5,
          day: 7,
          min: 50,
          km: 8,
          title: 'Simulado',
          structure: '10min aquec. + 4 km no ritmo da prova + 10min volta',
        ),
      ],
    ),
    TrainingWeek(
      number: 6,
      focus: 'Tapering + prova',
      notes: 'Reduzimos volume mantendo um pouco de intensidade.',
      workouts: [
        WB.easy(planId: _id, week: 6, day: 2, min: 30, km: 5),
        WB.interval(
          planId: _id,
          week: 6,
          day: 4,
          min: 30,
          km: 5,
          structure: '10min aquec. + 4x (200m forte / 200m trote)',
        ),
        WB.recovery(planId: _id, week: 6, day: 6, min: 20, km: 3),
        WB.race(
          planId: _id,
          week: 6,
          day: 7,
          min: 30,
          km: 5,
          title: 'Prova: 5 km!',
          structure: 'Aquec. + 5 km no seu ritmo de prova',
        ),
      ],
    ),
  ],
);
