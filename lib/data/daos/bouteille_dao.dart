// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:drift/drift.dart';
import '../database.dart';

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

  Stream<List<Bouteille>> watchStockFiltered({
    List<String>? couleurs,
    String? appellation,
    int? millesime,
    String? texte,
  }) {
    return (_db.select(_db.bouteilles)
          ..where((b) {
            var cond = b.dateSortie.isNull() | b.dateSortie.equals('');
            if (couleurs != null && couleurs.isNotEmpty) {
              cond = cond & b.couleur.isIn(couleurs);
            }
            if (appellation != null) {
              cond = cond & b.appellation.equals(appellation);
            }
            if (millesime != null) cond = cond & b.millesime.equals(millesime);
            if (texte != null && texte.isNotEmpty) {
              final t = texte.toLowerCase();
              cond = cond &
                  (b.domaine.lower().like('%$t%') |
                      b.appellation.lower().like('%$t%') |
                      b.millesime.cast<String>().like('%$t%'));
            }
            return cond;
          })
          ..orderBy([
            (b) => OrderingTerm.asc(b.domaine),
            (b) => OrderingTerm.asc(b.millesime),
          ]))
        .watch();
  }

  Future<List<String>> getDistinctCouleurs() async {
    final query = _db.selectOnly(_db.bouteilles, distinct: true)
      ..addColumns([_db.bouteilles.couleur])
      ..where(
        _db.bouteilles.dateSortie.isNull() |
            _db.bouteilles.dateSortie.equals(''),
      )
      ..orderBy([OrderingTerm.asc(_db.bouteilles.couleur)]);
    final rows = await query.get();
    return rows
        .map((r) => r.read(_db.bouteilles.couleur) ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<List<String>> getDistinctAppellations({String? couleur}) async {
    final query = _db.selectOnly(_db.bouteilles, distinct: true)
      ..addColumns([_db.bouteilles.appellation])
      ..where(
        _db.bouteilles.dateSortie.isNull() |
            _db.bouteilles.dateSortie.equals(''),
      );
    if (couleur != null) {
      query.where(_db.bouteilles.couleur.equals(couleur));
    }
    query.orderBy([OrderingTerm.asc(_db.bouteilles.appellation)]);
    final rows = await query.get();
    return rows
        .map((r) => r.read(_db.bouteilles.appellation) ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<List<int>> getDistinctMillesimes({
    String? couleur,
    String? appellation,
  }) async {
    final query = _db.selectOnly(_db.bouteilles, distinct: true)
      ..addColumns([_db.bouteilles.millesime])
      ..where(
        _db.bouteilles.dateSortie.isNull() |
            _db.bouteilles.dateSortie.equals(''),
      );
    if (couleur != null) {
      query.where(_db.bouteilles.couleur.equals(couleur));
    }
    if (appellation != null) {
      query.where(_db.bouteilles.appellation.equals(appellation));
    }
    query.orderBy([OrderingTerm.desc(_db.bouteilles.millesime)]);
    final rows = await query.get();
    return rows
        .map((r) => r.read(_db.bouteilles.millesime) ?? 0)
        .where((v) => v > 0)
        .toList();
  }

  Future<void> insertBouteille(BouteillesCompanion bouteille) {
    return _db.into(_db.bouteilles).insert(bouteille);
  }

  Future<void> insertBouteilles(List<BouteillesCompanion> bouteilles) {
    return _db.transaction(() async {
      for (final b in bouteilles) {
        await _db.into(_db.bouteilles).insert(b);
      }
    });
  }

  Future<bool> updateBouteille(BouteillesCompanion bouteille) {
    return _db.update(_db.bouteilles).replace(bouteille);
  }

  Future<void> deplacerBouteille(String id, String emplacement) {
    return (_db.update(_db.bouteilles)..where((b) => b.id.equals(id))).write(
      BouteillesCompanion(emplacement: Value(emplacement)),
    );
  }

  Future<void> consommerBouteille(
    String id, {
    required String dateSortie,
    double? noteDegus,
    String? commentaireDegus,
  }) {
    return (_db.update(_db.bouteilles)..where((b) => b.id.equals(id))).write(
      BouteillesCompanion(
        dateSortie: Value(dateSortie),
        noteDegus: noteDegus != null ? Value(noteDegus) : const Value.absent(),
        commentaireDegus: commentaireDegus != null
            ? Value(commentaireDegus)
            : const Value.absent(),
      ),
    );
  }

  Future<List<String>> getDistinctEmplacements() async {
    final query = _db.selectOnly(_db.bouteilles, distinct: true)
      ..addColumns([_db.bouteilles.emplacement])
      ..where(
        _db.bouteilles.dateSortie.isNull() |
            _db.bouteilles.dateSortie.equals(''),
      )
      ..orderBy([OrderingTerm.asc(_db.bouteilles.emplacement)]);
    final rows = await query.get();
    return rows
        .map((r) => r.read(_db.bouteilles.emplacement) ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<List<String>> getAllDistinctContenances() async {
    final query = _db.selectOnly(_db.bouteilles, distinct: true)
      ..addColumns([_db.bouteilles.contenance])
      ..where(_db.bouteilles.contenance.isNotNull())
      ..orderBy([OrderingTerm.asc(_db.bouteilles.contenance)]);
    final rows = await query.get();
    return rows
        .map((r) => r.read(_db.bouteilles.contenance) ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<List<String>> getAllDistinctCouleurs() async {
    final query = _db.selectOnly(_db.bouteilles, distinct: true)
      ..addColumns([_db.bouteilles.couleur])
      ..orderBy([OrderingTerm.asc(_db.bouteilles.couleur)]);
    final rows = await query.get();
    return rows
        .map((r) => r.read(_db.bouteilles.couleur) ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<List<String>> getAllDistinctCrus() async {
    final query = _db.selectOnly(_db.bouteilles, distinct: true)
      ..addColumns([_db.bouteilles.cru])
      ..where(_db.bouteilles.cru.isNotNull())
      ..orderBy([OrderingTerm.asc(_db.bouteilles.cru)]);
    final rows = await query.get();
    return rows
        .map((r) => r.read(_db.bouteilles.cru) ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<List<String>> getDistinctDomaines() async {
    final query = _db.selectOnly(_db.bouteilles, distinct: true)
      ..addColumns([_db.bouteilles.domaine])
      ..orderBy([OrderingTerm.asc(_db.bouteilles.domaine)]);
    final rows = await query.get();
    return rows
        .map((r) => r.read(_db.bouteilles.domaine) ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<List<String>> getAllDistinctAppellations() async {
    final query = _db.selectOnly(_db.bouteilles, distinct: true)
      ..addColumns([_db.bouteilles.appellation])
      ..orderBy([OrderingTerm.asc(_db.bouteilles.appellation)]);
    final rows = await query.get();
    return rows
        .map((r) => r.read(_db.bouteilles.appellation) ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<List<String>> getDistinctFournisseurs() async {
    final query = _db.selectOnly(_db.bouteilles, distinct: true)
      ..addColumns([_db.bouteilles.fournisseurNom])
      ..where(_db.bouteilles.fournisseurNom.isNotNull())
      ..orderBy([OrderingTerm.asc(_db.bouteilles.fournisseurNom)]);
    final rows = await query.get();
    return rows
        .map((r) => r.read(_db.bouteilles.fournisseurNom) ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Future<Bouteille?> getBouteilleById(String id) {
    return (_db.select(_db.bouteilles)..where((b) => b.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<Bouteille?> watchBottleById(String id) {
    return (_db.select(_db.bouteilles)..where((b) => b.id.equals(id)))
        .watchSingleOrNull();
  }
}
