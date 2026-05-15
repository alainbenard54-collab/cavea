// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import '../../core/locale_formatting.dart';
import '../../core/maturity/maturity_service.dart';
import '../../data/database.dart';
import '../../l10n/l10n.dart';
import '../bottle_actions/bottle_actions_sheet.dart';
import 'bouteille_list_tile.dart';

const _wCheckbox = 40.0;
const _wIcon = 44.0;
const _wMillesime = 68.0;
const _wGarde = 110.0;
const _wPrix = 76.0;

class StockTable extends StatelessWidget {
  final List<Bouteille> bouteilles;
  final String sortColumn;
  final bool sortAscending;
  final void Function(String column) onSort;
  final bool isSelectMode;
  final Set<String> selectedIds;
  final void Function(String id)? onToggleSelect;
  final void Function(String id)? onLongPressRow;

  const StockTable({
    super.key,
    required this.bouteilles,
    required this.sortColumn,
    required this.sortAscending,
    required this.onSort,
    this.isSelectMode = false,
    this.selectedIds = const {},
    this.onToggleSelect,
    this.onLongPressRow,
  });

  Widget _layout(List<Widget> cells, {bool withCheckbox = false}) {
    return Row(
      children: [
        if (withCheckbox) SizedBox(width: _wCheckbox, child: cells[0]),
        SizedBox(width: _wIcon, child: cells[withCheckbox ? 1 : 0]),
        Expanded(flex: 3, child: cells[withCheckbox ? 2 : 1]),
        Expanded(flex: 2, child: cells[withCheckbox ? 3 : 2]),
        SizedBox(width: _wMillesime, child: cells[withCheckbox ? 4 : 3]),
        Expanded(flex: 2, child: cells[withCheckbox ? 5 : 4]),
        SizedBox(width: _wGarde, child: cells[withCheckbox ? 6 : 5]),
        SizedBox(width: _wPrix, child: cells[withCheckbox ? 7 : 6]),
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
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: active
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
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

  Widget _gardeCell(BuildContext context, Bouteille b) {
    final l10n = context.l10n;
    final style = Theme.of(context).textTheme.bodySmall;

    if (b.gardeMin == null && b.gardeMax == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Text('—', style: style, textAlign: TextAlign.center),
      );
    }

    final from = b.gardeMin != null ? (b.millesime + b.gardeMin!).toString() : '?';
    final to = b.gardeMax != null ? (b.millesime + b.gardeMax!).toString() : '?';
    final gardeStr = '$from–$to';

    final level = computeMaturity(
      millesime: b.millesime,
      gardeMin: b.gardeMin,
      gardeMax: b.gardeMax,
    );

    final score = urgencyScore(
      millesime: b.millesime,
      gardeMin: b.gardeMin,
      gardeMax: b.gardeMax,
    );

    final absScore = score.abs();
    final yearsLeft = (b.gardeMax != null)
        ? (b.millesime + b.gardeMax! - DateTime.now().year)
        : 0;
    final yearsUntilReady = (b.gardeMin != null)
        ? (b.millesime + b.gardeMin! - DateTime.now().year)
        : 0;

    final (bgColor, deltaStr) = switch (level) {
      MaturityLevel.aBoireUrgent => (
          Colors.red.shade50,
          l10n.gardeDepasse(absScore),
        ),
      MaturityLevel.optimal => (
          Colors.green.shade50,
          l10n.gardeEncore(yearsLeft),
        ),
      MaturityLevel.tropJeune => (
          Colors.blue.shade50,
          l10n.gardeDans(yearsUntilReady),
        ),
      MaturityLevel.sansDonnee => (null, ''),
    };

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(gardeStr, style: style, textAlign: TextAlign.center),
          if (deltaStr.isNotEmpty)
            Text(
              deltaStr,
              style: style?.copyWith(fontSize: 10),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _dataRow(BuildContext context, Bouteille b) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall;
    final isSelected = selectedIds.contains(b.id);

    final cells = [
      if (isSelectMode)
        Checkbox(
          value: isSelected,
          onChanged: (_) => onToggleSelect?.call(b.id),
        ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Icon(Icons.wine_bar, color: couleurVin(b.couleur), size: 22),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Text(b.domaine, style: style, overflow: TextOverflow.ellipsis),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Text(b.appellation, style: style, overflow: TextOverflow.ellipsis),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Text(
          b.millesime > 0 ? b.millesime.toString() : '—',
          style: style,
          textAlign: TextAlign.center,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Text(b.emplacement, style: style, overflow: TextOverflow.ellipsis),
      ),
      _gardeCell(context, b),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        child: Text(
          formatCurrency(b.prixAchat, context),
          style: style,
          textAlign: TextAlign.right,
        ),
      ),
    ];

    final rowContent = _layout(cells, withCheckbox: isSelectMode);

    return InkWell(
      onTap: isSelectMode
          ? () => onToggleSelect?.call(b.id)
          : () => showBottleActionsSheet(context, b),
      onLongPress: isSelectMode ? null : () => onLongPressRow?.call(b.id),
      child: isSelected
          ? ColoredBox(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              child: rowContent,
            )
          : rowContent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final header = Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: _layout(
        [
          if (isSelectMode) const SizedBox(),
          const SizedBox(),
          _headerCell(context, l10n.tableHeaderDomaine, 'domaine'),
          _headerCell(context, l10n.tableHeaderAppellation, 'appellation'),
          _headerCell(context, l10n.tableHeaderMillesime, 'millesime', align: TextAlign.center),
          _headerCell(context, l10n.tableHeaderEmplacement, 'emplacement'),
          _headerCell(context, l10n.tableHeaderGarde, 'gardeMin', align: TextAlign.center),
          _headerCell(context, l10n.tableHeaderPrix, 'prixAchat', align: TextAlign.right),
        ],
        withCheckbox: isSelectMode,
      ),
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
