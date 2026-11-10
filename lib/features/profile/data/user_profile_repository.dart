import 'package:runner085/core/data/user_data/user_data_store.dart';
import 'package:runner085/features/plans/domain/enums/race_distance.dart';

/// Nível e objetivo do corredor, no documento `profile`:
/// `{ level: RunnerLevel.name, goalDistance: RaceDistance.name }`.
class UserProfileRepository {
  static const doc = 'profile';

  final UserDataStore _store;

  UserProfileRepository(this._store);

  Future<RunnerLevel?> getLevel() async {
    final value = (await _store.read(doc))?['level'] as String?;
    if (value == null) return null;
    return RunnerLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RunnerLevel.beginner,
    );
  }

  Future<RaceDistance?> getGoalDistance() async {
    final value = (await _store.read(doc))?['goalDistance'] as String?;
    if (value == null) return null;
    return RaceDistance.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RaceDistance.fiveKm,
    );
  }

  Future<void> saveLevel(RunnerLevel level) => _merge({'level': level.name});

  Future<void> saveGoalDistance(RaceDistance distance) =>
      _merge({'goalDistance': distance.name});

  Future<void> saveProfile({
    required RunnerLevel level,
    required RaceDistance goalDistance,
  }) =>
      _merge({'level': level.name, 'goalDistance': goalDistance.name});

  Future<void> _merge(Map<String, dynamic> fields) async {
    final current = await _store.read(doc) ?? const <String, dynamic>{};
    await _store.write(doc, {...current, ...fields});
  }
}
