import 'package:runner085/features/plans/data/datasources/mocks/workout_builders.dart';
import 'package:runner085/features/plans/domain/entities/training_plan.dart';
import 'package:runner085/features/plans/domain/entities/training_week.dart';
import 'package:runner085/features/plans/domain/enums/race_distance.dart';

const _id = 'plan-10km-intermediate';

/// 10 km — Intermediário (8 semanas, 4 treinos/sem).
final TrainingPlan plan10kmIntermediate = TrainingPlan(
  id: _id,
  name: '10 km Intermediário',
  description:
      'Plano de 8 semanas para corredores que já correm 10 km e querem '
      'evoluir o ritmo. Mistura de tempo, intervalado e longão.',
  distance: RaceDistance.tenKm,
  level: RunnerLevel.intermediate,
  sessionsPerWeek: 4,
  weeks: [
    TrainingWeek(
      number: 1,
      focus: 'Reativação',
      workouts: [
        WB.easy(planId: _id, week: 1, day: 2, min: 45, km: 8),
        WB.fartlek(
          planId: _id,
          week: 1,
          day: 4,
          min: 50,
          km: 9,
          structure: '15min aquec. + 8x (1min forte / 1min trote) + 10min volta',
        ),
        WB.recovery(planId: _id, week: 1, day: 5, min: 35, km: 6),
        WB.longRun(planId: _id, week: 1, day: 7, min: 70, km: 12),
      ],
    ),
    TrainingWeek(
      number: 2,
      focus: 'Tempo introdutório',
      workouts: [
        WB.easy(planId: _id, week: 2, day: 2, min: 50, km: 9),
        WB.tempo(
          planId: _id,
          week: 2,
          day: 4,
          min: 55,
          km: 10,
          structure: '10min aquec. + 25min tempo + 10min volta',
        ),
        WB.recovery(planId: _id, week: 2, day: 5, min: 35, km: 6),
        WB.longRun(planId: _id, week: 2, day: 7, min: 80, km: 14),
      ],
    ),
    TrainingWeek(
      number: 3,
      focus: 'Tiros',
      workouts: [
        WB.easy(planId: _id, week: 3, day: 2, min: 50, km: 9),
        WB.interval(
          planId: _id,
          week: 3,
          day: 4,
          min: 60,
          km: 11,
          structure: '15min aquec. + 6x1km (rec. 400m trote) + 10min volta',
        ),
        WB.recovery(planId: _id, week: 3, day: 5, min: 35, km: 6),
        WB.longRun(planId: _id, week: 3, day: 7, min: 85, km: 15),
      ],
    ),
    TrainingWeek(
      number: 4,
      focus: 'Recuperação',
      notes: 'Volume reduzido para absorver o ciclo.',
      workouts: [
        WB.easy(planId: _id, week: 4, day: 2, min: 40, km: 7),
        WB.fartlek(
          planId: _id,
          week: 4,
          day: 4,
          min: 45,
          km: 8,
          structure: '15min aquec. + 6x (1min forte / 2min trote) + 10min volta',
        ),
        WB.recovery(planId: _id, week: 4, day: 5, min: 30, km: 5),
        WB.longRun(planId: _id, week: 4, day: 7, min: 70, km: 12),
      ],
    ),
    TrainingWeek(
      number: 5,
      focus: 'Tempo + tiros',
      workouts: [
        WB.easy(planId: _id, week: 5, day: 2, min: 50, km: 9),
        WB.tempo(
          planId: _id,
          week: 5,
          day: 4,
          min: 65,
          km: 12,
          structure:
              '10min aquec. + 3x (12min tempo / 3min trote) + 10min volta',
        ),
        WB.recovery(planId: _id, week: 5, day: 5, min: 40, km: 7),
        WB.longRun(planId: _id, week: 5, day: 7, min: 90, km: 16),
      ],
    ),
    TrainingWeek(
      number: 6,
      focus: 'Volume + qualidade',
      workouts: [
        WB.easy(planId: _id, week: 6, day: 2, min: 55, km: 10),
        WB.interval(
          planId: _id,
          week: 6,
          day: 4,
          min: 65,
          km: 12,
          structure: '15min aquec. + 4x2km (rec. 600m trote) + 10min volta',
        ),
        WB.recovery(planId: _id, week: 6, day: 5, min: 40, km: 7),
        WB.longRun(planId: _id, week: 6, day: 7, min: 100, km: 18),
      ],
    ),
    TrainingWeek(
      number: 7,
      focus: 'Específico de prova',
      workouts: [
        WB.easy(planId: _id, week: 7, day: 2, min: 45, km: 8),
        WB.tempo(
          planId: _id,
          week: 7,
          day: 4,
          min: 60,
          km: 11,
          structure: '10min aquec. + 8 km no ritmo de prova + 10min volta',
        ),
        WB.recovery(planId: _id, week: 7, day: 5, min: 35, km: 6),
        WB.longRun(planId: _id, week: 7, day: 7, min: 75, km: 13),
      ],
    ),
    TrainingWeek(
      number: 8,
      focus: 'Tapering + prova',
      notes: 'Reduzimos volume e mantemos um pouco de intensidade.',
      workouts: [
        WB.easy(planId: _id, week: 8, day: 2, min: 35, km: 6),
        WB.interval(
          planId: _id,
          week: 8,
          day: 4,
          min: 35,
          km: 6,
          structure: '10min aquec. + 4x (400m forte / 400m trote)',
        ),
        WB.recovery(planId: _id, week: 8, day: 6, min: 25, km: 4),
        WB.race(
          planId: _id,
          week: 8,
          day: 7,
          min: 55,
          km: 10,
          title: 'Prova: 10 km — vai com tudo!',
          structure: 'Aquec. + 10 km no ritmo planejado',
        ),
      ],
    ),
  ],
);
