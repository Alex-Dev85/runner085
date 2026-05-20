import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_progress_entity.freezed.dart';
part 'user_progress_entity.g.dart';

@freezed
class UserProgressEntity with _$UserProgressEntity {
  const factory UserProgressEntity({
    required String userId,
    required String planId,
    required int currentWeek,
    required int totalWeeks,
    @Default(0) int completedSessions,
    @Default(0) int totalSessions,
    @Default(0) int totalMinutesTrained,
    @Default(0) int streakDays,
    DateTime? startDate,
    DateTime? lastTrainingDate,
  }) = _UserProgressEntity;

  factory UserProgressEntity.fromJson(Map<String, dynamic> json) =>
      _$UserProgressEntityFromJson(json);

  const UserProgressEntity._();

  double get completionPercentage =>
      totalSessions > 0 ? (completedSessions / totalSessions) * 100 : 0;

  bool get isCompleted => completedSessions >= totalSessions;
}
