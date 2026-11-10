import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Armazenamento de documentos de um único usuário.
///
/// Cada "documento" é um mapa JSON identificado por um nome curto
/// (`active_plan`, `progress`, `profile`, `pace_zones`). As implementações
/// garantem que usuários diferentes nunca enxerguem os dados uns dos outros.
abstract class UserDataStore {
  Future<Map<String, dynamic>?> read(String doc);

  /// Substitui o documento inteiro.
  Future<void> write(String doc, Map<String, dynamic> data);

  Future<void> delete(String doc);
}

/// Firestore: `users/{uid}/data/{doc}`.
///
/// Escritas são aplicadas no cache local na hora (o SDK as inclui nas
/// leituras seguintes) e sincronizadas em segundo plano. Por isso a escrita
/// não espera indefinidamente pelo servidor: offline, o app continua
/// respondendo e a sincronização acontece quando a conexão voltar.
class FirestoreUserDataStore implements UserDataStore {
  static const _serverAckTimeout = Duration(seconds: 4);

  final FirebaseFirestore _firestore;
  final String uid;

  FirestoreUserDataStore({required this.uid, FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _ref(String doc) =>
      _firestore.collection('users').doc(uid).collection('data').doc(doc);

  @override
  Future<Map<String, dynamic>?> read(String doc) async {
    final snapshot = await _ref(doc).get();
    return snapshot.data();
  }

  @override
  Future<void> write(String doc, Map<String, dynamic> data) =>
      _awaitBriefly(_ref(doc).set(data), 'write $doc');

  @override
  Future<void> delete(String doc) =>
      _awaitBriefly(_ref(doc).delete(), 'delete $doc');

  Future<void> _awaitBriefly(Future<void> op, String label) async {
    // Erros reais (ex.: permissão negada) são registrados mesmo depois do
    // timeout; o timeout só evita travar a UI sem conexão.
    unawaited(
      op.catchError((Object e) => debugPrint('UserDataStore $label: $e')),
    );
    try {
      await op.timeout(_serverAckTimeout);
    } on TimeoutException {
      // Fica na fila de sincronização do Firestore.
    } catch (_) {
      // Já registrado acima.
    }
  }
}

/// SharedPreferences com o uid na chave: `user_data/{uid}/{doc}`.
/// Usado no modo demo (sem Firebase).
class LocalUserDataStore implements UserDataStore {
  final String uid;

  LocalUserDataStore({required this.uid});

  String _key(String doc) => 'user_data/$uid/$doc';

  @override
  Future<Map<String, dynamic>?> read(String doc) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(doc));
    if (raw == null) return null;
    return (jsonDecode(raw) as Map).cast<String, dynamic>();
  }

  @override
  Future<void> write(String doc, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(doc), jsonEncode(data));
  }

  @override
  Future<void> delete(String doc) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(doc));
  }
}

/// Em memória: usado quando ninguém está logado e nos testes.
class InMemoryUserDataStore implements UserDataStore {
  final Map<String, Map<String, dynamic>> _docs = {};

  @override
  Future<Map<String, dynamic>?> read(String doc) async {
    final data = _docs[doc];
    return data == null ? null : Map.of(data);
  }

  @override
  Future<void> write(String doc, Map<String, dynamic> data) async {
    _docs[doc] = Map.of(data);
  }

  @override
  Future<void> delete(String doc) async {
    _docs.remove(doc);
  }
}
