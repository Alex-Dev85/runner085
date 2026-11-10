import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:runner085/app/bootstrap.dart';
import 'package:runner085/core/data/user_data/legacy_device_data.dart';
import 'package:runner085/core/data/user_data/user_data_store.dart';
import 'package:runner085/features/auth/presentation/providers/auth_provider.dart';

/// uid do usuário logado. Só notifica quando o uid muda (não a cada
/// atualização do perfil).
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider.select((auth) => auth.valueOrNull?.id));
});

/// Armazenamento dos dados do usuário logado.
///
/// Tudo que depende dele (plano ativo, progresso, perfil, zonas) é
/// recriado quando a conta muda, então cada conta vê só os próprios dados.
final userDataStoreProvider = Provider<UserDataStore>((ref) {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return InMemoryUserDataStore();

  final store = AppBootstrap.demoMode
      ? LocalUserDataStore(uid: uid)
      : FirestoreUserDataStore(uid: uid);
  return MigratingUserDataStore(store);
});
