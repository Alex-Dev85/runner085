import 'package:runner085/features/plans/data/datasources/mocks/workout_builders.dart';
import 'package:runner085/features/plans/domain/entities/training_plan.dart';
import 'package:runner085/features/plans/domain/entities/training_week.dart';
import 'package:runner085/features/plans/domain/enums/race_distance.dart';

const _id = 'plan-21km-intermediate';

/// 21 km — Intermediário (10 semanas, 4 treinos/sem).
final TrainingPlan plan21kmIntermediate = TrainingPlan(
  id: _id,
  name: 'Meia Maratona Intermediário',
  description:
      'Plano de 10 semanas para corredores que já completaram uma meia maratona '
      'e querem melhorar o ritmo. Foco em qualidade e longões progressivos.',
  distance: RaceDistance.halfMarathon,
  level: RunnerLevel.intermediate,
  sessionsPerWeek: 4,
  weeks: [
    TrainingWeek(
      number: 1,
      focus: 'Reativação',
      workouts: [
        WB.easy(planId: _id, week: 1, day: 2, min: 50, km: 9),
        WB.fartlek(
          planId: _id,
          week: 1,
          day: 4,
          min: 55,
          km: 10,
          structure: '15min aquec. + 8x (2min forte / 1min trote) + 10min volta',
        ),
        WB.recovery(planId: _id, week: 1, day: 5, min: 35, km: 6),
        WB.longRun(planId: _id, week: 1, day: 7, min: 90, km: 16),
      ],
    ),
    TrainingWeek(
      number: 2,
      focus: 'Tempo',
      workouts: [
        WB.easy(planId: _id, week: 2, day: 2, min: 55, km: 10),
        WB.tempo(
          planId: _id,
          week: 2,
          day: 4,
          min: 60,
          km: 11,
          structure: '10min aquec. + 30min tempo + 10min volta',
        ),
        WB.recovery(planId: _id, week: 2, day: 5, min: 40, km: 7),
        WB.longRun(planId: _id, week: 2, day: 7, min: 100, km: 18),
      ],
    ),
    TrainingWeek(
      number: 3,
      focus: 'Tiros longos',
      workouts: [
        WB.easy(planId: _id, week: 3, day: 2, min: 55, km: 10),
        WB.interval(
          planId: _id,
          week: 3,
          day: 4,
          min: 65,
          km: 12,
          structure: '15min aquec. + 5x1,6km (rec. 600m trote) + 10min volta',
        ),
        WB.recovery(planId: _id, week: 3, day: 5, min: 40, km: 7),
        WB.longRun(planId: _id, week: 3, day: 7, min: 110, km: 20),
      ],
    ),
    TrainingWeek(
      number: 4,
      focus: 'Recuperação',
      notes: 'Volume reduzido para absorver.',
      workouts: [
        WB.easy(planId: _id, week: 4, day: 2, min: 45, km: 8),
        WB.fartlek(
          planId: _id,
          week: 4,
          day: 4,
          min: 50,
          km: 9,
          structure: '15min aquec. + 6x (2min forte / 2min trote) + 10min volta',
        ),
        WB.recovery(planId: _id, week: 4, day: 5, min: 35, km: 6),
        WB.longRun(planId: _id, week: 4, day: 7, min: 85, km: 15),
      ],
    ),
    TrainingWeek(
      number: 5,
      focus: 'Tempo longo',
      workouts: [
        WB.easy(planId: _id, week: 5, day: 2, min: 55, km: 10),
        WB.tempo(
          planId: _id,
          week: 5,
          day: 4,
          min: 70,
          km: 13,
          structure:
              '10min aquec. + 3x (15min tempo / 3min trote) + 10min volta',
        ),
        WB.recovery(planId: _id, week: 5, day: 5, min: 40, km: 7),
        WB.longRun(planId: _id, week: 5, day: 7, min: 120, km: 22),
      ],
    ),
    TrainingWeek(
      number: 6,
      focus: 'Volume + qualidade',
      workouts: [
        WB.easy(planId: _id, week: 6, day: 2, min: 60, km: 11),
        WB.interval(
          planId: _id,
          week: 6,
          day: 4,
          min: 70,
          km: 13,
          structure: '15min aquec. + 4x2km (rec. 800m trote) + 10min volta',
        ),
        WB.recovery(planId: _id, week: 6, day: 5, min: 45, km: 8),
        WB.longRun(planId: _id, week: 6, day: 7, min: 130, km: 24),
      ],
    ),
    TrainingWeek(
      number: 7,
      focus: 'Específico de prova',
      workouts: [
        WB.easy(planId: _id, week: 7, day: 2, min: 55, km: 10),
        WB.tempo(
          planId: _id,
          week: 7,
          day: 4,
          min: 75,
          km: 14,
          structure:
              '10min aquec. + 12 km no ritmo de meia maratona + 10min volta',
        ),
        WB.recovery(planId: _id, week: 7, day: 5, min: 40, km: 7),
        WB.longRun(
          planId: _id,
          week: 7,
          day: 7,
          min: 130,
          km: 24,
          title: 'Longão progressivo',
          structure: '18 km trote + 6 km no ritmo de prova',
        ),
      ],
    ),
    TrainingWeek(
      number: 8,
      focus: 'Pico',
      workouts: [
        WB.easy(planId: _id, week: 8, day: 2, min: 55, km: 10),
        WB.interval(
          planId: _id,
          week: 8,
          day: 4,
          min: 70,
          km: 13,
          structure: '15min aquec. + 5x1,6km (rec. 600m trote) + 10min volta',
        ),
        WB.recovery(planId: _id, week: 8, day: 5, min: 45, km: 8),
        WB.longRun(planId: _id, week: 8, day: 7, min: 110, km: 20),
      ],
    ),
    TrainingWeek(
      number: 9,
      focus: 'Tapering',
      workouts: [
        WB.easy(planId: _id, week: 9, day: 2, min: 45, km: 8),
        WB.tempo(
          planId: _id,
          week: 9,
          day: 4,
          min: 55,
          km: 10,
          structure: '10min aquec. + 6 km no ritmo de prova + 10min volta',
        ),
        WB.recovery(planId: _id, week: 9, day: 5, min: 35, km: 6),
        WB.longRun(planId: _id, week: 9, day: 7, min: 80, km: 14),
      ],
    ),
    TrainingWeek(
      number: 10,
      focus: 'Semana da prova',
      notes: 'Pernas frescas, estratégia clara.',
      workouts: [
        WB.easy(planId: _id, week: 10, day: 2, min: 35, km: 6),
        WB.interval(
          planId: _id,
          week: 10,
          day: 4,
          min: 35,
          km: 6,
          structure: '10min aquec. + 4x (400m forte / 400m trote)',
        ),
        WB.recovery(planId: _id, week: 10, day: 6, min: 25, km: 4),
        WB.race(
          planId: _id,
          week: 10,
          day: 7,
          min: 115,
          km: 21.1,
          title: 'Prova: 21 km — busque o PR!',
          structure: 'Aquec. + 21,1 km no ritmo planejado',
        ),
      ],
    ),
  ],
);
