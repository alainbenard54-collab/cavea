// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/bouteilles.dart';

class BouteilleDao {
  final AppDatabase _db;

  BouteilleDao(this._db);

  Stream<List<Bouteille>> watchStock() {
    return (_db.select(_db.bouteilles)
          ..where((b) => b.dateSortie.isNull() | b.dateSortie.equals(''))
          ..orderBy([
            (b) => OrderingTerm.asc(b.domaine),
            (b) => OrderingTerm.asc(b.millesime),
          ]))
        .watch();
  }

  Future<void> insertBouteille(BouteillesCompanion bouteille) {
    return _db.into(_db.bouteilles).insert(bouteille);
  }

  Future<bool> updateBouteille(BouteillesCompanion bouteille) {
    return _db.update(_db.bouteilles).replace(bouteille);
  }

  Future<Bouteille?> getBouteilleById(String id) {
    return (_db.select(_db.bouteilles)..where((b) => b.id.equals(id)))
        .getSingleOrNull();
  }
}
