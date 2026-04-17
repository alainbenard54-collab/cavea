// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import '../../data/database.dart';
import 'bouteille_list_tile.dart';

// Largeurs fixes pour colonnes non-flexibles
const _wIcon = 44.0;
const _wMillesime = 68.0;
const _wGarde = 96.0;
const _wPrix = 76.0;

class StockTable extends StatelessWidget {
  final List<Bouteille> bouteilles;
  final String sortColumn;
  final bool sortAscending;
  final void Function(String column) onSort;

  const StockTable({
    super.key,
    required this.bouteilles,
    required this.sortColumn,
    required this.sortAscending,
    required this.onSort,
  });

  Widget _layout(List<Widget> cells) {
    return Row(
      children: [
        SizedBox(width: _wIcon, child: cells[0]),
        Expanded(flex: 3, child: cells[1]),
        Expanded(flex: 2, child: cells[2]),
        SizedBox(width: _wMillesime, child: cells[3]),
        Expanded(flex: 2, child: cells[4]),
        SizedBox(width: _wGarde, child: cells[5]),
        SizedBox(width: _wPrix, child: cells[6]),
      ],
    );
  }

  Widget _headerCell(
    BuildContext context,
    String label,
    String column, {
    TextAlign align = TextAlign.left,
  }) {
    final theme = Theme.of(context);
    final active = sortColumn == column;
    return InkWell(
      onTap: () => onSort(column),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Row(
          mainAxisAlignment: align == TextAlign.right
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: active
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (active) ...[
              const SizedBox(width: 2),
              Icon(
                sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12,
                color: theme.colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _dataRow(BuildContext context, Bouteille b) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall;

    String gardeStr() {
      if (b.gardeMin == null && b.gardeMax == null) return '—';
      final from =
          b.gardeMin != null ? (b.millesime + b.gardeMin!).toString() : '?';
      final to =
          b.gardeMax != null ? (b.millesime + b.gardeMax!).toString() : '?';
      return '$from–$to';
    }

    String prixStr() {
      if (b.prixAchat == null) return '—';
      return '${b.prixAchat!.toStringAsFixed(0)} €';
    }

    return InkWell(
      onTap: null, // futur : ouvrir la fiche
      child: _layout([
        // Icône couleur
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Icon(Icons.wine_bar, color: couleurVin(b.couleur), size: 22),
        ),
        // Domaine
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Text(b.domaine, style: style, overflow: TextOverflow.ellipsis),
        ),
        // Appellation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Text(
            b.appellation,
            style: style,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Millésime
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Text(
            b.millesime > 0 ? b.millesime.toString() : '—',
            style: style,
            textAlign: TextAlign.center,
          ),
        ),
        // Emplacement
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Text(
            b.emplacement,
            style: style,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Garde (années réelles)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Text(
            gardeStr(),
            style: style,
            textAlign: TextAlign.center,
          ),
        ),
        // Prix
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Text(
            prixStr(),
            style: style,
            textAlign: TextAlign.right,
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final header = Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: _layout([
        const SizedBox(),
        _headerCell(context, 'DOMAINE', 'domaine'),
        _headerCell(context, 'APPELLATION', 'appellation'),
        _headerCell(context, 'MILL.', 'millesime', align: TextAlign.center),
        _headerCell(context, 'EMPLACEMENT', 'emplacement'),
        _headerCell(context, 'GARDE', 'gardeMin', align: TextAlign.center),
        _headerCell(context, 'PRIX', 'prixAchat', align: TextAlign.right),
      ]),
    );

    return Column(
      children: [
        header,
        const Divider(height: 1, thickness: 1),
        Expanded(
          child: ListView.separated(
            itemCount: bouteilles.length,
            separatorBuilder: (_, i) => const Divider(height: 1),
            itemBuilder: (context, i) => _dataRow(context, bouteilles[i]),
          ),
        ),
      ],
    );
  }
}
