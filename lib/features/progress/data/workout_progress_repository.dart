import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persiste o progresso de treinos concluídos via SharedPreferences.
///
/// Estrutura salva:
///   - `progress_completed_ids`  → JSON list de workoutIds concluídos
///   - `progress_completed_dates`→ JSON map { workoutId: isoDate }
///   - `progress_total_minutes`  → int acumulado de minutos treinados
///   - `progress_streak_days`    → int de dias consecutivos
///   - `progress_last_date`      → ISO date do último treino concluído
class WorkoutProgressRepository {
  static const _keyCompletedIds = 'progress_completed_ids';
  static const _keyCompletedDates = 'progress_completed_dates';
  static const _keyTotalMinutes = 'progress_total_minutes';
  static const _keyStreakDays = 'progress_streak_days';
  static const _keyLastDate = 'progress_last_date';

  // ── Leitura ────────────────────────────────────────────────────────────────

  Future<Set<String>> getCompletedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyCompletedIds);
    if (raw == null) return {};
    final list = (jsonDecode(raw) as List).cast<String>();
    return list.toSet();
  }

  /// Retorna mapa { workoutId → data de conclusão }.
  Future<Map<String, DateTime>> getCompletedDates() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyCompletedDates);
    if (raw == null) return {};
    final map = (jsonDecode(raw) as Map).cast<String, String>();
    return map.map((k, v) => MapEntry(k, DateTime.parse(v)));
  }

  Future<int> getTotalMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTotalMinutes) ?? 0;
  }

  Future<int> getStreakDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyStreakDays) ?? 0;
  }

  Future<DateTime?> getLastTrainingDate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyLastDate);
    if (raw == null) return null;
    return DateTime.parse(raw);
  }

  // ── Escrita ────────────────────────────────────────────────────────────────

  /// Marca um workout como concluído e atualiza streak + minutos.
  Future<void> markCompleted({
    required String workoutId,
    required int durationMinutes,
    required DateTime date,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // IDs concluídos
    final ids = await getCompletedIds();
    if (ids.contains(workoutId)) return; // idempotente
    ids.add(workoutId);
    await prefs.setString(_keyCompletedIds, jsonEncode(ids.toList()));

    // Datas de conclusão
    final dates = await getCompletedDates();
    dates[workoutId] = date;
    await prefs.setString(
      _keyCompletedDates,
      jsonEncode(dates.map((k, v) => MapEntry(k, v.toIso8601String()))),
    );

    // Total de minutos
    final total = (prefs.getInt(_keyTotalMinutes) ?? 0) + durationMinutes;
    await prefs.setInt(_keyTotalMinutes, total);

    // Streak
    final lastRaw = prefs.getString(_keyLastDate);
    final today = _dateOnly(date);
    if (lastRaw != null) {
      final last = _dateOnly(DateTime.parse(lastRaw));
      final diff = today.difference(last).inDays;
      final streak = prefs.getInt(_keyStreakDays) ?? 0;
      if (diff == 1) {
        await prefs.setInt(_keyStreakDays, streak + 1);
      } else if (diff > 1) {
        await prefs.setInt(_keyStreakDays, 1);
      }
      // diff == 0: mesmo dia, não altera streak
    } else {
      await prefs.setInt(_keyStreakDays, 1);
    }
    await prefs.setString(_keyLastDate, today.toIso8601String());
  }

  /// Remove a marcação de concluído de um workout (desfazer).
  Future<void> markUncompleted({
    required String workoutId,
    required int durationMinutes,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final ids = await getCompletedIds();
    if (!ids.contains(workoutId)) return;
    ids.remove(workoutId);
    await prefs.setString(_keyCompletedIds, jsonEncode(ids.toList()));

    final dates = await getCompletedDates();
    dates.remove(workoutId);
    await prefs.setString(
      _keyCompletedDates,
      jsonEncode(dates.map((k, v) => MapEntry(k, v.toIso8601String()))),
    );

    final total = (prefs.getInt(_keyTotalMinutes) ?? 0) - durationMinutes;
    await prefs.setInt(_keyTotalMinutes, total.clamp(0, 999999));
  }

  /// Limpa todo o progresso (ao trocar de plano).
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCompletedIds);
    await prefs.remove(_keyCompletedDates);
    await prefs.remove(_keyTotalMinutes);
    await prefs.remove(_keyStreakDays);
    await prefs.remove(_keyLastDate);
  }

  static DateTime _dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);
}
