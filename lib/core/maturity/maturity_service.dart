// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

enum MaturityLevel { tropJeune, optimal, aBoireUrgent, sansDonnee }

MaturityLevel computeMaturity({
  required int millesime,
  required int? gardeMin,
  required int? gardeMax,
  int? annee,
}) {
  if (millesime <= 0 ||
      gardeMin == null ||
      gardeMax == null ||
      gardeMin == 0 ||
      gardeMax == 0) {
    return MaturityLevel.sansDonnee;
  }
  final age = (annee ?? DateTime.now().year) - millesime;
  if (age < gardeMin) return MaturityLevel.tropJeune;
  if (age > gardeMax) return MaturityLevel.aBoireUrgent;
  return MaturityLevel.optimal;
}

int maturitySortOrder(MaturityLevel level) => switch (level) {
      MaturityLevel.aBoireUrgent => 0,
      MaturityLevel.optimal => 1,
      MaturityLevel.tropJeune => 2,
      MaturityLevel.sansDonnee => 3,
    };

// Score secondaire dans chaque groupe : valeur plus haute = plus urgent
int urgencyScore({
  required int millesime,
  required int? gardeMin,
  required int? gardeMax,
  int? annee,
}) {
  if (millesime <= 0 || gardeMin == null || gardeMax == null) return 0;
  final age = (annee ?? DateTime.now().year) - millesime;
  final level = computeMaturity(
    millesime: millesime,
    gardeMin: gardeMin,
    gardeMax: gardeMax,
    annee: annee,
  );
  return switch (level) {
    MaturityLevel.aBoireUrgent => age - gardeMax,
    MaturityLevel.optimal => gardeMax - age, // plus proche de fin = score élevé
    MaturityLevel.tropJeune => gardeMin - age, // plus proche de maturité = score élevé
    MaturityLevel.sansDonnee => 0,
  };
}
