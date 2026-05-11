// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/maturity/maturity_service.dart';
import '../../data/database.dart';
import '../../data/providers.dart';

class BottleDetailScreen extends ConsumerWidget {
  final String id;

  const BottleDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(bottleByIdProvider(id));

    return async.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Fiche bouteille')),
        body: Center(child: Text('Erreur : $e')),
      ),
      data: (bouteille) {
        if (bouteille == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Fiche bouteille')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.wine_bar_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  const Text('Bouteille introuvable.'),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Retour'),
                  ),
                ],
              ),
            ),
          );
        }
        return _DetailView(bouteille: bouteille);
      },
    );
  }
}

class _DetailView extends StatelessWidget {
  final Bouteille bouteille;

  const _DetailView({required this.bouteille});

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final b = bouteille;
    final consommee = b.dateSortie != null && b.dateSortie!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Fiche bouteille')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader('Identité'),
          _ReadField(label: 'Domaine', value: b.domaine),
          const SizedBox(height: 10),
          _ReadField(label: 'Appellation', value: b.appellation),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: _ReadField(
                label: 'Millésime',
                value: b.millesime > 0 ? b.millesime.toString() : '',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: _ReadField(label: 'Couleur', value: b.couleur)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _ReadField(label: 'Cru', value: b.cru ?? '')),
            const SizedBox(width: 10),
            Expanded(child: _ReadField(label: 'Contenance', value: b.contenance)),
          ]),
          const SizedBox(height: 16),

          _SectionHeader('Emplacement'),
          _ReadField(label: 'Emplacement', value: b.emplacement),
          const SizedBox(height: 16),

          _SectionHeader('Garde & prix'),
          Row(children: [
            Expanded(
              child: _ReadField(
                label: 'Garde min (ans)',
                value: b.gardeMin?.toString() ?? '',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ReadField(
                label: 'Garde max (ans)',
                value: b.gardeMax?.toString() ?? '',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ReadField(
                label: 'Prix achat (€)',
                value: b.prixAchat != null
                    ? b.prixAchat!.toStringAsFixed(2).replaceAll('.', ',')
                    : '',
              ),
            ),
          ]),
          const SizedBox(height: 10),
          if (b.dateSortie == null || b.dateSortie!.isEmpty) ...[
            _MaturityBadge(bouteille: b),
            const SizedBox(height: 16),
          ] else
            const SizedBox(height: 6),

          _SectionHeader('Fournisseur'),
          _ReadField(label: 'Nom fournisseur', value: b.fournisseurNom ?? ''),
          const SizedBox(height: 10),
          _ReadField(
            label: 'Infos fournisseur',
            value: b.fournisseurInfos ?? '',
            maxLines: 2,
          ),
          const SizedBox(height: 10),
          _ReadField(label: 'Producteur', value: b.producteur ?? ''),
          const SizedBox(height: 16),

          _SectionHeader('Commentaire & date'),
          _ReadField(
            label: "Commentaire d'entrée",
            value: b.commentaireEntree ?? '',
            maxLines: 3,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text("Date d'entrée : ${_formatDate(b.dateEntree)}"),
            onPressed: null,
            style: OutlinedButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 24),

          // Consommation — uniquement si date_sortie renseignée
          if (consommee) ...[
            _SectionHeader('Consommation'),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text(
                'Date de consommation : ${_formatDate(b.dateSortie)}',
              ),
              onPressed: null,
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 10),
            _ReadField(
              label: 'Note /10',
              value: b.noteDegus != null
                  ? b.noteDegus!.toStringAsFixed(1).replaceAll('.', ',')
                  : '',
            ),
            const SizedBox(height: 10),
            _ReadField(
              label: 'Commentaire de dégustation',
              value: b.commentaireDegus ?? '',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

// ── Widgets locaux ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

/// Champ texte en lecture seule avec la même apparence qu'un TextFormField
/// éditable — OutlineInputBorder préservé, aucune interaction possible.
class _ReadField extends StatelessWidget {
  final String label;
  final String value;
  final int maxLines;

  const _ReadField({
    required this.label,
    required this.value,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}

class _MaturityBadge extends StatelessWidget {
  final Bouteille bouteille;

  const _MaturityBadge({required this.bouteille});

  @override
  Widget build(BuildContext context) {
    final level = computeMaturity(
      millesime: bouteille.millesime,
      gardeMin: bouteille.gardeMin,
      gardeMax: bouteille.gardeMax,
    );

    final (bgColor, textColor, label) = switch (level) {
      MaturityLevel.tropJeune => (
          Colors.blue.shade50,
          Colors.blue.shade800,
          'Trop jeune',
        ),
      MaturityLevel.optimal => (
          Colors.green.shade50,
          Colors.green.shade800,
          'Optimal',
        ),
      MaturityLevel.aBoireUrgent => (
          Colors.red.shade50,
          Colors.red.shade800,
          'À boire — urgent',
        ),
      MaturityLevel.sansDonnee => (
          Colors.grey.shade100,
          Colors.grey.shade600,
          'Maturité inconnue',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.water_drop_outlined, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
