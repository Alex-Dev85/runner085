import 'package:runner085/features/plans/domain/entities/training_plan.dart';
import 'package:runner085/features/plans/domain/repositories/training_plan_repository.dart';

class GetPlansUsecase {
  final TrainingPlanRepository _repository;

  const GetPlansUsecase(this._repository);

  Future<List<TrainingPlan>> call() => _repository.getAllPlans();
}
