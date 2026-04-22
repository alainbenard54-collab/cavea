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
