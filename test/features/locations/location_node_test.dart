// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter_test/flutter_test.dart';
import 'package:cavea/data/daos/bouteille_dao.dart';
import 'package:cavea/features/locations/location_node.dart';

void main() {
  LocationLeaf _leaf(String emplacement, {int count = 1, double? sumPrix, int nullPrixCount = 0}) =>
      LocationLeaf(
        emplacement: emplacement,
        count: count,
        sumPrix: sumPrix,
        nullPrixCount: nullPrixCount,
      );

  // ── buildTree ─────────────────────────────────────────────────────────────

  group('buildTree', () {
    test('liste vide → résultat vide', () {
      expect(buildTree([]), isEmpty);
    });

    test('emplacement simple → 1 nœud racine avec directCount', () {
      // SQL renvoie 1 feuille unique par emplacement (GROUP BY)
      final nodes = buildTree([_leaf('Cave A', count: 2)]);

      expect(nodes.length, 1);
      expect(nodes.first.label, 'Cave A');
      expect(nodes.first.directCount, 2);
      expect(nodes.first.children, isEmpty);
    });

    test('hiérarchie 2 niveaux → nœud racine avec 2 enfants', () {
      final nodes = buildTree([
        _leaf('Cave A > Étagère 1', count: 2),
        _leaf('Cave A > Étagère 2', count: 3),
      ]);

      expect(nodes.length, 1);
      expect(nodes.first.label, 'Cave A');
      expect(nodes.first.children.length, 2);
      expect(nodes.first.directCount, 0);

      final labels = nodes.first.children.map((c) => c.label).toSet();
      expect(labels, {'Étagère 1', 'Étagère 2'});
    });

    test('mix direct + enfants → directCount correct', () {
      final nodes = buildTree([
        _leaf('Cave A', count: 1),
        _leaf('Cave A > Étagère 1', count: 2),
      ]);

      expect(nodes.length, 1);
      final cave = nodes.first;
      expect(cave.directCount, 1);
      expect(cave.children.length, 1);
      expect(cave.children.first.directCount, 2);
    });

    test('plusieurs nœuds racine → triés par label', () {
      final nodes = buildTree([
        _leaf('Cave Z', count: 1),
        _leaf('Cave A', count: 1),
      ]);

      expect(nodes.length, 2);
      expect(nodes.first.label, 'Cave A');
      expect(nodes.last.label, 'Cave Z');
    });
  });

  // ── nodeStats ─────────────────────────────────────────────────────────────

  group('nodeStats', () {
    test('includeChildren=false → stats directes uniquement', () {
      final parent = LocationNode(
        label: 'Cave A',
        fullPath: 'Cave A',
        children: [
          LocationNode(
            label: 'Étagère 1',
            fullPath: 'Cave A > Étagère 1',
            children: const [],
            directCount: 5,
            directSumPrix: 100.0,
          ),
        ],
        directCount: 1,
        directSumPrix: 20.0,
      );

      final (count, sumPrix, _) = nodeStats(parent, false);
      expect(count, 1);
      expect(sumPrix, 20.0);
    });

    test('includeChildren=true → agrège récursivement', () {
      final parent = LocationNode(
        label: 'Cave A',
        fullPath: 'Cave A',
        children: [
          LocationNode(
            label: 'Étagère 1',
            fullPath: 'Cave A > Étagère 1',
            children: const [],
            directCount: 2,
          ),
        ],
        directCount: 1,
      );

      final (count, _, __) = nodeStats(parent, true);
      expect(count, 3);
    });

    test('sumPrix agrégée correctement', () {
      final parent = LocationNode(
        label: 'Cave A',
        fullPath: 'Cave A',
        children: [
          LocationNode(
            label: 'Étagère 1',
            fullPath: 'Cave A > Étagère 1',
            children: const [],
            directCount: 1,
            directSumPrix: 5.0,
          ),
        ],
        directCount: 1,
        directSumPrix: 10.0,
      );

      final (_, sumPrix, __) = nodeStats(parent, true);
      expect(sumPrix, 15.0);
    });

    test('nullPrixCount agrégé correctement', () {
      final parent = LocationNode(
        label: 'Cave A',
        fullPath: 'Cave A',
        children: [
          LocationNode(
            label: 'Étagère 1',
            fullPath: 'Cave A > Étagère 1',
            children: const [],
            directCount: 2,
            directNullPrixCount: 2,
          ),
        ],
        directCount: 1,
        directNullPrixCount: 1,
      );

      final (_, __, nullCount) = nodeStats(parent, true);
      expect(nullCount, 3);
    });
  });
}
