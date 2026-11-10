import 'package:firebase_auth/firebase_auth.dart';

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
    return _authDatasource.authStateChanges.asyncMap(
      (user) => user == null ? null : _loadUser(user),
    );
  }

  @override
  Future<UserEntity?> get currentUser async {
    final user = _authDatasource.currentUser;
    if (user == null) return null;
    return _loadUser(user);
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
        return Result.success(await _loadUser(user));
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

        final userEntity = UserEntity(
          id: user.uid,
          email: email,
          displayName: displayName,
          // Em UTC: serializa com "Z" e não depende do fuso do aparelho.
          createdAt: DateTime.now().toUtc(),
        );

        // A conta já existe no Auth; falhas aqui não devem bloquear o
        // cadastro (o perfil é recriado a partir do Auth no próximo login).
        try {
          await user.updateDisplayName(displayName);
        } catch (_) {}
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

  /// Busca o perfil em `users/{uid}`. Se o documento não existir, não puder
  /// ser lido ou estiver malformado, usa os dados básicos do Firebase Auth
  /// — o login nunca falha por causa do Firestore.
  Future<UserEntity> _loadUser(User user) async {
    final fallback = UserEntity(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
    final result = await _firestoreDatasource.getDocument(
      _firestoreDatasource.usersRef,
      user.uid,
    );
    return result.when(
      success: (data) {
        try {
          return UserEntity.fromJson({...data, 'id': user.uid});
        } catch (_) {
          return fallback;
        }
      },
      failure: (_) => fallback,
    );
  }
}
