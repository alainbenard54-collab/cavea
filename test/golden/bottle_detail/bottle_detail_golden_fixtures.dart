// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:cavea/data/database.dart';

/// Bouteille en stock (date_sortie vide) — badge de maturité visible,
/// section Consommation masquée. Voir design.md du change
/// golden-tests-alchemist.
const bottleDetailGoldenEnStock = Bouteille(
  id: 'golden-detail-stock',
  domaine: 'Château Margaux',
  appellation: 'Margaux',
  millesime: 2015,
  couleur: 'Rouge',
  cru: 'Grand Cru Classé',
  contenance: '75 cl',
  emplacement: 'Cave A > Étagère 1',
  dateEntree: '2026-01-01',
  prixAchat: 45.0,
  gardeMin: 5,
  gardeMax: 15,
  commentaireEntree: 'Achat en primeur.',
  fournisseurNom: 'Vinatis',
  producteur: 'Château Margaux',
  updatedAt: '2026-01-01T00:00:00Z',
);

/// Bouteille consommée (date_sortie renseignée) — section Consommation
/// visible, badge de maturité masqué.
const bottleDetailGoldenConsommee = Bouteille(
  id: 'golden-detail-consommee',
  domaine: 'Domaine Leflaive',
  appellation: 'Meursault',
  millesime: 2012,
  couleur: 'Blanc',
  contenance: '75 cl',
  emplacement: 'Cave A > Étagère 1',
  dateEntree: '2026-01-01',
  dateSortie: '2026-06-15',
  prixAchat: 38.5,
  gardeMin: 5,
  gardeMax: 15,
  noteDegus: 8.5,
  commentaireDegus: 'Très belle minéralité, à refaire.',
  updatedAt: '2026-06-15T00:00:00Z',
);
