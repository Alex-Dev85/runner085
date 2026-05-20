import 'package:runner085/features/plans/data/datasources/mocks/workout_builders.dart';
import 'package:runner085/features/plans/domain/entities/training_plan.dart';
import 'package:runner085/features/plans/domain/entities/training_week.dart';
import 'package:runner085/features/plans/domain/enums/race_distance.dart';

const _id = 'plan-5km-advanced';

/// 5 km — Avançado (8 semanas, 5 treinos/sem).
/// Para corredores experientes buscando PR (recorde pessoal).
final TrainingPlan plan5kmAdvanced = TrainingPlan(
  id: _id,
  name: '5 km Avançado',
  description:
      'Plano agressivo de 8 semanas para quem busca PR nos 5 km. Volume '
      'alto, qualidade refinada e duplas sessões em algumas semanas.',
  distance: RaceDistance.fiveKm,
  level: RunnerLevel.advanced,
  sessionsPerWeek: 5,
  weeks: [
    TrainingWeek(
      number: 1,
      focus: 'Base de qualidade',
      workouts: [
        WB.easy(planId: _id, week: 1, day: 2, min: 50, km: 9),
        WB.interval(
          planId: _id,
          week: 1,
          day: 3,
          min: 55,
          km: 10,
          structure: '15min aquec. + 12x400m (rec. 100m trote) + 10min volta',
        ),
        WB.easy(planId: _id, week: 1, day: 4, min: 45, km: 8),
        WB.tempo(
          planId: _id,
          week: 1,
          day: 5,
          min: 55,
          km: 10,
          structure: '10min aquec. + 25min tempo + 10min volta',
        ),
        WB.longRun(planId: _id, week: 1, day: 7, min: 70, km: 13),
      ],
    ),
    TrainingWeek(
      number: 2,
      focus: 'VO2 máx',
      workouts: [
        WB.easy(planId: _id, week: 2, day: 2, min: 50, km: 9),
        WB.interval(
          planId: _id,
          week: 2,
          day: 3,
          min: 60,
          km: 11,
          structure:
              '15min aquec. + 6x800m no ritmo de 5km (rec. 400m trote) + 10min volta',
        ),
        WB.easy(planId: _id, week: 2, day: 4, min: 45, km: 8),
        WB.fartlek(
          planId: _id,
          week: 2,
          day: 5,
          min: 50,
          km: 9,
          structure: '15min aquec. + 10x (1min forte / 1min trote) + 10min volta',
        ),
        WB.longRun(planId: _id, week: 2, day: 7, min: 75, km: 14),
      ],
    ),
    TrainingWeek(
      number: 3,
      focus: 'Limiar',
      workouts: [
        WB.easy(planId: _id, week: 3, day: 2, min: 50, km: 9),
        WB.tempo(
          planId: _id,
          week: 3,
          day: 3,
          min: 60,
          km: 11,
          structure:
              '10min aquec. + 3x (10min tempo / 2min trote) + 10min volta',
        ),
        WB.easy(planId: _id, week: 3, day: 4, min: 50, km: 9),
        WB.interval(
          planId: _id,
          week: 3,
          day: 5,
          min: 60,
          km: 11,
          structure: '15min aquec. + 5x1km (rec. 200m trote) + 10min volta',
        ),
        WB.longRun(planId: _id, week: 3, day: 7, min: 80, km: 15),
      ],
    ),
    TrainingWeek(
      number: 4,
      focus: 'Recuperação',
      notes: 'Semana de menor volume para absorver o estímulo.',
      workouts: [
        WB.easy(planId: _id, week: 4, day: 2, min: 40, km: 7),
        WB.fartlek(
          planId: _id,
          week: 4,
          day: 3,
          min: 45,
          km: 8,
          structure: '15min aquec. + 8x (1min forte / 2min trote) + 10min volta',
        ),
        WB.recovery(planId: _id, week: 4, day: 4, min: 35, km: 6),
        WB.tempo(
          planId: _id,
          week: 4,
          day: 5,
          min: 50,
          km: 9,
          structure: '10min aquec. + 20min tempo + 10min volta',
        ),
        WB.longRun(planId: _id, week: 4, day: 7, min: 60, km: 11),
      ],
    ),
    TrainingWeek(
      number: 5,
      focus: 'Tiros longos',
      workouts: [
        WB.easy(planId: _id, week: 5, day: 2, min: 50, km: 9),
        WB.interval(
          planId: _id,
          week: 5,
          day: 3,
          min: 65,
          km: 12,
          structure:
              '15min aquec. + 5x1200m no ritmo de 5km (rec. 400m trote) + 10min volta',
        ),
        WB.easy(planId: _id, week: 5, day: 4, min: 50, km: 9),
        WB.tempo(
          planId: _id,
          week: 5,
          day: 5,
          min: 60,
          km: 11,
          structure: '10min aquec. + 4x (8min tempo / 2min trote) + 10min volta',
        ),
        WB.longRun(planId: _id, week: 5, day: 7, min: 80, km: 15),
      ],
    ),
    TrainingWeek(
      number: 6,
      focus: 'Específico',
      workouts: [
        WB.easy(planId: _id, week: 6, day: 2, min: 50, km: 9),
        WB.interval(
          planId: _id,
          week: 6,
          day: 3,
          min: 65,
          km: 12,
          structure:
              '15min aquec. + 8x600m no ritmo de 3km (rec. 200m trote) + 10min volta',
        ),
        WB.easy(planId: _id, week: 6, day: 4, min: 50, km: 9),
        WB.race(
          planId: _id,
          week: 6,
          day: 5,
          min: 55,
          km: 10,
          title: 'Simulado',
          structure: '10min aquec. + 3 km no ritmo de prova + 10min volta',
        ),
        WB.longRun(planId: _id, week: 6, day: 7, min: 75, km: 14),
      ],
    ),
    TrainingWeek(
      number: 7,
      focus: 'Tapering',
      workouts: [
        WB.easy(planId: _id, week: 7, day: 2, min: 40, km: 7),
        WB.interval(
          planId: _id,
          week: 7,
          day: 3,
          min: 45,
          km: 8,
          structure: '10min aquec. + 6x400m forte (rec. 200m trote) + 10min volta',
        ),
        WB.easy(planId: _id, week: 7, day: 4, min: 35, km: 6),
        WB.tempo(
          planId: _id,
          week: 7,
          day: 5,
          min: 40,
          km: 7,
          structure: '10min aquec. + 12min ritmo de prova + 10min volta',
        ),
        WB.longRun(planId: _id, week: 7, day: 7, min: 60, km: 11),
      ],
    ),
    TrainingWeek(
      number: 8,
      focus: 'Semana da prova',
      notes: 'Pernas frescas. Foque em sono, hidratação e nutrição.',
      workouts: [
        WB.easy(planId: _id, week: 8, day: 2, min: 30, km: 5),
        WB.interval(
          planId: _id,
          week: 8,
          day: 4,
          min: 30,
          km: 5,
          structure: '10min aquec. + 4x (200m forte / 200m trote)',
        ),
        WB.recovery(planId: _id, week: 8, day: 6, min: 20, km: 3),
        WB.race(
          planId: _id,
          week: 8,
          day: 7,
          min: 28,
          km: 5,
          title: 'Prova: 5 km — busque o PR!',
          structure: 'Aquec. completo + 5 km no ritmo planejado',
        ),
      ],
    ),
  ],
);
