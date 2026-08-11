// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:alchemist/alchemist.dart';
import 'package:cavea/features/stock/stock_table.dart';
import 'package:flutter/material.dart';

import '../golden_harness.dart';
import 'stock_golden_fixtures.dart';

void _noopSort(String column) {}

void main() {
  goldenTest(
    'StockTable — vue desktop, 4 niveaux de maturité',
    fileName: 'stock_table_default',
    builder: () => GoldenTestGroup(
      // Voir stock_list_golden_test.dart : StockTable se termine aussi par
      // un ListView.separated, donc même besoin de largeur de colonne fixe.
      columnWidthBuilder: (_) => const FixedColumnWidth(900),
      children: [
        GoldenTestScenario(
          name: 'table desktop',
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 400),
          child: wrapForGolden(
            StockTable(
              bouteilles: stockGoldenFixtures(),
              sortColumn: 'domaine',
              sortAscending: true,
              onSort: _noopSort,
            ),
          ),
        ),
      ],
    ),
  );
}
