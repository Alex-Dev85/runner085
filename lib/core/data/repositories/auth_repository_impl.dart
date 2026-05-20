import 'package:runner085/core/data/datasources/firebase_auth_datasource.dart';
import 'package:runner085/core/data/datasources/firestore_datasource.dart';
import 'package:runner085/core/domain/entities/user_entity.dart';
import 'package:runner085/core/domain/failures/app_failure.dart';
import 'package:runner085/core/domain/repositories/auth_repository.dart';
import 'package:runner085/core/utils/result.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource _authDatasource;
  final FirestoreDatasource _firestoreDatasource;

  AuthRepositoryImpl({
    required FirebaseAuthDatasource authDatasource,
    required FirestoreDatasource firestoreDatasource,
  })  : _authDatasource = authDatasource,
        _firestoreDatasource = firestoreDatasource;

  @override
  Stream<UserEntity?> get authStateChanges {
    return _authDatasource.authStateChanges.asyncMap((user) async {
      if (user == null) return null;
      final result = await _firestoreDatasource.getDocument(
        _firestoreDatasource.usersRef,
        user.uid,
      );
      return result.when(
        success: (data) => UserEntity.fromJson(data),
        failure: (_) => UserEntity(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
        ),
      );
    });
  }

  @override
  Future<UserEntity?> get currentUser async {
    final user = _authDatasource.currentUser;
    if (user == null) return null;
    final result = await _firestoreDatasource.getDocument(
      _firestoreDatasource.usersRef,
      user.uid,
    );
    return result.when(
      success: (data) => UserEntity.fromJson(data),
      failure: (_) => UserEntity(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
      ),
    );
  }

  @override
  Future<Result<UserEntity>> signInWithEmail(
    String email,
    String password,
  ) async {
    final result = await _authDatasource.signInWithEmail(email, password);
    return result.when(
      success: (credential) async {
        final user = credential.user;
        if (user == null) {
          return Result.failure(
            const AppFailure.auth(message: 'Erro ao autenticar'),
          );
        }
        final docResult = await _firestoreDatasource.getDocument(
          _firestoreDatasource.usersRef,
          user.uid,
        );
        return docResult.when(
          success: (data) => Result.success(UserEntity.fromJson(data)),
          failure: (_) => Result.success(
            UserEntity(
              id: user.uid,
              email: user.email ?? '',
              displayName: user.displayName,
            ),
          ),
        );
      },
      failure: (failure) => Result.failure(failure),
    );
  }

  @override
  Future<Result<UserEntity>> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    final result = await _authDatasource.signUpWithEmail(email, password);
    return result.when(
      success: (credential) async {
        final user = credential.user;
        if (user == null) {
          return Result.failure(
            const AppFailure.auth(message: 'Erro ao criar conta'),
          );
        }

        await user.updateDisplayName(displayName);

        final userEntity = UserEntity(
          id: user.uid,
          email: email,
          displayName: displayName,
          createdAt: DateTime.now(),
        );

        await _firestoreDatasource.setDocument(
          _firestoreDatasource.usersRef,
          user.uid,
          userEntity.toJson(),
        );

        return Result.success(userEntity);
      },
      failure: (failure) => Result.failure(failure),
    );
  }

  @override
  Future<Result<void>> signOut() => _authDatasource.signOut();

  @override
  Future<Result<void>> resetPassword(String email) =>
      _authDatasource.resetPassword(email);
}
