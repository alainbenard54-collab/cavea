// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

// _BottleActionsSheet (le contenu réel du BottomSheet) est une classe privée
// de bottle_actions_sheet.dart, inaccessible depuis ce fichier de test — la
// seule API publique est showBottleActionsSheet(context, bouteille), qui
// déclenche un showModalBottomSheet. On simule donc un tap sur un bouton
// déclencheur via `whilePerforming` pour ouvrir le sheet avant la capture.

import 'package:alchemist/alchemist.dart';
import 'package:cavea/features/bottle_actions/bottle_actions_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../golden_harness.dart';
import 'bottle_detail_golden_fixtures.dart';

const _openSheetKey = Key('open-actions-sheet-golden');

Future<AsyncCallback?> _openSheet(WidgetTester tester) async {
  await tester.tap(find.byKey(_openSheetKey));
  await tester.pumpAndSettle();
  return null;
}

void main() {
  goldenTest(
    'BottleActionsSheet — mode normal',
    fileName: 'bottle_actions_sheet_default',
    whilePerforming: _openSheet,
    builder: () => GoldenTestGroup(
      scenarioConstraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
      // Sans largeur de colonne fixe, IntrinsicColumnWidth (le défaut)
      // dimensionne la colonne sur le petit bouton déclencheur avant tap —
      // le BottomSheet hérite ensuite de cette largeur minuscule une fois
      // ouvert (texte des libellés de menu qui passe sur 4 lignes).
      columnWidthBuilder: (_) => const FixedColumnWidth(400),
      children: [
        GoldenTestScenario(
          name: 'mode normal',
          child: wrapForGolden(
            Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  key: _openSheetKey,
                  onPressed: () => showBottleActionsSheet(
                    context,
                    bottleDetailGoldenEnStock,
                  ),
                  child: const Text('ouvrir'),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
