import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runner085/app/bootstrap.dart';
import 'package:runner085/core/data/datasources/firebase_auth_datasource.dart';
import 'package:runner085/core/data/datasources/firestore_datasource.dart';
import 'package:runner085/core/data/repositories/auth_repository_impl.dart';
import 'package:runner085/core/data/repositories/fake_auth_repository.dart';
import 'package:runner085/core/domain/repositories/auth_repository.dart';

// Datasources
final firebaseAuthDatasourceProvider = Provider<FirebaseAuthDatasource>((ref) {
  return FirebaseAuthDatasource();
});

final firestoreDatasourceProvider = Provider<FirestoreDatasource>((ref) {
  return FirestoreDatasource();
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (AppBootstrap.demoMode) {
    return FakeAuthRepository();
  }
  return AuthRepositoryImpl(
    authDatasource: ref.watch(firebaseAuthDatasourceProvider),
    firestoreDatasource: ref.watch(firestoreDatasourceProvider),
  );
});
