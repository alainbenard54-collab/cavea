// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'location_node.dart';
import 'location_node_tile.dart';
import 'location_provider.dart';
import 'location_bottle_list_screen.dart';

class LocationNodeScreen extends ConsumerWidget {
  final LocationNode node;

  const LocationNodeScreen({super.key, required this.node});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final includeSublocations = ref.watch(includeSublocationsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(node.label)),
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
            child: ListView.builder(
              itemCount: node.children.length,
              itemBuilder: (context, i) {
                final child = node.children[i];
                return LocationNodeTile(
                  node: child,
                  includeSublocations: includeSublocations,
                  onTap: () => _onChildTap(context, ref, child, includeSublocations),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onChildTap(
    BuildContext context,
    WidgetRef ref,
    LocationNode child,
    bool includeSublocations,
  ) {
    if (!includeSublocations && !child.isLeaf) {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          builder: (_) => LocationNodeScreen(node: child),
        ),
      );
    } else {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute<void>(
          builder: (_) => LocationBottleListScreen(
            node: child,
            includeSublocations: includeSublocations && !child.isLeaf,
          ),
        ),
      );
    }
  }
}
