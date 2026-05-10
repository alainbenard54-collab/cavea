// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'location_node.dart';

class LocationNodeTile extends StatelessWidget {
  final LocationNode node;
  final VoidCallback onTap;

  const LocationNodeTile({
    super.key,
    required this.node,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (count, sumPrix, nullPrixCount) = nodeStats(node, true); // toujours agréger
    final statsLabel = _statsLabel(count, sumPrix, nullPrixCount);
    final hasChildren = !node.isLeaf;

    return ListTile(
      leading: Icon(
        hasChildren ? Icons.folder_outlined : Icons.wine_bar_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(node.label),
      subtitle: Text(statsLabel),
      trailing: hasChildren ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }
}

String locationStatsLabel(int count, double? sumPrix, [int nullPrixCount = 0]) =>
    _statsLabel(count, sumPrix, nullPrixCount);

String _statsLabel(int count, double? sumPrix, [int nullPrixCount = 0]) {
  final bottles = '$count bouteille${count > 1 ? 's' : ''}';
  if (sumPrix == null || sumPrix <= 0) return bottles;
  final label = '$bottles (${sumPrix.round()} €)';
  if (nullPrixCount > 0) return '$label dont $nullPrixCount sans prix';
  return label;
}
