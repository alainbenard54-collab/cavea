// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:alchemist/alchemist.dart';
import 'package:cavea/data/providers.dart';
import 'package:cavea/features/bottle_detail/bottle_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';

import '../golden_harness.dart';
import 'bottle_detail_golden_fixtures.dart';

void main() {
  goldenTest(
    'BottleDetailScreen — en stock et consommée',
    fileName: 'bottle_detail_default',
    builder: () => GoldenTestGroup(
      columns: 2,
      columnWidthBuilder: (_) => const FixedColumnWidth(400),
      children: [
        GoldenTestScenario(
          name: 'en stock',
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 1400),
          child: wrapForGolden(
            BottleDetailScreen(id: bottleDetailGoldenEnStock.id),
            overrides: [
              bottleByIdProvider(bottleDetailGoldenEnStock.id).overrideWith(
                (ref) => Stream.value(bottleDetailGoldenEnStock),
              ),
            ],
          ),
        ),
        GoldenTestScenario(
          name: 'consommée',
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 1400),
          child: wrapForGolden(
            BottleDetailScreen(id: bottleDetailGoldenConsommee.id),
            overrides: [
              bottleByIdProvider(bottleDetailGoldenConsommee.id).overrideWith(
                (ref) => Stream.value(bottleDetailGoldenConsommee),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
