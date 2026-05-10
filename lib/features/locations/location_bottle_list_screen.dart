// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/sync_service.dart';
import '../bottle_actions/bottle_actions_sheet.dart';
import '../stock/bouteille_list_tile.dart';
import '../stock/selection_controller.dart';
import '../stock/widgets/bulk_action_bar.dart';
import '../stock/widgets/consommer_batch_sheet.dart' show showConsommerBatchSheet;
import '../stock/widgets/deplacer_batch_sheet.dart' show showDeplacerBatchSheet;
import 'location_node.dart';
import 'location_provider.dart';

class LocationBottleListScreen extends ConsumerWidget {
  final LocationNode node;

  const LocationBottleListScreen({
    super.key,
    required this.node,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottlesAsync = ref.watch(locationBottleListProvider(node.fullPath));
    final selection = ref.watch(selectionProvider);
    final isReadOnly = ref.watch(syncServiceProvider) is SyncReadOnly;

    return Scaffold(
      appBar: AppBar(title: Text(node.label)),
      body: Column(
        children: [
          Expanded(
            child: bottlesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur : $e')),
              data: (bottles) {
                if (bottles.isEmpty) {
                  return const Center(
                    child: Text('Aucune bouteille dans cet emplacement.'),
                  );
                }
                return ListView.separated(
                  itemCount: bottles.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 16),
                  itemBuilder: (context, i) {
                    final b = bottles[i];
                    final isSelected = selection.selectedIds.contains(b.id);
                    return BouteilleListTile(
                      bouteille: b,
                      isSelectMode: selection.isSelectMode,
                      isSelected: isSelected,
                      onTap: selection.isSelectMode
                          ? () => ref
                              .read(selectionProvider.notifier)
                              .toggleId(b.id)
                          : () => showBottleActionsSheet(context, b),
                      onLongPress: isReadOnly
                          ? null
                          : () => ref
                              .read(selectionProvider.notifier)
                              .enterSelectMode(b.id),
                    );
                  },
                );
              },
            ),
          ),
          if (selection.isSelectMode)
            BulkActionBar(
              count: selection.count,
              onDeplacer: () => showDeplacerBatchSheet(
                context,
                List.of(selection.selectedIds),
                onDone: () => ref.read(selectionProvider.notifier).reset(),
              ),
              onConsommer: () => showConsommerBatchSheet(
                context,
                List.of(selection.selectedIds),
                onDone: () => ref.read(selectionProvider.notifier).reset(),
              ),
              onCancel: () => ref.read(selectionProvider.notifier).reset(),
            ),
        ],
      ),
    );
  }
}
