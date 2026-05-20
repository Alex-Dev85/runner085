import 'package:runner085/features/plans/domain/entities/training_plan.dart';
import 'package:runner085/features/plans/domain/enums/race_distance.dart';
import 'package:runner085/features/plans/domain/repositories/training_plan_repository.dart';

class GetPlansByDistanceUsecase {
  final TrainingPlanRepository _repository;

  const GetPlansByDistanceUsecase(this._repository);

  Future<List<TrainingPlan>> call(RaceDistance distance) =>
      _repository.getPlansByDistance(distance);
}
