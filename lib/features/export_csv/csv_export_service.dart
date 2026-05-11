// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import '../../data/database.dart';

const _bom = '﻿';

const _headers = [
  'id',
  'domaine',
  'appellation',
  'millesime',
  'couleur',
  'cru',
  'contenance',
  'emplacement',
  'date_entree',
  'date_sortie',
  'prix_achat',
  'garde_min',
  'garde_max',
  'commentaire_entree',
  'note_degus',
  'commentaire_degus',
  'fournisseur_nom',
  'fournisseur_infos',
  'producteur',
  'updated_at',
];

class CsvExportService {
  String buildCsv(List<Bouteille> bouteilles, {required String separator}) {
    final buf = StringBuffer(_bom);
    buf.writeln(_headers.join(separator));
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
