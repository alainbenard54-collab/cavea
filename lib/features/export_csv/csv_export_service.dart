// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import '../../data/database.dart';
import '../../l10n/app_localizations.dart';

const _bom = '﻿';

class CsvExportService {
  String buildCsv(
    List<Bouteille> bouteilles, {
    required String separator,
    required AppLocalizations l10n,
  }) {
    final headers = [
      l10n.csvHeaderId,
      l10n.csvHeaderDomaine,
      l10n.csvHeaderAppellation,
      l10n.csvHeaderMillesime,
      l10n.csvHeaderCouleur,
      l10n.csvHeaderCru,
      l10n.csvHeaderContenance,
      l10n.csvHeaderEmplacement,
      l10n.csvHeaderDateEntree,
      l10n.csvHeaderDateSortie,
      l10n.csvHeaderPrixAchat,
      l10n.csvHeaderGardeMin,
      l10n.csvHeaderGardeMax,
      l10n.csvHeaderCommentaireEntree,
      l10n.csvHeaderNoteDegus,
      l10n.csvHeaderCommentaireDegus,
      l10n.csvHeaderFournisseurNom,
      l10n.csvHeaderFournisseurInfos,
      l10n.csvHeaderProducteur,
      l10n.csvHeaderUpdatedAt,
    ];
    final buf = StringBuffer(_bom);
    buf.writeln(headers.join(separator));
    for (final b in bouteilles) {
      final row = [
        b.id,
        b.domaine,
        b.appellation,
        b.millesime.toString(),
        b.couleur,
        b.cru,
        b.contenance,
        b.emplacement,
        b.dateEntree,
        b.dateSortie,
        b.prixAchat?.toString(),
        b.gardeMin?.toString(),
        b.gardeMax?.toString(),
        b.commentaireEntree,
        b.noteDegus?.toString(),
        b.commentaireDegus,
        b.fournisseurNom,
        b.fournisseurInfos,
        b.producteur,
        b.updatedAt,
      ];
      buf.writeln(row.map((v) => _escape(v, separator)).join(separator));
    }
    return buf.toString();
  }

  String _escape(String? value, String separator) {
    if (value == null) return '';
    if (value.contains(separator) || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
