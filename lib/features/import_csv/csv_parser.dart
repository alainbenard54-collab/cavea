// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../data/database.dart';

const _uuid = Uuid();

class ParseError {
  final int lineNumber;
  final String reason;
  final String rawLine;
  const ParseError({
    required this.lineNumber,
    required this.reason,
    required this.rawLine,
  });
}

class ParseResult {
  final List<BouteillesCompanion> companions;
  final List<ParseError> errors;
  int get errorCount => errors.length;

  const ParseResult({required this.companions, required this.errors});
}

ParseResult parseCsv(String content) {
  // Normalise les fins de ligne Windows/Unix
  final lines = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');
  if (lines.isEmpty) return const ParseResult(companions: [], errors: []);

  final headers = lines.first
      .trim()
      .split(';')
      .map((h) => h.trim().toLowerCase())
      .toList();

  final companions = <BouteillesCompanion>[];
  final errors = <ParseError>[];

  for (var i = 1; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) continue;

    try {
      final values = _splitLine(line);
      final row = <String, String>{};
      for (var j = 0; j < headers.length && j < values.length; j++) {
        row[headers[j]] = values[j].trim();
      }

      final (companion, reason) = _rowToCompanion(row);
      if (companion != null) {
        companions.add(companion);
      } else {
        errors.add(ParseError(
          lineNumber: i + 1,
          reason: reason ?? 'Champ obligatoire manquant',
          rawLine: line.length > 80 ? '${line.substring(0, 80)}…' : line,
        ));
      }
    } catch (e) {
      errors.add(ParseError(
        lineNumber: i + 1,
        reason: 'Exception : $e',
        rawLine: line.length > 80 ? '${line.substring(0, 80)}…' : line,
      ));
    }
  }

  return ParseResult(companions: companions, errors: errors);
}

// Respecte les champs entre guillemets contenant des ";"
List<String> _splitLine(String line) {
  final result = <String>[];
  final current = StringBuffer();
  var inQuotes = false;

  for (var i = 0; i < line.length; i++) {
    final char = line[i];
    if (char == '"') {
      inQuotes = !inQuotes;
    } else if (char == ';' && !inQuotes) {
      result.add(current.toString());
      current.clear();
    } else {
      current.write(char);
    }
  }
  result.add(current.toString());
  return result;
}

(BouteillesCompanion?, String?) _rowToCompanion(Map<String, String> row) {
  final domaine = row['domaine'];
  if (domaine == null || domaine.isEmpty) return (null, 'domaine vide');

  final appellation = row['appellation'];
  if (appellation == null || appellation.isEmpty) return (null, 'appellation vide');

  final millesimeStr = row['millesime'] ?? '';
  final millesime = int.tryParse(millesimeStr);
  if (millesime == null) return (null, 'millesime invalide : "$millesimeStr"');

  final couleur = row['couleur'];
  if (couleur == null || couleur.isEmpty) return (null, 'couleur vide');

  final rawId = row['id']?.trim() ?? '';
  final id = rawId.isEmpty ? _uuid.v4() : rawId;

  return (
    BouteillesCompanion(
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
    ),
    null
  );
}

String? _nullIfEmpty(String? value) =>
    (value == null || value.isEmpty) ? null : value;

double? _parseReal(String? value) {
  if (value == null || value.isEmpty) return null;
  return double.tryParse(value.replaceAll(',', '.'));
}
