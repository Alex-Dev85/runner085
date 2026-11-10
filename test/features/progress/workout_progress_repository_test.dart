import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:runner085/core/data/user_data/user_data_store.dart';
import 'package:runner085/features/progress/data/workout_progress_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WorkoutProgressRepository repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = WorkoutProgressRepository(LocalUserDataStore(uid: 'u1'));
  });

  test('começa vazio', () async {
    expect(await repo.getCompletedIds(), isEmpty);
    expect(await repo.getCompletedDates(), isEmpty);
    expect(await repo.getTotalMinutes(), 0);
    expect(await repo.getStreakDays(), 0);
    expect(await repo.getLastTrainingDate(), isNull);
  });

  test('markCompleted registra id, data, minutos e inicia a sequência',
      () async {
    await repo.markCompleted(
      workoutId: 'w1',
      durationMinutes: 30,
      date: DateTime(2026, 1, 5, 18, 30),
    );

    expect(await repo.getCompletedIds(), {'w1'});
    expect(
      (await repo.getCompletedDates())['w1'],
      DateTime(2026, 1, 5, 18, 30),
    );
    expect(await repo.getTotalMinutes(), 30);
    expect(await repo.getStreakDays(), 1);
    expect(await repo.getLastTrainingDate(), DateTime(2026, 1, 5));
  });

  test('markCompleted é idempotente para o mesmo treino', () async {
    await repo.markCompleted(
      workoutId: 'w1',
      durationMinutes: 30,
      date: DateTime(2026, 1, 5),
    );
    await repo.markCompleted(
      workoutId: 'w1',
      durationMinutes: 30,
      date: DateTime(2026, 1, 6),
    );

    expect(await repo.getCompletedIds(), {'w1'});
    expect(await repo.getTotalMinutes(), 30);
    expect(await repo.getStreakDays(), 1);
  });

  test('dias consecutivos aumentam a sequência', () async {
    await repo.markCompleted(
      workoutId: 'w1',
      durationMinutes: 30,
      date: DateTime(2026, 1, 5),
    );
    await repo.markCompleted(
      workoutId: 'w2',
      durationMinutes: 45,
      date: DateTime(2026, 1, 6),
    );

    expect(await repo.getStreakDays(), 2);
    expect(await repo.getTotalMinutes(), 75);
  });

  test('dois treinos no mesmo dia não alteram a sequência', () async {
    await repo.markCompleted(
      workoutId: 'w1',
      durationMinutes: 30,
      date: DateTime(2026, 1, 5, 8),
    );
    await repo.markCompleted(
      workoutId: 'w2',
      durationMinutes: 20,
      date: DateTime(2026, 1, 5, 19),
    );

    expect(await repo.getStreakDays(), 1);
    expect(await repo.getTotalMinutes(), 50);
  });

  test('um intervalo maior que um dia reinicia a sequência em 1', () async {
    await repo.markCompleted(
      workoutId: 'w1',
      durationMinutes: 30,
      date: DateTime(2026, 1, 5),
    );
    await repo.markCompleted(
      workoutId: 'w2',
      durationMinutes: 30,
      date: DateTime(2026, 1, 6),
    );
    await repo.markCompleted(
      workoutId: 'w3',
      durationMinutes: 30,
      date: DateTime(2026, 1, 9),
    );

    expect(await repo.getStreakDays(), 1);
    expect(await repo.getLastTrainingDate(), DateTime(2026, 1, 9));
  });

  test('markUncompleted remove o treino e desconta os minutos', () async {
    await repo.markCompleted(
      workoutId: 'w1',
      durationMinutes: 30,
      date: DateTime(2026, 1, 5),
    );
    await repo.markCompleted(
      workoutId: 'w2',
      durationMinutes: 45,
      date: DateTime(2026, 1, 6),
    );

    await repo.markUncompleted(workoutId: 'w1', durationMinutes: 30);

    expect(await repo.getCompletedIds(), {'w2'});
    expect((await repo.getCompletedDates()).containsKey('w1'), isFalse);
    expect(await repo.getTotalMinutes(), 45);
  });

  test('markUncompleted ignora treino que não estava concluído', () async {
    await repo.markCompleted(
      workoutId: 'w1',
      durationMinutes: 30,
      date: DateTime(2026, 1, 5),
    );

    await repo.markUncompleted(workoutId: 'outro', durationMinutes: 99);

    expect(await repo.getCompletedIds(), {'w1'});
    expect(await repo.getTotalMinutes(), 30);
  });

  test('clearAll apaga todo o progresso', () async {
    await repo.markCompleted(
      workoutId: 'w1',
      durationMinutes: 30,
      date: DateTime(2026, 1, 5),
    );

    await repo.clearAll();

    expect(await repo.getCompletedIds(), isEmpty);
    expect(await repo.getCompletedDates(), isEmpty);
    expect(await repo.getTotalMinutes(), 0);
    expect(await repo.getStreakDays(), 0);
    expect(await repo.getLastTrainingDate(), isNull);
  });
}
