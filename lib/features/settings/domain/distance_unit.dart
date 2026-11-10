/// Unidade de medida usada para exibir distâncias no app.
///
/// Os planos são sempre armazenados em quilômetros; a conversão acontece
/// apenas na exibição.
enum DistanceUnit {
  kilometers,
  miles;

  static const double _milesPerKm = 0.621371;

  /// Abreviação exibida na UI.
  String get label => switch (this) {
        DistanceUnit.kilometers => 'km',
        DistanceUnit.miles => 'mi',
      };

  String get displayName => switch (this) {
        DistanceUnit.kilometers => 'Quilômetros',
        DistanceUnit.miles => 'Milhas',
      };

  /// Converte um valor em quilômetros para esta unidade.
  double fromKm(double km) => switch (this) {
        DistanceUnit.kilometers => km,
        DistanceUnit.miles => km * _milesPerKm,
      };

  /// Formata uma distância em km já convertida, com a abreviação.
  String format(double km, {int decimals = 1}) =>
      '${fromKm(km).toStringAsFixed(decimals)} $label';
}
