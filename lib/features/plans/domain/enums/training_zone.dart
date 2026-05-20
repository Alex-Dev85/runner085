import 'package:flutter/material.dart';

import 'package:runner085/app/theme/app_colors.dart';

/// Zonas de treinamento baseadas em frequência cardíaca máxima.
enum TrainingZone {
  z1,
  z2,
  z3,
  z4,
  z5;

  String get label => switch (this) {
        TrainingZone.z1 => 'Z1',
        TrainingZone.z2 => 'Z2',
        TrainingZone.z3 => 'Z3',
        TrainingZone.z4 => 'Z4',
        TrainingZone.z5 => 'Z5',
      };

  String get displayName => switch (this) {
        TrainingZone.z1 => 'Recuperação',
        TrainingZone.z2 => 'Aeróbico Leve',
        TrainingZone.z3 => 'Aeróbico Moderado',
        TrainingZone.z4 => 'Limiar Anaeróbico',
        TrainingZone.z5 => 'VO2 Máx',
      };

  String get hrRange => switch (this) {
        TrainingZone.z1 => '50-60% FCmáx',
        TrainingZone.z2 => '60-70% FCmáx',
        TrainingZone.z3 => '70-80% FCmáx',
        TrainingZone.z4 => '80-90% FCmáx',
        TrainingZone.z5 => '90-100% FCmáx',
      };

  String get description => switch (this) {
        TrainingZone.z1 =>
          'Esforço muito leve. Recuperação ativa, ideal entre treinos pesados.',
        TrainingZone.z2 =>
          'Esforço confortável. Base aeróbica, conversa fluida.',
        TrainingZone.z3 =>
          'Esforço moderado. Conversa em frases curtas.',
        TrainingZone.z4 =>
          'Desconfortável. Limiar entre aeróbico e anaeróbico.',
        TrainingZone.z5 =>
          'Esforço máximo. Tiros curtos, fôlego no limite.',
      };

  Color get color => switch (this) {
        TrainingZone.z1 => AppColors.zone1Recovery,
        TrainingZone.z2 => AppColors.zone2Easy,
        TrainingZone.z3 => AppColors.zone3Moderate,
        TrainingZone.z4 => AppColors.zone4Threshold,
        TrainingZone.z5 => AppColors.zone5Max,
      };
}
