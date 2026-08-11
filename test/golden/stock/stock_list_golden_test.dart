// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

// Golden test isolé sur la liste mobile (<640px) : reproduit uniquement le
// ListView.builder de bouteilles de stock_screen.dart (sans barre de
// recherche ni filtres) — décision actée dans golden-tests-alchemist,
// cohérente avec BouteilleListTile qui n'a aucune dépendance Riverpod.

@Tags(['golden'])
library;

import 'package:alchemist/alchemist.dart';
import 'package:cavea/features/stock/bouteille_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../golden_harness.dart';
import 'stock_golden_fixtures.dart';

void main() {
  goldenTest(
    'Liste mobile — BouteilleListTile, 4 niveaux de maturité',
    fileName: 'stock_list_mobile',
    builder: () => GoldenTestGroup(
      // IntrinsicColumnWidth (le défaut) ne sait pas calculer une largeur
      // intrinsèque pour un ListView (RenderViewport) : sans cette largeur
      // fixe, la colonne s'effondre à quelques pixels et casse le layout
      // interne de ListTile ("Trailing widget consumes the entire tile
      // width").
      columnWidthBuilder: (_) => const FixedColumnWidth(375),
      children: [
        GoldenTestScenario(
          name: 'liste mobile',
          constraints: const BoxConstraints(maxWidth: 375, maxHeight: 320),
          child: wrapForGolden(
            ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: stockGoldenFixtures().length,
              itemBuilder: (context, i) => BouteilleListTile(
                bouteille: stockGoldenFixtures()[i],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
