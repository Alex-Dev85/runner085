import 'package:runner085/features/plans/domain/entities/training_plan.dart';

/// Repositório responsável por persistir e recuperar o plano ativo do usuário.
abstract class ActivePlanRepository {
  /// Retorna o id do plano ativo, ou null se nenhum estiver ativo.
  Future<String?> getActivePlanId();

  /// Retorna a data de início do plano ativo, ou null.
  Future<DateTime?> getStartDate();

  /// Persiste o plano ativo com a data de início.
  Future<void> setActivePlan(String planId, DateTime startDate);

  /// Remove o plano ativo.
  Future<void> clearActivePlan();
}
