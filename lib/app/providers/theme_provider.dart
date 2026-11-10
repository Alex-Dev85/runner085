import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:runner085/core/utils/constants.dart';
import 'package:runner085/features/settings/data/user_settings_repository.dart';
import 'package:runner085/features/settings/presentation/providers/app_settings_provider.dart';

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

/// Tema do app.
///
/// A preferência pertence à conta (campo `themeMode` do documento
/// `settings`). Uma cópia fica no aparelho só para as telas que aparecem
/// antes do login (splash, login, cadastro), que abrem com o último tema
/// usado; ao entrar, vale o tema da conta.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  /// Último tema aplicado nesta execução: evita "piscar" ao trocar de conta.
  static ThemeMode? _lastApplied;

  /// Descarta carregamentos de uma conta anterior que terminem atrasados.
  int _generation = 0;

  @override
  ThemeMode build() {
    // watch: recarrega o tema ao trocar de conta.
    final repo = ref.watch(userSettingsRepositoryProvider);
    final generation = ++_generation;
    unawaited(_load(repo, generation));
    return _lastApplied ?? ThemeMode.system;
  }

  Future<void> _load(UserSettingsRepository repo, int generation) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = _parse(prefs.getString(AppConstants.keyThemeMode));
    final fromAccount = _parse((await repo.read())['themeMode'] as String?);
    if (generation != _generation) return;

    final mode = fromAccount ?? cached;
    if (mode != null) _apply(mode);
    if (fromAccount != null) {
      await prefs.setString(AppConstants.keyThemeMode, fromAccount.name);
    }
  }

  void setThemeMode(ThemeMode mode) {
    _generation++; // a escolha do usuário vence um carregamento em andamento
    _apply(mode);
    unawaited(_save(mode));
  }

  void toggleTheme() {
    setThemeMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  void _apply(ThemeMode mode) {
    _lastApplied = mode;
    state = mode;
  }

  Future<void> _save(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyThemeMode, mode.name);
    await ref.read(userSettingsRepositoryProvider).update({
      'themeMode': mode.name,
    });
  }

  static ThemeMode? _parse(String? name) {
    if (name == null) return null;
    for (final mode in ThemeMode.values) {
      if (mode.name == name) return mode;
    }
    return null;
  }
}
