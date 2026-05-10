// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'location_node.dart';
import 'location_node_tile.dart';
import 'location_provider.dart';
import 'location_node_screen.dart';
import 'location_bottle_list_screen.dart';

class LocationTreeScreen extends ConsumerWidget {
  const LocationTreeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leavesAsync = ref.watch(locationLeavesProvider);
    final includeSublocations = ref.watch(includeSublocationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Emplacements')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            title: const Text('Inclure les sous-emplacements'),
            value: includeSublocations,
            onChanged: (v) =>
                ref.read(includeSublocationsProvider.notifier).state = v,
            dense: true,
          ),
          const Divider(height: 1),
          Expanded(
            child: leavesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Erreur : $e')),
              data: (leaves) {
                if (leaves.isEmpty) {
                  return const Center(
                    child: Text('Aucun emplacement trouvé.'),
                  );
                }
                final roots = buildTree(leaves);
                return ListView.builder(
                  itemCount: roots.length,
                  itemBuilder: (context, i) => LocationNodeTile(
                    node: roots[i],
                    includeSublocations: includeSublocations,
                    onTap: () => _onNodeTap(context, ref, roots[i], includeSublocations),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void _onNodeTap(
  BuildContext context,
  WidgetRef ref,
  LocationNode node,
  bool includeSublocations,
) {
  if (!includeSublocations && !node.isLeaf) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => LocationNodeScreen(node: node),
      ),
    );
  } else {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => LocationBottleListScreen(
          node: node,
          includeSublocations: includeSublocations && !node.isLeaf,
        ),
      ),
    );
  }
}

