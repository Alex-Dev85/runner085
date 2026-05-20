import 'package:freezed_annotation/freezed_annotation.dart';

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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _UserEntity;

  factory UserEntity.fromJson(Map<String, dynamic> json) =>
      _$UserEntityFromJson(json);
}

enum RunnerLevel {
  beginner,
  intermediate,
  advanced,
  elite;

  String get displayName => switch (this) {
        RunnerLevel.beginner => 'Iniciante',
        RunnerLevel.intermediate => 'Intermediário',
        RunnerLevel.advanced => 'Avançado',
        RunnerLevel.elite => 'Elite',
      };
}
