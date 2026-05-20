import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runner085/core/domain/entities/user_entity.dart';
import 'package:runner085/core/providers/core_providers.dart';
import 'package:runner085/core/utils/result.dart';

/// Watches the Firebase auth state as a stream
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return authRepo.authStateChanges;
});

/// Notifier for auth actions (sign in, sign up, sign out)
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserEntity?>>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<Result<UserEntity>> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    final result =
        await _ref.read(authRepositoryProvider).signInWithEmail(email, password);
    result.when(
      success: (user) => state = AsyncValue.data(user),
      failure: (failure) =>
          state = AsyncValue.error(failure, StackTrace.current),
    );
    return result;
  }

  Future<Result<UserEntity>> signUp(
    String email,
    String password,
    String displayName,
  ) async {
    state = const AsyncValue.loading();
    final result = await _ref
        .read(authRepositoryProvider)
        .signUpWithEmail(email, password, displayName);
    result.when(
      success: (user) => state = AsyncValue.data(user),
      failure: (failure) =>
          state = AsyncValue.error(failure, StackTrace.current),
    );
    return result;
  }

  Future<Result<void>> signOut() async {
    final result = await _ref.read(authRepositoryProvider).signOut();
    result.when(
      success: (_) => state = const AsyncValue.data(null),
      failure: (failure) =>
          state = AsyncValue.error(failure, StackTrace.current),
    );
    return result;
  }

  Future<Result<void>> resetPassword(String email) async {
    return _ref.read(authRepositoryProvider).resetPassword(email);
  }
}

/// Provider for the current user (convenience)
final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});
