// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

// BulkAddScreen interroge le DAO réel dès initState() (suggestions
// d'autocomplétion), contrairement aux autres écrans testés — nécessite un
// AppDatabase.memory() (même pattern que la suite de tests DAO du projet),
// pas de vraies données ni de fichier persisté. Décision actée dans
// golden-tests-alchemist.

@Tags(['golden'])
library;

import 'package:alchemist/alchemist.dart';
import 'package:cavea/data/database.dart';
import 'package:cavea/data/providers.dart';
import 'package:cavea/features/bulk_add/bulk_add_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../golden_harness.dart';

void main() {
  final db = AppDatabase.memory();
  tearDownAll(() => db.close());

  goldenTest(
    'BulkAddScreen — état initial (avant saisie)',
    fileName: 'bulk_add_default',
    builder: () => GoldenTestGroup(
      columnWidthBuilder: (_) => const FixedColumnWidth(400),
      children: [
        GoldenTestScenario(
          name: 'état initial',
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 1700),
          child: wrapForGolden(
            const BulkAddScreen(),
            overrides: [
              appDatabaseProvider.overrideWithValue(db),
            ],
          ),
        ),
      ],
    ),
  );
}
