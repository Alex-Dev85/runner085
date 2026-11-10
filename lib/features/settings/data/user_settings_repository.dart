import 'package:runner085/core/data/user_data/user_data_store.dart';

/// Preferências do usuário, no documento `settings`:
///
/// ```
/// {
///   distanceUnit:    DistanceUnit.name | null,
///   weeklyFrequency: int | null,          // null = sem preferência
///   themeMode:       ThemeMode.name | null
/// }
/// ```
///
/// Tema e configurações compartilham o documento; cada escrita altera só
/// os próprios campos.
class UserSettingsRepository {
  static const doc = 'settings';

  final UserDataStore _store;

  UserSettingsRepository(this._store);

  Future<Map<String, dynamic>> read() async =>
      await _store.read(doc) ?? const <String, dynamic>{};

  /// Atualiza os campos informados. Um valor `null` remove o campo.
  Future<void> update(Map<String, Object?> fields) async {
    final current = Map<String, dynamic>.of(await read());
    fields.forEach((key, value) {
      if (value == null) {
        current.remove(key);
      } else {
        current[key] = value;
      }
    });
    await _store.write(doc, current);
  }
}
