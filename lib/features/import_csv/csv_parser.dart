// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../data/tables/bouteilles.dart';

const _uuid = Uuid();

class ParseResult {
  final List<BouteillesCompanion> companions;
  final int errorCount;

  const ParseResult({required this.companions, required this.errorCount});
}

ParseResult parseCsv(String content) {
  final lines = content.split('\n');
  if (lines.isEmpty) return const ParseResult(companions: [], errorCount: 0);

  // Lire les en-têtes (1ère ligne)
  final headers = lines.first
      .trim()
      .split(';')
      .map((h) => h.trim().toLowerCase())
      .toList();

  final companions = <BouteillesCompanion>[];
  var errorCount = 0;

  for (final rawLine in lines.skip(1)) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;

    try {
      final values = line.split(';');
      final row = <String, String>{};
      for (var i = 0; i < headers.length && i < values.length; i++) {
        row[headers[i]] = values[i].trim();
      }

      final companion = _rowToCompanion(row);
      if (companion != null) {
        companions.add(companion);
      } else {
        errorCount++;
      }
    } catch (_) {
      errorCount++;
    }
  }

  return ParseResult(companions: companions, errorCount: errorCount);
}

BouteillesCompanion? _rowToCompanion(Map<String, String> row) {
  // Champs obligatoires
  final domaine = row['domaine'];
  final appellation = row['appellation'];
  final millesimeStr = row['millesime'];
  final couleur = row['couleur'];

  if (domaine == null || domaine.isEmpty) return null;
  if (appellation == null || appellation.isEmpty) return null;
  final millesime = int.tryParse(millesimeStr ?? '');
  if (millesime == null) return null;
  if (couleur == null || couleur.isEmpty) return null;

  final id =
      (row['id']?.isEmpty ?? true) ? _uuid.v4() : row['id']!;

  return BouteillesCompanion(
    id: Value(id),
    domaine: Value(domaine),
    appellation: Value(appellation),
    millesime: Value(millesime),
    couleur: Value(couleur),
    cru: Value(_nullIfEmpty(row['cru'])),
    contenance: Value(row['contenance'] ?? ''),
    emplacement: Value(row['emplacement'] ?? ''),
    dateEntree: Value(row['date_entree'] ?? ''),
    dateSortie: Value(_nullIfEmpty(row['date_sortie'])),
    prixAchat: Value(_parseReal(row['prix_achat'])),
    gardeMin: Value(int.tryParse(row['garde_min'] ?? '')),
    gardeMax: Value(int.tryParse(row['garde_max'] ?? '')),
    commentaireEntree: Value(_nullIfEmpty(row['commentaire_entree'])),
    noteDegus: Value(_parseReal(row['note_degus'])),
    commentaireDegus: Value(_nullIfEmpty(row['commentaire_degus'])),
    fournisseurNom: Value(_nullIfEmpty(row['fournisseur_nom'])),
    fournisseurInfos: Value(_nullIfEmpty(row['fournisseur_infos'])),
    producteur: Value(_nullIfEmpty(row['producteur'])),
    updatedAt: Value(DateTime.now().toIso8601String()),
  );
}

String? _nullIfEmpty(String? value) =>
    (value == null || value.isEmpty) ? null : value;

double? _parseReal(String? value) {
  if (value == null || value.isEmpty) return null;
  return double.tryParse(value.replaceAll(',', '.'));
}
