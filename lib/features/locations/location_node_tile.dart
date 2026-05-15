// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';
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
    final (count, sumPrix, nullPrixCount) = nodeStats(node, true);
    final statsLabel = locationStatsLabel(context, count, sumPrix, nullPrixCount);
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

String locationStatsLabel(
  BuildContext context,
  int count,
  double? sumPrix, [
  int nullPrixCount = 0,
]) {
  final l10n = context.l10n;
  if (sumPrix == null || sumPrix <= 0) return l10n.locationsBouteilles(count);
  final label = l10n.locationsBouteillesAvecPrix(count, sumPrix.round());
  if (nullPrixCount > 0) return '$label${l10n.locationsSansPrix(nullPrixCount)}';
  return label;
}
