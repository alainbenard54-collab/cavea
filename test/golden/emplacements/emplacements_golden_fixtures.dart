// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:cavea/data/daos/bouteille_dao.dart';

/// Jeu de données statique pour le golden test Emplacements : vue racine de
/// l'arbre avec un nœud à sous-emplacements ("Cave A", ≥2 niveaux de
/// hiérarchie) et un nœud feuille ("Cave B") — voir design.md du change
/// golden-tests-alchemist. Le mix « nœuds + bouteilles directes » (tuile
/// dédiée) n'est visible qu'après navigation dans un nœud, hors périmètre
/// de ce golden (vue racine uniquement, sans simulation de tap).
List<LocationLeaf> locationsGoldenFixtures() => const [
      LocationLeaf(
        emplacement: 'Cave A > Étagère 1',
        count: 3,
        sumPrix: 45.5,
      ),
      LocationLeaf(
        emplacement: 'Cave A > Étagère 2',
        count: 2,
        nullPrixCount: 2,
      ),
      LocationLeaf(
        emplacement: 'Cave B',
        count: 4,
        sumPrix: 88.0,
        nullPrixCount: 1,
      ),
    ];
