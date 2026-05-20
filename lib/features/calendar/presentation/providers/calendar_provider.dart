import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runner085/features/plans/domain/entities/workout.dart';

/// Provider for the selected date in the calendar.
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Provider for workouts on a specific date.
/// TODO: derive from the user's active plan when persistence is implemented.
final workoutsForDateProvider =
    FutureProvider.family<List<Workout>, DateTime>(
  (ref, date) async {
    return [];
  },
);
