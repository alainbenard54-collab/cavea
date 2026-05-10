// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import '../../data/daos/bouteille_dao.dart';

class LocationNode {
  final String label;
  final String fullPath;
  final List<LocationNode> children;
  final int directCount;
  final double? directSumPrix;

  const LocationNode({
    required this.label,
    required this.fullPath,
    required this.children,
    required this.directCount,
    this.directSumPrix,
  });

  bool get isLeaf => children.isEmpty;
}

/// Stats d'un nœud selon le toggle "Inclure sous-emplacements".
(int count, double? sumPrix) nodeStats(LocationNode node, bool includeChildren) {
  if (!includeChildren) return (node.directCount, node.directSumPrix);
  var count = node.directCount;
  double? sum = node.directSumPrix;
  for (final child in node.children) {
    final cs = nodeStats(child, true);
    count += cs.$1;
    final childSum = cs.$2;
    if (childSum != null) sum = (sum ?? 0) + childSum;
  }
  return (count, sum);
}

class _NodeBuilder {
  final String label;
  final String fullPath;
  int directCount = 0;
  double? directSumPrix;
  final List<_NodeBuilder> children = [];

  _NodeBuilder(this.label, this.fullPath);

  LocationNode build() {
    children.sort((a, b) => a.label.compareTo(b.label));
    return LocationNode(
      label: label,
      fullPath: fullPath,
      children: children.map((c) => c.build()).toList(),
      directCount: directCount,
      directSumPrix: directSumPrix,
    );
  }
}

/// Construit l'arbre hiérarchique depuis la liste plate des feuilles SQL.
List<LocationNode> buildTree(List<LocationLeaf> leaves) {
  final Map<String, _NodeBuilder> all = {};

  for (final leaf in leaves) {
    final parts = leaf.emplacement.split(' > ');
    for (int depth = 1; depth <= parts.length; depth++) {
      final path = parts.take(depth).join(' > ');
      all.putIfAbsent(path, () => _NodeBuilder(parts[depth - 1], path));
    }
    all[leaf.emplacement]!
      ..directCount = leaf.count
      ..directSumPrix = leaf.sumPrix;
  }

  // Câbler les enfants
  for (final entry in all.entries) {
    final parts = entry.key.split(' > ');
    if (parts.length > 1) {
      final parentPath = parts.take(parts.length - 1).join(' > ');
      final parent = all[parentPath]!;
      if (!parent.children.any((c) => c.fullPath == entry.key)) {
        parent.children.add(entry.value);
      }
    }
  }

  return all.entries
      .where((e) => !e.key.contains(' > '))
      .map((e) => e.value.build())
      .toList()
    ..sort((a, b) => a.label.compareTo(b.label));
}
