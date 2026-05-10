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
    final (count, sumPrix) = nodeStats(node, true); // toujours agréger
    final statsLabel = _statsLabel(count, sumPrix);
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

String locationStatsLabel(int count, double? sumPrix) => _statsLabel(count, sumPrix);

String _statsLabel(int count, double? sumPrix) {
  final bottles = '$count bouteille${count > 1 ? 's' : ''}';
  if (sumPrix == null || sumPrix <= 0) return bottles;
  return '$bottles (${sumPrix.round()} €)';
}
