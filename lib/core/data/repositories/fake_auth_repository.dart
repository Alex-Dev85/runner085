import 'dart:async';

import 'package:runner085/core/domain/entities/user_entity.dart';
import 'package:runner085/core/domain/repositories/auth_repository.dart';
import 'package:runner085/core/utils/result.dart';

/// In-memory fake auth repository used in demo mode (no Firebase).
/// Accepts any non-empty email/password pair.
class FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<UserEntity?>.broadcast();
  UserEntity? _currentUser;

  /// Como o Firebase Auth: cada novo ouvinte recebe primeiro o usuário
  /// atual e depois as mudanças. (Antes, quem assinava depois do login não
  /// recebia o usuário e ficava sem uid.)
  @override
  Stream<UserEntity?> get authStateChanges async* {
    yield _currentUser;
    yield* _controller.stream;
  }

  @override
  Future<UserEntity?> get currentUser async => _currentUser;

  @override
  Future<Result<UserEntity>> signInWithEmail(
    String email,
    String password,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final user = UserEntity(
      id: 'demo-${email.hashCode}',
      email: email,
      displayName: email.split('@').first,
      createdAt: DateTime.now(),
    );
    _currentUser = user;
    _controller.add(user);
    return Result.success(user);
  }

  @override
  Future<Result<UserEntity>> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final user = UserEntity(
      id: 'demo-${email.hashCode}',
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
    );
    _currentUser = user;
    _controller.add(user);
    return Result.success(user);
  }

  @override
  Future<Result<void>> signOut() async {
    _currentUser = null;
    _controller.add(null);
    return Result.success(null);
  }

  @override
  Future<Result<void>> resetPassword(String email) async {
    return Result.success(null);
  }
}
