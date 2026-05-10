// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'location_node.dart';
import 'location_node_tile.dart';
import 'location_bottle_list_screen.dart';

class LocationNodeScreen extends StatelessWidget {
  final LocationNode node;

  const LocationNodeScreen({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          node.fullPath,
          style: const TextStyle(fontSize: 14),
        ),
      ),
      body: ListView(
        children: [
          // Sous-nœuds (avec stats agrégées)
          ...node.children.map(
            (child) => LocationNodeTile(
              node: child,
              onTap: () => _navigateTo(context, child),
            ),
          ),
          // Bouteilles directement dans ce nœud (si mix nœuds + bouteilles directes)
          if (node.directCount > 0) ...[
            if (node.children.isNotEmpty)
              const Divider(height: 1),
            _DirectBottlesTile(node: node),
          ],
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, LocationNode child) {
    if (child.isLeaf) {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          builder: (_) => LocationBottleListScreen(node: child),
        ),
      );
    } else {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          builder: (_) => LocationNodeScreen(node: child),
        ),
      );
    }
  }
}

class _DirectBottlesTile extends StatelessWidget {
  final LocationNode node;

  const _DirectBottlesTile({required this.node});

  @override
  Widget build(BuildContext context) {
    final count = node.directCount;
    final sumPrix = node.directSumPrix;
    final stats = locationStatsLabel(count, sumPrix);

    return ListTile(
      leading: Icon(
        Icons.wine_bar_outlined,
        color: Theme.of(context).colorScheme.secondary,
      ),
      title: Text('Directement dans cet emplacement'),
      subtitle: Text(stats),
      onTap: () => Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          builder: (_) => LocationBottleListScreen(node: node),
        ),
      ),
    );
  }
}
