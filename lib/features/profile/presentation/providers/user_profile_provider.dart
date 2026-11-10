import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runner085/core/providers/user_data_providers.dart';
import 'package:runner085/features/auth/presentation/providers/auth_provider.dart';
import 'package:runner085/features/plans/domain/enums/race_distance.dart';
import 'package:runner085/features/profile/data/user_profile_repository.dart';

// ── Repositório ──────────────────────────────────────────────────────────────

/// Recriado quando a conta muda (depende do armazenamento do usuário).
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepository(ref.watch(userDataStoreProvider));
});

// ── Estado do perfil ─────────────────────────────────────────────────────────

class UserProfile {
  final RunnerLevel level;
  final RaceDistance? goalDistance;

  const UserProfile({
    required this.level,
    this.goalDistance,
  });

  UserProfile copyWith({
    RunnerLevel? level,
    RaceDistance? goalDistance,
  }) {
    return UserProfile(
      level: level ?? this.level,
      goalDistance: goalDistance ?? this.goalDistance,
    );
  }

  /// Perfil está completo quando nível e objetivo estão definidos.
  bool get isComplete => goalDistance != null;
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class UserProfileNotifier extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() async {
    // watch: recarrega o perfil ao trocar de conta.
    final repo = ref.watch(userProfileRepositoryProvider);

    // Tenta carregar o perfil salvo do usuário primeiro.
    final savedLevel = await repo.getLevel();
    final savedGoal = await repo.getGoalDistance();

    // Fallback: usa o nível do UserEntity autenticado.
    final authUser = ref.read(currentUserProvider);
    final level = savedLevel ?? authUser?.level ?? RunnerLevel.beginner;
    final goal = savedGoal ?? authUser?.goalDistance;

    return UserProfile(level: level, goalDistance: goal);
  }

  Future<void> updateLevel(RunnerLevel level) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await ref.read(userProfileRepositoryProvider).saveLevel(level);
    state = AsyncValue.data(current.copyWith(level: level));
  }

  Future<void> updateGoalDistance(RaceDistance distance) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await ref.read(userProfileRepositoryProvider).saveGoalDistance(distance);
    state = AsyncValue.data(current.copyWith(goalDistance: distance));
  }

  Future<void> updateProfile({
    required RunnerLevel level,
    required RaceDistance goalDistance,
  }) async {
    await ref.read(userProfileRepositoryProvider).saveProfile(
          level: level,
          goalDistance: goalDistance,
        );
    state = AsyncValue.data(
      UserProfile(level: level, goalDistance: goalDistance),
    );
  }
}

final userProfileProvider =
    AsyncNotifierProvider<UserProfileNotifier, UserProfile>(
  UserProfileNotifier.new,
);
