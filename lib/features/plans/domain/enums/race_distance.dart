enum RaceDistance {
  fiveKm,
  tenKm,
  halfMarathon,
  marathon;

  String get displayName => switch (this) {
        RaceDistance.fiveKm => '5 km',
        RaceDistance.tenKm => '10 km',
        RaceDistance.halfMarathon => '21 km',
        RaceDistance.marathon => '42 km',
      };

  String get fullName => switch (this) {
        RaceDistance.fiveKm => '5 quilômetros',
        RaceDistance.tenKm => '10 quilômetros',
        RaceDistance.halfMarathon => 'Meia Maratona',
        RaceDistance.marathon => 'Maratona',
      };

  double get km => switch (this) {
        RaceDistance.fiveKm => 5.0,
        RaceDistance.tenKm => 10.0,
        RaceDistance.halfMarathon => 21.0975,
        RaceDistance.marathon => 42.195,
      };
}

enum RunnerLevel {
  beginner,
  intermediate,
  advanced,
  elite;

  String get displayName => switch (this) {
        RunnerLevel.beginner => 'Iniciante',
        RunnerLevel.intermediate => 'Intermediário',
        RunnerLevel.advanced => 'Avançado',
        RunnerLevel.elite => 'Elite',
      };
}
