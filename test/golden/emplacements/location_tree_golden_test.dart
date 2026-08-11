// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:alchemist/alchemist.dart';
import 'package:cavea/features/locations/location_provider.dart';
import 'package:cavea/features/locations/location_tree_screen.dart';
import 'package:flutter/material.dart';

import '../golden_harness.dart';
import 'emplacements_golden_fixtures.dart';

void main() {
  goldenTest(
    'LocationTreeScreen — vue racine, nœud + feuille',
    fileName: 'location_tree_root',
    builder: () => GoldenTestGroup(
      columnWidthBuilder: (_) => const FixedColumnWidth(500),
      children: [
        GoldenTestScenario(
          name: 'vue racine',
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 300),
          child: wrapForGolden(
            const LocationTreeScreen(),
            overrides: [
              locationLeavesProvider.overrideWith(
                (ref) => Stream.value(locationsGoldenFixtures()),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
