// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import '../../data/daos/bouteille_dao.dart';
import '../../data/database.dart';

class ImportResult {
  final int inserted;
  final int updated;
  final int skipped;
  final int errors;
  final List<String> errorDetails;

  const ImportResult({
    required this.inserted,
    required this.updated,
    required this.skipped,
    required this.errors,
    this.errorDetails = const [],
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
    List<String> parseErrorDetails = const [],
  }) async {
    var inserted = 0;
    var updated = 0;
    var skipped = 0;
    final allErrors = List<String>.from(parseErrorDetails);

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
      } catch (e) {
        allErrors.add('UUID ${companion.id.value} : $e');
      }
    }

    return ImportResult(
      inserted: inserted,
      updated: updated,
      skipped: skipped,
      errors: allErrors.length,
      errorDetails: allErrors,
    );
  }
}
