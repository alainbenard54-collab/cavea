// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import '../../data/daos/bouteille_dao.dart';
import '../../data/tables/bouteilles.dart';

class ImportResult {
  final int inserted;
  final int updated;
  final int skipped;
  final int errors;

  const ImportResult({
    required this.inserted,
    required this.updated,
    required this.skipped,
    required this.errors,
  });

  @override
  String toString() =>
      '$inserted insérées · $updated mises à jour · $skipped ignorées · $errors erreurs';
}

class ImportService {
  final BouteilleDao _dao;

  ImportService(this._dao);

  Future<ImportResult> run(
    List<BouteillesCompanion> companions, {
    bool overwrite = false,
    int parseErrors = 0,
  }) async {
    var inserted = 0;
    var updated = 0;
    var skipped = 0;
    var errors = parseErrors;

    for (final companion in companions) {
      try {
        final id = companion.id.value;
        final existing = await _dao.getBouteilleById(id);

        if (existing == null) {
          await _dao.insertBouteille(companion);
          inserted++;
        } else if (overwrite) {
          await _dao.updateBouteille(companion);
          updated++;
        } else {
          skipped++;
        }
      } catch (_) {
        errors++;
      }
    }

    return ImportResult(
      inserted: inserted,
      updated: updated,
      skipped: skipped,
      errors: errors,
    );
  }
}
