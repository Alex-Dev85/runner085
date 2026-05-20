import 'package:firebase_auth/firebase_auth.dart';

import 'package:runner085/core/domain/failures/app_failure.dart';
import 'package:runner085/core/utils/result.dart';

class FirebaseAuthDatasource {
  final FirebaseAuth _auth;

  FirebaseAuthDatasource({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<Result<UserCredential>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Result.success(credential);
    } on FirebaseAuthException catch (e) {
      return Result.failure(
        AppFailure.auth(message: _mapAuthError(e.code)),
      );
    } catch (e) {
      return Result.failure(
        AppFailure.unknown(message: e.toString()),
      );
    }
  }

  Future<Result<UserCredential>> signUpWithEmail(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Result.success(credential);
    } on FirebaseAuthException catch (e) {
      return Result.failure(
        AppFailure.auth(message: _mapAuthError(e.code)),
      );
    } catch (e) {
      return Result.failure(
        AppFailure.unknown(message: e.toString()),
      );
    }
  }

  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        const AppFailure.auth(message: 'Erro ao sair da conta'),
      );
    }
  }

  Future<Result<void>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      return Result.failure(
        AppFailure.auth(message: _mapAuthError(e.code)),
      );
    } catch (e) {
      return Result.failure(
        AppFailure.unknown(message: e.toString()),
      );
    }
  }

  String _mapAuthError(String code) => switch (code) {
        'user-not-found' => 'Usuário não encontrado',
        'wrong-password' => 'Senha incorreta',
        'email-already-in-use' => 'E-mail já está em uso',
        'weak-password' => 'Senha muito fraca',
        'invalid-email' => 'E-mail inválido',
        'user-disabled' => 'Conta desativada',
        'too-many-requests' => 'Muitas tentativas. Tente novamente mais tarde',
        'operation-not-allowed' => 'Operação não permitida',
        _ => 'Erro de autenticação: $code',
      };
}
