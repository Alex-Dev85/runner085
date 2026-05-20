import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runner085/features/plans/domain/entities/workout.dart';
import 'package:runner085/features/plans/domain/enums/training_zone.dart';

/// Provider for the currently active workout (selected in detail page).
final activeWorkoutProvider = StateProvider<Workout?>((ref) => null);

/// Provider for the selected training zone filter.
final selectedZoneProvider = StateProvider<TrainingZone?>((ref) => null);

/// Provider for today's scheduled workouts.
/// TODO: derive from the user's active plan when persistence is implemented.
final todayWorkoutsProvider = FutureProvider<List<Workout>>((ref) async {
  return [];
});
