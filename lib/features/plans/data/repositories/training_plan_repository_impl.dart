import 'package:runner085/features/plans/data/datasources/local_plan_datasource.dart';
import 'package:runner085/features/plans/domain/entities/training_plan.dart';
import 'package:runner085/features/plans/domain/enums/race_distance.dart';
import 'package:runner085/features/plans/domain/repositories/training_plan_repository.dart';

class TrainingPlanRepositoryImpl implements TrainingPlanRepository {
  final LocalPlanDatasource _datasource;

  const TrainingPlanRepositoryImpl(this._datasource);

  @override
  Future<List<TrainingPlan>> getAllPlans() => _datasource.fetchAll();

  @override
  Future<TrainingPlan?> getPlanById(String id) => _datasource.fetchById(id);

  @override
  Future<List<TrainingPlan>> getPlansByDistance(RaceDistance distance) async {
    final plans = await _datasource.fetchAll();
    return plans.where((p) => p.distance == distance).toList();
  }

  @override
  Future<List<TrainingPlan>> getPlansByLevel(RunnerLevel level) async {
    final plans = await _datasource.fetchAll();
    return plans.where((p) => p.level == level).toList();
  }
}
