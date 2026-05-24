import 'package:runner085/features/plans/domain/entities/training_plan.dart';
import 'package:runner085/features/plans/domain/entities/workout.dart';

/// Representa o plano que o usuário ativou, com a data de início.
class ActivePlan {
  final TrainingPlan plan;
  final DateTime startDate;

  const ActivePlan({
    required this.plan,
    required this.startDate,
  });

  /// Retorna o treino agendado para [date], ou null se for dia de descanso
  /// ou se a data estiver fora do período do plano.
  Workout? workoutForDate(DateTime date) {
    final dayOffset = _daysBetween(startDate, date);
    if (dayOffset < 0) return null;

    final weekIndex = dayOffset ~/ 7;
    if (weekIndex >= plan.weeks.length) return null;

    final week = plan.weeks[weekIndex];
    // dayOfWeek no plano: 1=segunda … 7=domingo
    // weekday do DateTime: 1=segunda … 7=domingo (mesmo padrão)
    final dayOfWeek = date.weekday;

    try {
      return week.workouts.firstWhere(
        (w) => w.dayOfWeek == dayOfWeek && !w.isRest,
      );
    } catch (_) {
      return null;
    }
  }

  /// Retorna todos os dias que têm treino no período do plano.
  Set<DateTime> get trainingDays {
    final days = <DateTime>{};
    for (var weekIdx = 0; weekIdx < plan.weeks.length; weekIdx++) {
      final week = plan.weeks[weekIdx];
      for (final workout in week.workouts) {
        if (workout.isRest) continue;
        // Calcula a data real: startDate + semanas + ajuste de dia da semana
        final weekStart = startDate.add(Duration(days: weekIdx * 7));
        // Ajusta para o dia correto dentro da semana
        final diff = workout.dayOfWeek - weekStart.weekday;
        final trainingDate = weekStart.add(Duration(days: diff));
        days.add(_dateOnly(trainingDate));
      }
    }
    return days;
  }

  DateTime get endDate =>
      startDate.add(Duration(days: plan.durationWeeks * 7 - 1));

  static int _daysBetween(DateTime from, DateTime to) {
    final f = _dateOnly(from);
    final t = _dateOnly(to);
    return t.difference(f).inDays;
  }

  static DateTime _dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);
}
