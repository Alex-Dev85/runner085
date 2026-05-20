import 'package:runner085/features/plans/data/datasources/mocks/workout_builders.dart';
import 'package:runner085/features/plans/domain/entities/training_plan.dart';
import 'package:runner085/features/plans/domain/entities/training_week.dart';
import 'package:runner085/features/plans/domain/enums/race_distance.dart';

const _id = 'plan-10km-advanced';

/// 10 km — Avançado (10 semanas, 5 treinos/sem).
final TrainingPlan plan10kmAdvanced = TrainingPlan(
  id: _id,
  name: '10 km Avançado',
  description:
      'Plano de 10 semanas para corredores experientes em busca de PR no 10 km. '
      'Volume e qualidade altos, com duplas chaves semanais.',
  distance: RaceDistance.tenKm,
  level: RunnerLevel.advanced,
  sessionsPerWeek: 5,
  weeks: [
    TrainingWeek(
      number: 1,
      focus: 'Base',
      workouts: [
        WB.easy(planId: _id, week: 1, day: 2, min: 60, km: 11),
        WB.fartlek(
          planId: _id,
          week: 1,
          day: 3,
          min: 60,
          km: 11,
          structure: '15min aquec. + 10x (1min forte / 1min trote) + 10min volta',
        ),
        WB.easy(planId: _id, week: 1, day: 4, min: 50, km: 9),
        WB.tempo(
          planId: _id,
          week: 1,
          day: 5,
          min: 60,
          km: 11,
          structure: '10min aquec. + 25min tempo + 10min volta',
        ),
        WB.longRun(planId: _id, week: 1, day: 7, min: 95, km: 17),
      ],
    ),
    TrainingWeek(
      number: 2,
      focus: 'VO2 máx',
      workouts: [
        WB.easy(planId: _id, week: 2, day: 2, min: 60, km: 11),
        WB.interval(
          planId: _id,
          week: 2,
          day: 3,
          min: 65,
          km: 12,
          structure:
              '15min aquec. + 5x1200m no ritmo de 5km (rec. 400m trote) + 10min volta',
        ),
        WB.easy(planId: _id, week: 2, day: 4, min: 50, km: 9),
        WB.tempo(
          planId: _id,
          week: 2,
          day: 5,
          min: 65,
          km: 12,
          structure: '10min aquec. + 30min tempo + 10min volta',
        ),
        WB.longRun(planId: _id, week: 2, day: 7, min: 100, km: 18),
      ],
    ),
    TrainingWeek(
      number: 3,
      focus: 'Limiar',
      workouts: [
        WB.easy(planId: _id, week: 3, day: 2, min: 60, km: 11),
        WB.tempo(
          planId: _id,
          week: 3,
          day: 3,
          min: 70,
          km: 13,
          structure:
              '10min aquec. + 4x (10min tempo / 2min trote) + 10min volta',
        ),
        WB.easy(planId: _id, week: 3, day: 4, min: 55, km: 10),
        WB.interval(
          planId: _id,
          week: 3,
          day: 5,
          min: 65,
          km: 12,
          structure: '15min aquec. + 6x1km (rec. 200m trote) + 10min volta',
        ),
        WB.longRun(planId: _id, week: 3, day: 7, min: 105, km: 19),
      ],
    ),
    TrainingWeek(
      number: 4,
      focus: 'Recuperação',
      notes: 'Reduza volume e absorva o estímulo.',
      workouts: [
        WB.easy(planId: _id, week: 4, day: 2, min: 45, km: 8),
        WB.fartlek(
          planId: _id,
          week: 4,
          day: 3,
          min: 50,
          km: 9,
          structure: '15min aquec. + 8x (1min forte / 2min trote) + 10min volta',
        ),
        WB.recovery(planId: _id, week: 4, day: 4, min: 40, km: 7),
        WB.tempo(
          planId: _id,
          week: 4,
          day: 5,
          min: 55,
          km: 10,
          structure: '10min aquec. + 20min tempo + 10min volta',
        ),
        WB.longRun(planId: _id, week: 4, day: 7, min: 80, km: 14),
      ],
    ),
    TrainingWeek(
      number: 5,
      focus: 'Tiros longos',
      workouts: [
        WB.easy(planId: _id, week: 5, day: 2, min: 60, km: 11),
        WB.interval(
          planId: _id,
          week: 5,
          day: 3,
          min: 75,
          km: 14,
          structure:
              '15min aquec. + 4x2km no ritmo de 10km (rec. 600m trote) + 10min volta',
        ),
        WB.easy(planId: _id, week: 5, day: 4, min: 55, km: 10),
        WB.tempo(
          planId: _id,
          week: 5,
          day: 5,
          min: 70,
          km: 13,
          structure: '10min aquec. + 35min tempo + 10min volta',
        ),
        WB.longRun(planId: _id, week: 5, day: 7, min: 105, km: 19),
      ],
    ),
    TrainingWeek(
      number: 6,
      focus: 'Pico',
      workouts: [
        WB.easy(planId: _id, week: 6, day: 2, min: 60, km: 11),
        WB.interval(
          planId: _id,
          week: 6,
          day: 3,
          min: 75,
          km: 14,
          structure:
              '15min aquec. + 3x3km no ritmo de 10km (rec. 800m trote) + 10min volta',
        ),
        WB.easy(planId: _id, week: 6, day: 4, min: 55, km: 10),
        WB.race(
          planId: _id,
          week: 6,
          day: 5,
          min: 65,
          km: 12,
          title: 'Simulado',
          structure: '10min aquec. + 6 km no ritmo de prova + 10min volta',
        ),
        WB.longRun(planId: _id, week: 6, day: 7, min: 110, km: 20),
      ],
    ),
    TrainingWeek(
      number: 7,
      focus: 'Específico',
      workouts: [
        WB.easy(planId: _id, week: 7, day: 2, min: 55, km: 10),
        WB.tempo(
          planId: _id,
          week: 7,
          day: 3,
          min: 75,
          km: 14,
          structure:
              '10min aquec. + 8 km no ritmo de 10km + 10min volta',
        ),
        WB.easy(planId: _id, week: 7, day: 4, min: 50, km: 9),
        WB.interval(
          planId: _id,
          week: 7,
          day: 5,
          min: 65,
          km: 12,
          structure: '15min aquec. + 8x800m (rec. 200m trote) + 10min volta',
        ),
        WB.longRun(planId: _id, week: 7, day: 7, min: 100, km: 18),
      ],
    ),
    TrainingWeek(
      number: 8,
      focus: 'Recuperação ativa',
      workouts: [
        WB.easy(planId: _id, week: 8, day: 2, min: 50, km: 9),
        WB.fartlek(
          planId: _id,
          week: 8,
          day: 3,
          min: 55,
          km: 10,
          structure: '15min aquec. + 8x (1min forte / 2min trote) + 10min volta',
        ),
        WB.recovery(planId: _id, week: 8, day: 4, min: 40, km: 7),
        WB.tempo(
          planId: _id,
          week: 8,
          day: 5,
          min: 60,
          km: 11,
          structure: '10min aquec. + 25min tempo + 10min volta',
        ),
        WB.longRun(planId: _id, week: 8, day: 7, min: 85, km: 15),
      ],
    ),
    TrainingWeek(
      number: 9,
      focus: 'Tapering',
      workouts: [
        WB.easy(planId: _id, week: 9, day: 2, min: 45, km: 8),
        WB.interval(
          planId: _id,
          week: 9,
          day: 3,
          min: 50,
          km: 9,
          structure: '10min aquec. + 6x600m (rec. 200m trote) + 10min volta',
        ),
        WB.easy(planId: _id, week: 9, day: 4, min: 40, km: 7),
        WB.tempo(
          planId: _id,
          week: 9,
          day: 5,
          min: 45,
          km: 8,
          structure: '10min aquec. + 4 km no ritmo de prova + 10min volta',
        ),
        WB.longRun(planId: _id, week: 9, day: 7, min: 75, km: 13),
      ],
    ),
    TrainingWeek(
      number: 10,
      focus: 'Semana da prova',
      notes: 'Foco em recuperação e nutrição.',
      workouts: [
        WB.easy(planId: _id, week: 10, day: 2, min: 35, km: 6),
        WB.interval(
          planId: _id,
          week: 10,
          day: 4,
          min: 30,
          km: 5,
          structure: '10min aquec. + 4x (200m forte / 200m trote)',
        ),
        WB.recovery(planId: _id, week: 10, day: 6, min: 20, km: 3),
        WB.race(
          planId: _id,
          week: 10,
          day: 7,
          min: 55,
          km: 10,
          title: 'Prova: 10 km — busque o PR!',
          structure: 'Aquec. completo + 10 km no ritmo planejado',
        ),
      ],
    ),
  ],
);
