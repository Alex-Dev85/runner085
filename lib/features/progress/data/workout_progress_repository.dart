import 'package:runner085/core/data/user_data/user_data_store.dart';

/// Progresso de treinos concluídos do usuário, no documento `progress`:
///
/// ```
/// {
///   completedDates: { workoutId: ISO-8601 },  // ids concluídos = chaves
///   totalMinutes:   int,
///   streakDays:     int,
///   lastDate:       ISO-8601 | null           // dia do último treino
/// }
/// ```
class WorkoutProgressRepository {
  static const doc = 'progress';

  final UserDataStore _store;

  WorkoutProgressRepository(this._store);

  // ── Leitura ────────────────────────────────────────────────────────────────

  Future<Set<String>> getCompletedIds() async =>
      (await getCompletedDates()).keys.toSet();

  /// Retorna mapa { workoutId → data de conclusão }.
  Future<Map<String, DateTime>> getCompletedDates() async {
    final data = await _store.read(doc);
    return _dates(data);
  }

  Future<int> getTotalMinutes() async =>
      ((await _store.read(doc))?['totalMinutes'] as num?)?.toInt() ?? 0;

  Future<int> getStreakDays() async =>
      ((await _store.read(doc))?['streakDays'] as num?)?.toInt() ?? 0;

  Future<DateTime?> getLastTrainingDate() async {
    final raw = (await _store.read(doc))?['lastDate'] as String?;
    return raw == null ? null : DateTime.tryParse(raw);
  }

  // ── Escrita ────────────────────────────────────────────────────────────────

  /// Marca um workout como concluído e atualiza streak + minutos.
  Future<void> markCompleted({
    required String workoutId,
    required int durationMinutes,
    required DateTime date,
  }) async {
    final data = await _store.read(doc);
    final dates = _dates(data);
    if (dates.containsKey(workoutId)) return; // idempotente
    dates[workoutId] = date;

    final total = ((data?['totalMinutes'] as num?)?.toInt() ?? 0) +
        durationMinutes;

    final today = _dateOnly(date);
    final lastRaw = data?['lastDate'] as String?;
    var streak = (data?['streakDays'] as num?)?.toInt() ?? 0;
    if (lastRaw == null) {
      streak = 1;
    } else {
      final diff = today.difference(_dateOnly(DateTime.parse(lastRaw))).inDays;
      if (diff == 1) {
        streak += 1;
      } else if (diff > 1) {
        streak = 1;
      }
      // diff == 0: mesmo dia, não altera streak
    }

    await _store.write(doc, {
      'completedDates': _encode(dates),
      'totalMinutes': total,
      'streakDays': streak,
      'lastDate': today.toIso8601String(),
    });
  }

  /// Remove a marcação de concluído de um workout (desfazer).
  Future<void> markUncompleted({
    required String workoutId,
    required int durationMinutes,
  }) async {
    final data = await _store.read(doc);
    final dates = _dates(data);
    if (!dates.containsKey(workoutId)) return;
    dates.remove(workoutId);

    final total = ((data?['totalMinutes'] as num?)?.toInt() ?? 0) -
        durationMinutes;

    await _store.write(doc, {
      ...?data,
      'completedDates': _encode(dates),
      'totalMinutes': total.clamp(0, 999999),
    });
  }

  /// Limpa todo o progresso (ao trocar de plano).
  Future<void> clearAll() => _store.delete(doc);

  static Map<String, DateTime> _dates(Map<String, dynamic>? data) {
    final raw = data?['completedDates'] as Map?;
    if (raw == null) return {};
    return raw.map(
      (k, v) => MapEntry(k as String, DateTime.parse(v as String)),
    );
  }

  static Map<String, String> _encode(Map<String, DateTime> dates) =>
      dates.map((k, v) => MapEntry(k, v.toIso8601String()));

  static DateTime _dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);
}
