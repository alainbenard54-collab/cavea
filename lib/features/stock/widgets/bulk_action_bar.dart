// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                    'Mode lecture seule',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              else
                Expanded(
                  child: Text(
                    '$count bouteille${count > 1 ? 's' : ''} sélectionnée${count > 1 ? 's' : ''}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              TextButton.icon(
                icon: const Icon(Icons.place_outlined, size: 18),
                label: const Text('Déplacer'),
                onPressed: isReadOnly ? null : onDeplacer,
              ),
              const SizedBox(width: 4),
              TextButton.icon(
                icon: const Icon(Icons.wine_bar_outlined, size: 18),
                label: const Text('Consommer'),
                onPressed: isReadOnly ? null : onConsommer,
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Annuler la sélection',
                onPressed: onCancel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
