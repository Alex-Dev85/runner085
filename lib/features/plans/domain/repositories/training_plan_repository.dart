import 'package:runner085/features/plans/domain/entities/training_plan.dart';
import 'package:runner085/features/plans/domain/enums/race_distance.dart';

abstract class TrainingPlanRepository {
  Future<List<TrainingPlan>> getAllPlans();
  Future<TrainingPlan?> getPlanById(String id);
  Future<List<TrainingPlan>> getPlansByDistance(RaceDistance distance);
  Future<List<TrainingPlan>> getPlansByLevel(RunnerLevel level);
}
