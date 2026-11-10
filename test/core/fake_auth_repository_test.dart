import 'package:flutter_test/flutter_test.dart';

import 'package:runner085/core/data/repositories/fake_auth_repository.dart';

void main() {
  test('quem assina depois do login recebe o usuário atual', () async {
    final repo = FakeAuthRepository();
    await repo.signInWithEmail('ana@runner085.test', 'x');

    final first = await repo.authStateChanges.first;
    expect(first?.email, 'ana@runner085.test');
  });

  test('emite null ao sair', () async {
    final repo = FakeAuthRepository();
    await repo.signInWithEmail('ana@runner085.test', 'x');

    final events = <String?>[];
    final sub = repo.authStateChanges.listen((u) => events.add(u?.email));
    await Future<void>.delayed(Duration.zero);
    await repo.signOut();
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(events, ['ana@runner085.test', null]);
  });
}
