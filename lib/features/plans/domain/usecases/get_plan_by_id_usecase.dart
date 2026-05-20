import 'package:runner085/features/plans/domain/entities/training_plan.dart';
import 'package:runner085/features/plans/domain/repositories/training_plan_repository.dart';

class GetPlanByIdUsecase {
  final TrainingPlanRepository _repository;

  const GetPlanByIdUsecase(this._repository);

  Future<TrainingPlan?> call(String id) => _repository.getPlanById(id);
}
