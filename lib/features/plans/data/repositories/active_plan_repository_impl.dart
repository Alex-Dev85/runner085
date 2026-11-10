import 'package:runner085/core/data/user_data/user_data_store.dart';
import 'package:runner085/features/plans/domain/repositories/active_plan_repository.dart';

/// Plano ativo do usuário, no documento `active_plan`:
/// `{ planId: String, startDate: ISO-8601 }`.
class ActivePlanRepositoryImpl implements ActivePlanRepository {
  static const doc = 'active_plan';

  final UserDataStore _store;

  ActivePlanRepositoryImpl(this._store);

  @override
  Future<String?> getActivePlanId() async {
    final data = await _store.read(doc);
    return data?['planId'] as String?;
  }

  @override
  Future<DateTime?> getStartDate() async {
    final raw = (await _store.read(doc))?['startDate'] as String?;
    return raw == null ? null : DateTime.tryParse(raw);
  }

  @override
  Future<void> setActivePlan(String planId, DateTime startDate) {
    return _store.write(doc, {
      'planId': planId,
      'startDate': startDate.toIso8601String(),
    });
  }

  @override
  Future<void> clearActivePlan() => _store.delete(doc);
}
