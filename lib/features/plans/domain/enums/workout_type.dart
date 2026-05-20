/// Tipos de treino de corrida.
enum WorkoutType {
  rest,
  easy,
  recovery,
  longRun,
  tempo,
  interval,
  fartlek,
  hillRepeat,
  raceSimulation;

  String get displayName => switch (this) {
        WorkoutType.rest => 'Descanso',
        WorkoutType.easy => 'Corrida Leve',
        WorkoutType.recovery => 'Recuperação',
        WorkoutType.longRun => 'Longão',
        WorkoutType.tempo => 'Tempo Run',
        WorkoutType.interval => 'Intervalado',
        WorkoutType.fartlek => 'Fartlek',
        WorkoutType.hillRepeat => 'Subidas',
        WorkoutType.raceSimulation => 'Simulado',
      };

  String get description => switch (this) {
        WorkoutType.rest =>
          'Dia de repouso completo. Aproveite para alongar e dormir bem.',
        WorkoutType.easy =>
          'Corrida em ritmo confortável, conversável. Foco na resistência aeróbica.',
        WorkoutType.recovery =>
          'Trote bem leve para recuperar do treino anterior.',
        WorkoutType.longRun =>
          'Corrida longa em ritmo confortável. Constrói resistência específica para a prova.',
        WorkoutType.tempo =>
          'Corrida em ritmo "confortavelmente difícil", próximo ao limiar anaeróbico.',
        WorkoutType.interval =>
          'Tiros curtos e rápidos com recuperação entre eles. Melhora VO2 máx.',
        WorkoutType.fartlek =>
          'Brincadeira com ritmo: alterne acelerações e trotes conforme o terreno.',
        WorkoutType.hillRepeat =>
          'Repetições em subida para ganhar força e potência.',
        WorkoutType.raceSimulation =>
          'Treino simulando o ritmo e condições da prova alvo.',
      };
}
