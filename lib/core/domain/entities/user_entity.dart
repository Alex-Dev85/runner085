import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:runner085/features/plans/domain/enums/race_distance.dart';

part 'user_entity.freezed.dart';
part 'user_entity.g.dart';

@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String email,
    String? displayName,
    String? photoUrl,
    @Default(RunnerLevel.beginner) RunnerLevel level,
    @Default(0) int weeklyGoalKm,
    /// Distância-alvo que o usuário quer correr (usada para recomendação).
    RaceDistance? goalDistance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserEntity;

  factory UserEntity.fromJson(Map<String, dynamic> json) =>
      _$UserEntityFromJson(json);
}
