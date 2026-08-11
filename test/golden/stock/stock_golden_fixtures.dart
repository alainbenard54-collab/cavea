// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:cavea/data/database.dart';

/// Jeu de données statique pour les golden tests Stock : couvre les 4
/// niveaux de maturité (tropJeune/optimal/aBoireUrgent/sansDonnee) et
/// plusieurs couleurs — voir design.md du change golden-tests-alchemist.
List<Bouteille> stockGoldenFixtures() => const [
      // tropJeune : millésime récent, encore loin de gardeMin.
      Bouteille(
        id: 'golden-stock-1',
        domaine: "Château Margaux",
        appellation: 'Margaux',
        millesime: 2024,
        couleur: 'Rouge',
        contenance: '75 cl',
        emplacement: 'Cave A',
        dateEntree: '2026-01-01',
        prixAchat: 45.0,
        gardeMin: 10,
        gardeMax: 20,
        updatedAt: '2026-01-01T00:00:00Z',
      ),
      // optimal : âge compris entre gardeMin et gardeMax.
      Bouteille(
        id: 'golden-stock-2',
        domaine: 'Domaine Leflaive',
        appellation: 'Meursault',
        millesime: 2015,
        couleur: 'Blanc',
        contenance: '75 cl',
        emplacement: 'Cave A > Étagère 1',
        dateEntree: '2026-01-01',
        prixAchat: 38.5,
        gardeMin: 5,
        gardeMax: 15,
        updatedAt: '2026-01-01T00:00:00Z',
      ),
      // aBoireUrgent : âge dépassant largement gardeMax.
      Bouteille(
        id: 'golden-stock-3',
        domaine: "Château d'Yquem",
        appellation: 'Sauternes',
        millesime: 2000,
        couleur: 'Blanc liquoreux',
        contenance: '75 cl',
        emplacement: 'Cave B',
        dateEntree: '2026-01-01',
        prixAchat: 210.0,
        gardeMin: 5,
        gardeMax: 15,
        updatedAt: '2026-01-01T00:00:00Z',
      ),
      // sansDonnee : ni gardeMin ni gardeMax renseignés.
      Bouteille(
        id: 'golden-stock-4',
        domaine: 'Moët & Chandon',
        appellation: 'Champagne',
        millesime: 2020,
        couleur: 'Blanc effervescent',
        contenance: '75 cl',
        emplacement: 'Cave B > Étagère 2',
        dateEntree: '2026-01-01',
        updatedAt: '2026-01-01T00:00:00Z',
      ),
    ];
