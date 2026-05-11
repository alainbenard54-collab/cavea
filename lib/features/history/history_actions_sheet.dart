// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../services/sync_service.dart';

void showHistoryActionsSheet(BuildContext context, Bouteille bouteille) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => UncontrolledProviderScope(
      container: ProviderScope.containerOf(context),
      child: _HistoryActionsSheet(bouteille: bouteille),
    ),
  );
}

class _HistoryActionsSheet extends ConsumerWidget {
  final Bouteille bouteille;

  const _HistoryActionsSheet({required this.bouteille});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReadOnly = ref.watch(syncServiceProvider) is SyncReadOnly;
    final b = bouteille;

    String? dateSortieFormatted;
    final ds = b.dateSortie;
    if (ds != null && ds.isNotEmpty) {
      try {
        final d = DateTime.parse(ds);
        dateSortieFormatted =
            '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
      } catch (_) {
        dateSortieFormatted = ds;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête ───────────────────────────────────────────────────
          Text(
            b.domaine,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (b.appellation.isNotEmpty || b.millesime > 0) ...[
            const SizedBox(height: 2),
            Text(
              [
                if (b.appellation.isNotEmpty) b.appellation,
                if (b.millesime > 0) b.millesime.toString(),
              ].join(' · '),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // ── Détails consommation ───────────────────────────────────────
          _InfoRow(label: 'Couleur', value: b.couleur),
          if (b.emplacement.isNotEmpty)
            _InfoRow(label: 'Emplacement d\'origine', value: b.emplacement),
          if (dateSortieFormatted != null)
            _InfoRow(label: 'Date de consommation', value: dateSortieFormatted),
          if (b.noteDegus != null)
            _InfoRow(label: 'Note', value: '${b.noteDegus}/10'),
          if (b.commentaireDegus != null && b.commentaireDegus!.isNotEmpty)
            _InfoRow(label: 'Commentaire', value: b.commentaireDegus!),

          const SizedBox(height: 16),

          // ── Actions ───────────────────────────────────────────────────
          if (isReadOnly)
            const Text(
              'Mode lecture seule — modifications indisponibles',
              style: TextStyle(color: Colors.orange),
            )
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () => _confirmRehabiliter(context, ref),
                child: const Text('Réhabiliter (remettre en stock)'),
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/bottle/${b.id}');
              },
              child: const Text('Consulter la fiche'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRehabiliter(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Réhabiliter cette bouteille ?'),
        content: const Text(
          'La bouteille sera remise en stock à son emplacement d\'origine.\n\n'
          'La note et le commentaire de dégustation seront effacés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Réhabiliter'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref
          .read(bouteillesDaoProvider)
          .rehabiliterBouteille(bouteille.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
