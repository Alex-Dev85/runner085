import 'package:runner085/core/domain/entities/user_entity.dart';
import 'package:runner085/core/utils/result.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  Future<UserEntity?> get currentUser;
  Future<Result<UserEntity>> signInWithEmail(String email, String password);
  Future<Result<UserEntity>> signUpWithEmail(
    String email,
    String password,
    String displayName,
  );
  Future<Result<void>> signOut();
  Future<Result<void>> resetPassword(String email);
}
