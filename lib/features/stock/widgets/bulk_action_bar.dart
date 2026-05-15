// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/l10n.dart';
import '../../../services/sync_service.dart';

class BulkActionBar extends ConsumerWidget {
  final int count;
  final VoidCallback onDeplacer;
  final VoidCallback onConsommer;
  final VoidCallback onCancel;

  const BulkActionBar({
    super.key,
    required this.count,
    required this.onDeplacer,
    required this.onConsommer,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isReadOnly = ref.watch(syncServiceProvider) is SyncReadOnly;

    return Material(
      elevation: 8,
      color: theme.colorScheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              if (isReadOnly)
                Expanded(
                  child: Text(
                    l10n.bulkReadOnly,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              else
                Expanded(
                  child: Text(
                    l10n.bulkSelectionCount(count),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              TextButton.icon(
                icon: const Icon(Icons.place_outlined, size: 18),
                label: Text(l10n.actionsDeplacer),
                onPressed: isReadOnly ? null : onDeplacer,
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                icon: const Icon(Icons.wine_bar_outlined, size: 18),
                label: Text(l10n.actionsConsommer),
                onPressed: isReadOnly ? null : onConsommer,
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: l10n.bulkAnnulerSelection,
                onPressed: onCancel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
