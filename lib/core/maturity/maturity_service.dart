// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

enum MaturityLevel { tropJeune, optimal, aBoireUrgent, sansDonnee }

MaturityLevel computeMaturity({
  required int millesime,
  required int? gardeMin,
  required int? gardeMax,
  int? annee,
}) {
  if (millesime <= 0 || gardeMin == null || gardeMax == null) {
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
  // Sémantique uniforme : score plus élevé = plus urgent → tri décroissant cohérent
  return switch (level) {
    MaturityLevel.aBoireUrgent => age - gardeMax,  // positif, plus grand = plus en retard
    MaturityLevel.optimal => age - gardeMax,       // négatif, moins négatif = moins de temps restant
    MaturityLevel.tropJeune => age - gardeMin,     // négatif, moins négatif = plus proche de maturité
    MaturityLevel.sansDonnee => 0,
  };
}
