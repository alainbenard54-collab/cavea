// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../l10n/l10n.dart';
import '../../services/sync_service.dart';
import '../import_csv/import_csv_screen.dart';
import 'export_csv_screen.dart';

class ImportExportScreen extends ConsumerWidget {
  const ImportExportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReadOnly = ref.watch(syncServiceProvider) is SyncReadOnly;

    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.donneesTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _SectionCard(
                title: l10n.importSectionTitle,
                icon: Icons.upload_file_outlined,
                child: ImportCsvContent(isReadOnly: isReadOnly),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: l10n.exportSectionTitle,
                icon: Icons.download_outlined,
                child: const ExportCsvScreen(),
              ),
              if (!isReadOnly) ...[
                const SizedBox(height: 24),
                _DangerZone(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DangerZone extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: cs.error.withAlpha(100)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Icon(Icons.warning_amber_outlined, size: 20, color: cs.error),
              const SizedBox(width: 8),
              Text(
                l10n.dangerZoneTitle,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: cs.error),
              ),
            ]),
            const SizedBox(height: 12),
            Text(l10n.resetDbDesc,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: Icon(Icons.delete_forever_outlined, color: cs.error),
              label:
                  Text(l10n.resetDbButton, style: TextStyle(color: cs.error)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: cs.error),
              ),
              onPressed: () => _confirmReset(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.resetDbDialogTitle),
        content: Text(l10n.resetDbDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionAnnuler),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.resetDbConfirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final dao = ref.read(bouteillesDaoProvider);
    await dao.deleteAll();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.resetDbSuccess)),
      );
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ]),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
