import 'package:runner085/features/plans/data/datasources/mocks/plan_10km_advanced_mock.dart';
import 'package:runner085/features/plans/data/datasources/mocks/plan_10km_beginner_mock.dart';
import 'package:runner085/features/plans/data/datasources/mocks/plan_10km_intermediate_mock.dart';
import 'package:runner085/features/plans/data/datasources/mocks/plan_21km_advanced_mock.dart';
import 'package:runner085/features/plans/data/datasources/mocks/plan_21km_beginner_mock.dart';
import 'package:runner085/features/plans/data/datasources/mocks/plan_21km_intermediate_mock.dart';
import 'package:runner085/features/plans/data/datasources/mocks/plan_42km_advanced_mock.dart';
import 'package:runner085/features/plans/data/datasources/mocks/plan_42km_beginner_mock.dart';
import 'package:runner085/features/plans/data/datasources/mocks/plan_42km_intermediate_mock.dart';
import 'package:runner085/features/plans/data/datasources/mocks/plan_5km_advanced_mock.dart';
import 'package:runner085/features/plans/data/datasources/mocks/plan_5km_beginner_mock.dart';
import 'package:runner085/features/plans/data/datasources/mocks/plan_5km_intermediate_mock.dart';
import 'package:runner085/features/plans/domain/entities/training_plan.dart';

/// Local datasource that returns the full catalog of mock training plans.
/// All plans are always available regardless of the user's current level.
class LocalPlanDatasource {
  const LocalPlanDatasource();

  Future<List<TrainingPlan>> fetchAll() async {
    // Simulate small async delay so UI can show loading states.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return [
      // 5 km
      plan5kmBeginner,
      plan5kmIntermediate,
      plan5kmAdvanced,
      // 10 km
      plan10kmBeginner,
      plan10kmIntermediate,
      plan10kmAdvanced,
      // 21 km
      plan21kmBeginner,
      plan21kmIntermediate,
      plan21kmAdvanced,
      // 42 km
      plan42kmBeginner,
      plan42kmIntermediate,
      plan42kmAdvanced,
    ];
  }

  Future<TrainingPlan?> fetchById(String id) async {
    final plans = await fetchAll();
    try {
      return plans.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
