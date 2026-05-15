// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/config_service.dart';
import '../../core/locale_formatting.dart';
import '../../core/maturity/maturity_service.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../l10n/l10n.dart';

class BottleDetailScreen extends ConsumerWidget {
  final String id;

  const BottleDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(bottleByIdProvider(id));

    return async.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.ficheTitle)),
        body: Center(child: Text(l10n.errorGeneric(e.toString()))),
      ),
      data: (bouteille) {
        if (bouteille == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.ficheTitle)),
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
                  Text(l10n.ficheNotFound),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: Text(l10n.actionRetour),
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final b = bouteille;
    final consommee = b.dateSortie != null && b.dateSortie!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ficheTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(l10n.bulkAddSectionIdentite),
          _ReadField(label: l10n.fieldDomaine, value: b.domaine),
          const SizedBox(height: 10),
          _ReadField(label: l10n.fieldAppellation, value: b.appellation),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: _ReadField(
                label: l10n.fieldMillesime,
                value: b.millesime > 0 ? b.millesime.toString() : '',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ReadField(
                label: l10n.fieldCouleur,
                value: ConfigService.displayCouleur(b.couleur, locale),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _ReadField(label: l10n.fieldCru, value: b.cru ?? '')),
            const SizedBox(width: 10),
            Expanded(child: _ReadField(label: l10n.fieldContenance, value: b.contenance)),
          ]),
          const SizedBox(height: 16),

          _SectionHeader(l10n.fieldEmplacement),
          _ReadField(label: l10n.fieldEmplacement, value: b.emplacement),
          const SizedBox(height: 16),

          _SectionHeader(l10n.bulkAddSectionGarde),
          Row(children: [
            Expanded(
              child: _ReadField(
                label: l10n.bulkAddFieldGardeMin,
                value: b.gardeMin?.toString() ?? '',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ReadField(
                label: l10n.bulkAddFieldGardeMax,
                value: b.gardeMax?.toString() ?? '',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ReadField(
                label: l10n.bulkAddFieldPrix,
                value: b.prixAchat != null
                    ? formatNumber(b.prixAchat!, context, decimals: 2)
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

          _SectionHeader(l10n.bulkAddSectionFournisseur),
          _ReadField(label: l10n.bulkAddFieldFournisseur, value: b.fournisseurNom ?? ''),
          const SizedBox(height: 10),
          _ReadField(
            label: l10n.bulkAddFieldFournisseurInfos,
            value: b.fournisseurInfos ?? '',
            maxLines: 2,
          ),
          const SizedBox(height: 10),
          _ReadField(label: l10n.bulkAddFieldProducteur, value: b.producteur ?? ''),
          const SizedBox(height: 16),

          _SectionHeader(l10n.bulkAddSectionCommentaire),
          _ReadField(
            label: l10n.fieldCommentaireEntree,
            value: b.commentaireEntree ?? '',
            maxLines: 3,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today, size: 16),
            label: Text(l10n.bulkAddDateEntreeLabel(formatDateFromString(b.dateEntree, context))),
            onPressed: null,
            style: OutlinedButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
          const SizedBox(height: 24),

          // Consommation — uniquement si date_sortie renseignée
          if (consommee) ...[
            _SectionHeader(l10n.ficheConsommation),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text(
                l10n.consommerDateLabel(formatDateFromString(b.dateSortie, context)),
              ),
              onPressed: null,
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 10),
            _ReadField(
              label: l10n.ficheNote,
              value: b.noteDegus != null
                  ? formatNumber(b.noteDegus!, context, decimals: 1)
                  : '',
            ),
            const SizedBox(height: 10),
            _ReadField(
              label: l10n.ficheCommentaireDegus,
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
    final l10n = context.l10n;
    final level = computeMaturity(
      millesime: bouteille.millesime,
      gardeMin: bouteille.gardeMin,
      gardeMax: bouteille.gardeMax,
    );

    final (bgColor, textColor, label) = switch (level) {
      MaturityLevel.tropJeune => (
          Colors.blue.shade50,
          Colors.blue.shade800,
          l10n.maturityTropJeune,
        ),
      MaturityLevel.optimal => (
          Colors.green.shade50,
          Colors.green.shade800,
          l10n.maturityOptimal,
        ),
      MaturityLevel.aBoireUrgent => (
          Colors.red.shade50,
          Colors.red.shade800,
          l10n.maturityUrgentDetail,
        ),
      MaturityLevel.sansDonnee => (
          Colors.grey.shade100,
          Colors.grey.shade600,
          l10n.maturityInconnue,
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
