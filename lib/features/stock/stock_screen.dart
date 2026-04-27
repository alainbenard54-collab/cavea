// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/maturity/maturity_service.dart';
import '../../services/sync_service.dart';
import '../../shared/adaptive_layout.dart' show isDesktop;
import '../bottle_actions/bottle_actions_sheet.dart';
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
  bool _filtersExpanded = false;

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


    // isDesktop() est basé sur la largeur (≥600dp). Un téléphone en paysage
    // dépasse ce seuil, donc !isDesktop() serait faux → on utilise Platform.isAndroid.
    final isLandscapeMobile = Platform.isAndroid &&
        MediaQuery.of(context).orientation == Orientation.landscape;

    // En paysage mobile, les filtres sont collapsés par défaut
    final showFilters = !isLandscapeMobile || _filtersExpanded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Barre de recherche (toujours visible)
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: SearchBar(
            controller: _searchController,
            hintText: 'Rechercher : domaine, appellation, millésime…',
            backgroundColor: filters.texte.isNotEmpty
                ? WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.primaryContainer,
                  )
                : null,
            side: filters.texte.isNotEmpty
                ? WidgetStatePropertyAll(
                    BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  )
                : null,
            textStyle: filters.texte.isNotEmpty
                ? WidgetStatePropertyAll(
                    TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  )
                : null,
            leading: Icon(
              Icons.search,
              color: filters.texte.isNotEmpty
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
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

        // En paysage mobile : toggle compact pour les filtres
        if (isLandscapeMobile)
          InkWell(
            onTap: () => setState(() => _filtersExpanded = !_filtersExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Icon(
                    _filtersExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: filters.hasActiveFilters
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    filters.hasActiveFilters ? 'Filtres actifs' : 'Filtres',
                    style: TextStyle(
                      fontSize: 12,
                      color: filters.hasActiveFilters
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                      fontWeight: filters.hasActiveFilters ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Filtre couleur multi-sélect
        if (showFilters) couleursAsync.maybeWhen(
          data: (couleurs) => couleurs.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: couleurs.map((c) {
                        final selected = filters.couleurs.contains(c);
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            label: Text(c),
                            selected: selected,
                            onSelected: (_) => ctrl.toggleCouleur(c),
                            visualDensity: VisualDensity.compact,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
          orElse: () => const SizedBox.shrink(),
        ),

        // Filtre maturité (multi-sélect)
        if (showFilters) Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _MaturityChip(
                  label: 'À boire urgent !',
                  color: Colors.red.shade100,
                  selectedColor: Colors.red.shade200,
                  selected: filters.maturites.contains(MaturityLevel.aBoireUrgent),
                  onTap: () => ctrl.toggleMaturite(MaturityLevel.aBoireUrgent),
                ),
                const SizedBox(width: 6),
                _MaturityChip(
                  label: 'À boire',
                  color: Colors.green.shade100,
                  selectedColor: Colors.green.shade200,
                  selected: filters.maturites.contains(MaturityLevel.optimal),
                  onTap: () => ctrl.toggleMaturite(MaturityLevel.optimal),
                ),
                const SizedBox(width: 6),
                _MaturityChip(
                  label: 'Trop jeune',
                  color: Colors.blue.shade100,
                  selectedColor: Colors.blue.shade200,
                  selected: filters.maturites.contains(MaturityLevel.tropJeune),
                  onTap: () => ctrl.toggleMaturite(MaturityLevel.tropJeune),
                ),
                const SizedBox(width: 6),
                _MaturityChip(
                  label: '?',
                  color: Colors.grey.shade200,
                  selectedColor: Colors.grey.shade400,
                  selected: filters.maturites.contains(MaturityLevel.sansDonnee),
                  onTap: () => ctrl.toggleMaturite(MaturityLevel.sansDonnee),
                ),
              ],
            ),
          ),
        ),

        // Filtres avancés repliables
        if (showFilters) Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: const Text(
                'Filtres avancés',
                style: TextStyle(fontSize: 13),
              ),
              tilePadding: const EdgeInsets.symmetric(horizontal: 4),
              childrenPadding: const EdgeInsets.fromLTRB(4, 10, 4, 4),
              children: [
                Row(
                  children: [
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
              ],
            ),
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

        // Liste ou tableau
        Expanded(
          child: stockAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Erreur : $e')),
            data: (bouteilles) {
              if (bouteilles.isEmpty) {
                return _EmptyState(
                  hasFilters: filters.hasActiveFilters,
                  isReadOnly: ref.watch(syncServiceProvider) is SyncReadOnly,
                );
              }
              return LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 640) {
                    return StockTable(
                      bouteilles: bouteilles,
                      sortColumn: filters.sortColumn,
                      sortAscending: filters.sortAscending,
                      onSort: ctrl.setSort,
                    );
                  }
                  return ListView.builder(
                    itemCount: bouteilles.length,
                    itemBuilder: (context, i) => BouteilleListTile(
                      bouteille: bouteilles[i],
                      onTap: () =>
                          showBottleActionsSheet(context, bouteilles[i]),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MaturityChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color selectedColor;
  final bool selected;
  final VoidCallback onTap;

  const _MaturityChip({
    required this.label,
    required this.color,
    required this.selectedColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      backgroundColor: color,
      selectedColor: selectedColor,
      onSelected: (_) => onTap(),
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
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
  final bool isReadOnly;

  const _EmptyState({required this.hasFilters, this.isReadOnly = false});

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
          if (!isReadOnly) ...[
            const SizedBox(height: 8),
            FilledButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Importer un CSV'),
              onPressed: () => context.go('/import-csv'),
            ),
          ],
        ],
      ),
    );
  }
}
