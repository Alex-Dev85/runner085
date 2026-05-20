import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runner085/features/plans/data/datasources/local_plan_datasource.dart';
import 'package:runner085/features/plans/data/repositories/training_plan_repository_impl.dart';
import 'package:runner085/features/plans/domain/entities/training_plan.dart';
import 'package:runner085/features/plans/domain/enums/race_distance.dart';
import 'package:runner085/features/plans/domain/repositories/training_plan_repository.dart';
import 'package:runner085/features/plans/domain/usecases/get_plan_by_id_usecase.dart';
import 'package:runner085/features/plans/domain/usecases/get_plans_by_distance_usecase.dart';
import 'package:runner085/features/plans/domain/usecases/get_plans_usecase.dart';

// Datasource
final localPlanDatasourceProvider = Provider<LocalPlanDatasource>((ref) {
  return const LocalPlanDatasource();
});

// Repository
final trainingPlanRepositoryProvider =
    Provider<TrainingPlanRepository>((ref) {
  return TrainingPlanRepositoryImpl(ref.watch(localPlanDatasourceProvider));
});

// Usecases
final getPlansUsecaseProvider = Provider<GetPlansUsecase>((ref) {
  return GetPlansUsecase(ref.watch(trainingPlanRepositoryProvider));
});

final getPlanByIdUsecaseProvider = Provider<GetPlanByIdUsecase>((ref) {
  return GetPlanByIdUsecase(ref.watch(trainingPlanRepositoryProvider));
});

final getPlansByDistanceUsecaseProvider =
    Provider<GetPlansByDistanceUsecase>((ref) {
  return GetPlansByDistanceUsecase(ref.watch(trainingPlanRepositoryProvider));
});

// State providers consumed by UI
final plansProvider = FutureProvider<List<TrainingPlan>>((ref) {
  return ref.watch(getPlansUsecaseProvider)();
});

final planByIdProvider =
    FutureProvider.family<TrainingPlan?, String>((ref, id) {
  return ref.watch(getPlanByIdUsecaseProvider)(id);
});

final plansByDistanceProvider =
    FutureProvider.family<List<TrainingPlan>, RaceDistance>(
  (ref, distance) {
    return ref.watch(getPlansByDistanceUsecaseProvider)(distance);
  },
);

/// Currently selected distance filter on the plans list page.
final selectedDistanceFilterProvider = StateProvider<RaceDistance?>((ref) {
  return null;
});

/// Currently selected level filter on the plans list page.
final selectedLevelFilterProvider = StateProvider<RunnerLevel?>((ref) {
  return null;
});

/// Plans filtered by both distance and level filters.
final filteredPlansProvider = Provider<AsyncValue<List<TrainingPlan>>>((ref) {
  final plansAsync = ref.watch(plansProvider);
  final distance = ref.watch(selectedDistanceFilterProvider);
  final level = ref.watch(selectedLevelFilterProvider);

  return plansAsync.whenData((plans) {
    return plans.where((p) {
      final matchDistance = distance == null || p.distance == distance;
      final matchLevel = level == null || p.level == level;
      return matchDistance && matchLevel;
    }).toList();
  });
});
