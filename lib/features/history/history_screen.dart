// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/locale_formatting.dart';
import '../../data/database.dart';
import '../../l10n/l10n.dart';
import 'history_actions_sheet.dart';
import 'history_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final historyAsync = ref.watch(historyProvider);
    final query = ref.watch(historySearchProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.historyTitle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: SearchBar(
              controller: _searchController,
              hintText: l10n.historySearchHint,
              leading: const Icon(Icons.search),
              trailing: [
                if (query.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(historySearchProvider.notifier).state = '';
                    },
                  ),
              ],
              onChanged: (v) =>
                  ref.read(historySearchProvider.notifier).state = v,
            ),
          ),
          Expanded(
            child: historyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(l10n.errorGeneric(e.toString()))),
              data: (bottles) {
                final filtered = query.isEmpty
                    ? bottles
                    : bottles.where((b) {
                        final q = query.toLowerCase();
                        return b.domaine.toLowerCase().contains(q) ||
                            b.appellation.toLowerCase().contains(q);
                      }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      query.isEmpty
                          ? l10n.historyEmpty
                          : l10n.historyEmptySearch(query),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 16),
                  itemBuilder: (context, i) =>
                      _HistoryTile(bouteille: filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final Bouteille bouteille;
  const _HistoryTile({required this.bouteille});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final b = bouteille;

    final subtitleParts = [
      if (b.appellation.isNotEmpty) b.appellation,
      if (b.millesime > 0) b.millesime.toString(),
    ];

    final dateStr = formatDateFromString(b.dateSortie, context);
    final trailingText = dateStr.isNotEmpty ? dateStr : null;

    return ListTile(
      leading: Icon(
        Icons.wine_bar,
        color: theme.colorScheme.onSurfaceVariant,
        size: 28,
      ),
      title: Text(
        b.domaine,
        style: theme.textTheme.bodyMedium
            ?.copyWith(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitleParts.isNotEmpty
          ? Text(
              subtitleParts.join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (trailingText != null)
            Text(
              trailingText,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          if (b.noteDegus != null)
            Text(
              '${b.noteDegus}/10',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
      onTap: () => showHistoryActionsSheet(context, b),
    );
  }
}
