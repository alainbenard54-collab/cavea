// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/adaptive_layout.dart';
import 'stock_controller.dart';
import 'bouteille_list_tile.dart';
import 'stock_table.dart';

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  final _searchController = SearchController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reset() {
    _searchController.clear();
    ref.read(stockFilterProvider.notifier).reset();
  }

  void _clearTexte() {
    _searchController.clear();
    ref.read(stockFilterProvider.notifier).setTexte('');
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(stockFilterProvider);
    final ctrl = ref.read(stockFilterProvider.notifier);
    final stockAsync = ref.watch(stockProvider);
    final totalAsync = ref.watch(stockTotalCountProvider);
    final couleursAsync = ref.watch(couleursProvider);
    final appellationsAsync = ref.watch(appellationsProvider);
    final millesimesAsync = ref.watch(millesimesProvider);

    final desktop = isDesktop(context);

    return Column(
      children: [
        // Barre de recherche
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: SearchBar(
            controller: _searchController,
            hintText: 'Rechercher : domaine, appellation, millésime…',
            leading: const Icon(Icons.search),
            trailing: filters.texte.isNotEmpty
                ? [
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearTexte,
                    ),
                  ]
                : null,
            onChanged: ctrl.setTexte,
          ),
        ),
        // Filtres en cascade
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: _CascadeDropdown<String>(
                  hint: 'Couleur',
                  value: filters.couleur,
                  items: couleursAsync.valueOrNull ?? [],
                  onChanged: ctrl.setCouleur,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CascadeDropdown<String>(
                  hint: 'Appellation',
                  value: filters.appellation,
                  items: appellationsAsync.valueOrNull ?? [],
                  onChanged: ctrl.setAppellation,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _CascadeDropdown<int>(
                  hint: 'Millésime',
                  value: filters.millesime,
                  items: millesimesAsync.valueOrNull ?? [],
                  onChanged: ctrl.setMillesime,
                ),
              ),
            ],
          ),
        ),
        // Bouton reset + compteur
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: Row(
            children: [
              if (filters.hasActiveFilters)
                TextButton.icon(
                  icon: const Icon(Icons.filter_alt_off, size: 16),
                  label: const Text('Réinitialiser'),
                  onPressed: _reset,
                ),
              const Spacer(),
              stockAsync.when(
                data: (list) => totalAsync.maybeWhen(
                  data: (total) => Text(
                    filters.hasActiveFilters
                        ? '${list.length} / $total bouteilles'
                        : '${list.length} bouteille${list.length > 1 ? 's' : ''} en stock',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
                loading: () => const SizedBox.shrink(),
                error: (err, st) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        // Liste ou tableau selon la largeur
        Expanded(
          child: stockAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Erreur : $e')),
            data: (bouteilles) {
              if (bouteilles.isEmpty) {
                return _EmptyState(hasFilters: filters.hasActiveFilters);
              }
              if (desktop) {
                return StockTable(
                  bouteilles: bouteilles,
                  sortColumn: filters.sortColumn,
                  sortAscending: filters.sortAscending,
                  onSort: ctrl.setSort,
                );
              }
              return ListView.builder(
                itemCount: bouteilles.length,
                itemBuilder: (context, i) =>
                    BouteilleListTile(bouteille: bouteilles[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CascadeDropdown<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _CascadeDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // key force la reconstruction quand value change (cascade reset)
    return DropdownButtonFormField<T>(
      key: ValueKey(value),
      initialValue: value,
      decoration: InputDecoration(
        labelText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem<T>(value: null, child: const Text('Tous')),
        ...items.map(
          (item) => DropdownMenuItem<T>(
            value: item,
            child: Text(item.toString(), overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilters;

  const _EmptyState({required this.hasFilters});

  @override
  Widget build(BuildContext context) {
    if (hasFilters) {
      return const Center(
        child: Text('Aucune bouteille ne correspond aux filtres.'),
      );
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wine_bar_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Aucune bouteille en stock', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          FilledButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text('Importer un CSV'),
            onPressed: () => context.go('/import-csv'),
          ),
        ],
      ),
    );
  }
}
