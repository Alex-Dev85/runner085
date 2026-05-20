import 'package:runner085/core/domain/entities/user_progress_entity.dart';
import 'package:runner085/core/utils/result.dart';

abstract class UserProgressRepository {
  Future<Result<UserProgressEntity>> getProgress(String userId);
  Future<Result<void>> updateProgress(UserProgressEntity progress);
  Future<Result<void>> markSessionCompleted(
    String userId,
    String sessionId,
  );
  Stream<UserProgressEntity?> watchProgress(String userId);
}
