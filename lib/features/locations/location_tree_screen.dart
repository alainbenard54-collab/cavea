// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/l10n.dart';
import '../../services/sync_service.dart';
import '../bottle_actions/bottle_actions_sheet.dart';
import '../stock/bouteille_list_tile.dart';
import '../stock/selection_controller.dart';
import '../stock/widgets/bulk_action_bar.dart';
import '../stock/widgets/consommer_batch_sheet.dart' show showConsommerBatchSheet;
import '../stock/widgets/deplacer_batch_sheet.dart' show showDeplacerBatchSheet;
import '../../data/daos/bouteille_dao.dart' show LocationLeaf;
import 'location_node.dart';
import 'location_node_tile.dart';
import 'location_provider.dart';

class LocationTreeScreen extends ConsumerStatefulWidget {
  const LocationTreeScreen({super.key});

  @override
  ConsumerState<LocationTreeScreen> createState() => _LocationTreeScreenState();
}

class _LocationTreeScreenState extends ConsumerState<LocationTreeScreen> {
  // Chemin de navigation : liste de labels depuis la racine vers le nœud courant.
  final List<String> _path = [];
  // Affichage de la liste de bouteilles (feuille ou bouteilles directes d'un parent).
  bool _showingBottleList = false;
  // true = liste bouteilles directes d'un nœud parent (chemin inchangé au retour).
  bool _directOnly = false;

  bool get _canGoBack => _path.isNotEmpty || _showingBottleList;

  void _navigateToRoot() => setState(() {
        _path.clear();
        _showingBottleList = false;
        _directOnly = false;
      });

  void _navigateToLevel(int index) => setState(() {
        _path.removeRange(index + 1, _path.length);
        _showingBottleList = false;
        _directOnly = false;
      });

  void _goBack() {
    setState(() {
      if (_showingBottleList) {
        final wasDirectOnly = _directOnly;
        _showingBottleList = false;
        _directOnly = false;
        // Leaf : le label avait été ajouté au chemin → le retirer.
        if (!wasDirectOnly && _path.isNotEmpty) _path.removeLast();
      } else if (_path.isNotEmpty) {
        _path.removeLast();
      }
    });
  }

  void _enterNode(LocationNode node) =>
      setState(() {
        _path.add(node.label);
        _showingBottleList = false;
      });

  void _enterLeaf(LocationNode node) =>
      setState(() {
        _path.add(node.label);
        _showingBottleList = true;
        _directOnly = false;
      });

  void _enterDirect() =>
      setState(() {
        _showingBottleList = true;
        _directOnly = true;
      });

  /// Retrouve le nœud courant dans l'arbre reconstruit (données fraîches du stream).
  LocationNode? _findCurrentNode(List<LocationNode> roots) {
    if (_path.isEmpty) return null;
    var nodes = roots;
    LocationNode? current;
    for (final label in _path) {
      LocationNode? found;
      for (final n in nodes) {
        if (n.label == label) {
          found = n;
          break;
        }
      }
      if (found == null) return null;
      current = found;
      nodes = found.children;
    }
    return current;
  }

  @override
  Widget build(BuildContext context) {
    final leavesAsync = ref.watch(locationLeavesProvider);

    return PopScope(
      canPop: !_canGoBack,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _canGoBack) _goBack();
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: _canGoBack ? BackButton(onPressed: _goBack) : null,
          title: _buildBreadcrumb(context),
        ),
        body: leavesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(context.l10n.errorGeneric(e.toString()))),
          data: (leaves) => _buildContent(leaves),
        ),
      ),
    );
  }

  Widget _buildBreadcrumb(BuildContext context) {
    final mutedColor = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    const style = TextStyle(fontSize: 13);
    const sep = Text(' › ', style: TextStyle(fontSize: 13));

    Widget crumb(String label, VoidCallback? onTap) {
      final text = Text(
        label,
        style: style.copyWith(color: onTap != null ? mutedColor : null),
        overflow: TextOverflow.ellipsis,
      );
      if (onTap == null) return text;
      return GestureDetector(onTap: onTap, child: text);
    }

    final emplacementsLabel = context.l10n.navEmplacements;
    final items = <Widget>[];
    if (_path.isEmpty) {
      items.add(crumb(emplacementsLabel, null));
    } else {
      items.add(crumb(emplacementsLabel, _navigateToRoot));
      for (int i = 0; i < _path.length; i++) {
        items.add(sep);
        final isLast = i == _path.length - 1;
        items.add(crumb(
          _path[i],
          isLast ? null : () => _navigateToLevel(i),
        ));
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(mainAxisSize: MainAxisSize.min, children: items),
    );
  }

  Widget _buildContent(List<LocationLeaf> leaves) {
    final tree = buildTree(leaves);
    final currentNode = _findCurrentNode(tree);

    // Le nœud a disparu (déplacement total) → retour à la racine.
    if (_path.isNotEmpty && currentNode == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() { _path.clear(); _showingBottleList = false; });
      });
      return const Center(child: CircularProgressIndicator());
    }

    if (_showingBottleList) {
      return _BottleListBody(emplacement: currentNode?.fullPath ?? '');
    }

    final children = currentNode?.children ?? tree;
    final directCount = currentNode?.directCount ?? 0;
    final directSumPrix = currentNode?.directSumPrix;
    final directNullPrixCount = currentNode?.directNullPrixCount ?? 0;

    if (children.isEmpty && directCount == 0) {
      return Center(child: Text(context.l10n.locationsEmpty));
    }

    return ListView(
      children: [
        for (final child in children)
          LocationNodeTile(
            node: child,
            onTap: () => child.isLeaf ? _enterLeaf(child) : _enterNode(child),
          ),
        if (directCount > 0) ...[
          if (children.isNotEmpty) const Divider(height: 1),
          _DirectBottlesTile(
            count: directCount,
            sumPrix: directSumPrix,
            nullPrixCount: directNullPrixCount,
            onTap: _enterDirect,
          ),
        ],
      ],
    );
  }
}

// ── Tuile "Bouteilles directement dans ce nœud" ───────────────────────────────

class _DirectBottlesTile extends StatelessWidget {
  final int count;
  final double? sumPrix;
  final int nullPrixCount;
  final VoidCallback onTap;

  const _DirectBottlesTile({
    required this.count,
    this.sumPrix,
    this.nullPrixCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.wine_bar_outlined,
        color: Theme.of(context).colorScheme.secondary,
      ),
      title: Text(context.l10n.locationsDirect),
      subtitle: Text(locationStatsLabel(context, count, sumPrix, nullPrixCount)),
      onTap: onTap,
    );
  }
}

// ── Corps de la liste de bouteilles (inline, pas d'écran séparé) ─────────────

class _BottleListBody extends ConsumerWidget {
  final String emplacement;

  const _BottleListBody({required this.emplacement});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottlesAsync = ref.watch(locationBottleListProvider(emplacement));
    final selection = ref.watch(selectionProvider);
    final isReadOnly = ref.watch(syncServiceProvider) is SyncReadOnly;

    return Column(
      children: [
        Expanded(
          child: bottlesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(context.l10n.errorGeneric(e.toString()))),
            data: (bottles) {
              if (bottles.isEmpty) {
                return Center(child: Text(context.l10n.locationsEmpty));
              }
              return ListView.separated(
                itemCount: bottles.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
                itemBuilder: (context, i) {
                  final b = bottles[i];
                  final isSelected = selection.selectedIds.contains(b.id);
                  return BouteilleListTile(
                    bouteille: b,
                    showEmplacement: false,
                    isSelectMode: selection.isSelectMode,
                    isSelected: isSelected,
                    onTap: selection.isSelectMode
                        ? () =>
                            ref.read(selectionProvider.notifier).toggleId(b.id)
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
    );
  }
}
