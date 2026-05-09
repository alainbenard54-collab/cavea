// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:cavea/data/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  // ── Helpers ──────────────────────────────────────────────────────────────

  BouteillesCompanion _b({
    required String id,
    String domaine = 'Domaine Test',
    String appellation = 'Bordeaux',
    int millesime = 2015,
    String couleur = 'Rouge',
    String contenance = '75 cl',
    String emplacement = 'Cave A',
    String? dateSortie,
    double? noteDegus,
    String? commentaireDegus,
  }) {
    return BouteillesCompanion(
      id: Value(id),
      domaine: Value(domaine),
      appellation: Value(appellation),
      millesime: Value(millesime),
      couleur: Value(couleur),
      contenance: Value(contenance),
      emplacement: Value(emplacement),
      dateEntree: const Value('2026-01-01'),
      updatedAt: const Value('2026-01-01T00:00:00Z'),
      dateSortie: dateSortie != null ? Value(dateSortie) : const Value.absent(),
      noteDegus: noteDegus != null ? Value(noteDegus) : const Value.absent(),
      commentaireDegus: commentaireDegus != null
          ? Value(commentaireDegus)
          : const Value.absent(),
    );
  }

  // ── watchStock ───────────────────────────────────────────────────────────

  group('watchStock', () {
    test('exclut les bouteilles avec date_sortie renseignée', () async {
      await db.bouteilleDao.insertBouteille(_b(id: 'b1'));
      await db.bouteilleDao.insertBouteille(
        _b(id: 'b2', dateSortie: '2026-04-01'),
      );

      final stock = await db.bouteilleDao.watchStock().first;

      expect(stock.length, 1);
      expect(stock.first.id, 'b1');
    });

    test('liste vide si toutes les bouteilles sont consommées', () async {
      await db.bouteilleDao.insertBouteille(
        _b(id: 'b1', dateSortie: '2026-04-01'),
      );

      final stock = await db.bouteilleDao.watchStock().first;

      expect(stock, isEmpty);
    });
  });

  // ── watchStockFiltered ───────────────────────────────────────────────────

  group('watchStockFiltered', () {
    setUp(() async {
      await db.bouteilleDao.insertBouteilles([
        _b(id: '1', couleur: 'Rouge', appellation: 'Pomerol', millesime: 2015,
            domaine: 'Petrus'),
        _b(id: '2', couleur: 'Blanc', appellation: 'Chablis', millesime: 2018,
            domaine: 'Dauvissat'),
        _b(id: '3', couleur: 'Rosé', appellation: 'Bandol', millesime: 2020,
            domaine: 'Tempier'),
      ]);
    });

    test('filtre par couleur unique', () async {
      final result = await db.bouteilleDao
          .watchStockFiltered(couleurs: ['Rouge']).first;

      expect(result.length, 1);
      expect(result.first.couleur, 'Rouge');
    });

    test('filtre par plusieurs couleurs', () async {
      final result = await db.bouteilleDao
          .watchStockFiltered(couleurs: ['Rouge', 'Blanc']).first;

      expect(result.length, 2);
      expect(result.map((b) => b.couleur), containsAll(['Rouge', 'Blanc']));
      expect(result.any((b) => b.couleur == 'Rosé'), isFalse);
    });

    test('filtre par appellation', () async {
      final result = await db.bouteilleDao
          .watchStockFiltered(appellation: 'Pomerol').first;

      expect(result.length, 1);
      expect(result.first.appellation, 'Pomerol');
    });

    test('filtre par millésime', () async {
      final result = await db.bouteilleDao
          .watchStockFiltered(millesime: 2018).first;

      expect(result.length, 1);
      expect(result.first.millesime, 2018);
    });

    test('filtre par texte sur domaine (insensible à la casse)', () async {
      final result = await db.bouteilleDao
          .watchStockFiltered(texte: 'PETRUS').first;

      expect(result.length, 1);
      expect(result.first.domaine, 'Petrus');
    });

    test('sans critère retourne tout le stock', () async {
      final result = await db.bouteilleDao.watchStockFiltered().first;

      expect(result.length, 3);
    });
  });

  // ── insertBouteille ──────────────────────────────────────────────────────

  group('insertBouteille', () {
    test('la bouteille apparaît dans watchStock', () async {
      await db.bouteilleDao.insertBouteille(_b(id: 'x1'));

      final stock = await db.bouteilleDao.watchStock().first;

      expect(stock.any((b) => b.id == 'x1'), isTrue);
    });
  });

  // ── insertBouteilles ─────────────────────────────────────────────────────

  group('insertBouteilles', () {
    test('N bouteilles insérées en transaction', () async {
      await db.bouteilleDao.insertBouteilles([
        _b(id: 'a1'),
        _b(id: 'a2'),
        _b(id: 'a3'),
      ]);

      final stock = await db.bouteilleDao.watchStock().first;

      expect(stock.length, 3);
      expect(stock.map((b) => b.id), containsAll(['a1', 'a2', 'a3']));
    });
  });

  // ── deplacerBouteille ────────────────────────────────────────────────────

  group('deplacerBouteille', () {
    test('met à jour emplacement, date_sortie reste null', () async {
      await db.bouteilleDao.insertBouteille(_b(id: 'd1'));
      await db.bouteilleDao.deplacerBouteille('d1', 'Cave > Étagère 2');

      final b = await db.bouteilleDao.getBouteilleById('d1');

      expect(b!.emplacement, 'Cave > Étagère 2');
      expect(b.dateSortie, isNull);
    });

    test('la bouteille reste dans le stock après déplacement', () async {
      await db.bouteilleDao.insertBouteille(_b(id: 'd2'));
      await db.bouteilleDao.deplacerBouteille('d2', 'Cave B');

      final stock = await db.bouteilleDao.watchStock().first;

      expect(stock.any((b) => b.id == 'd2'), isTrue);
    });
  });

  // ── consommerBouteille ───────────────────────────────────────────────────

  group('consommerBouteille', () {
    test('avec note et commentaire', () async {
      await db.bouteilleDao.insertBouteille(_b(id: 'c1'));
      await db.bouteilleDao.consommerBouteille(
        'c1',
        dateSortie: '2026-05-07',
        noteDegus: 8.5,
        commentaireDegus: 'Excellent',
      );

      final b = await db.bouteilleDao.getBouteilleById('c1');

      expect(b!.dateSortie, '2026-05-07');
      expect(b.noteDegus, 8.5);
      expect(b.commentaireDegus, 'Excellent');
    });

    test('sans note ni commentaire — champs restent null', () async {
      await db.bouteilleDao.insertBouteille(_b(id: 'c2'));
      await db.bouteilleDao.consommerBouteille(
        'c2',
        dateSortie: '2026-05-07',
      );

      final b = await db.bouteilleDao.getBouteilleById('c2');

      expect(b!.dateSortie, '2026-05-07');
      expect(b.noteDegus, isNull);
      expect(b.commentaireDegus, isNull);
    });

    test('la bouteille disparaît du stock', () async {
      await db.bouteilleDao.insertBouteille(_b(id: 'c3'));
      await db.bouteilleDao.consommerBouteille('c3', dateSortie: '2026-05-07');

      final stock = await db.bouteilleDao.watchStock().first;

      expect(stock.any((b) => b.id == 'c3'), isFalse);
    });
  });

  // ── getDistinctEmplacements ──────────────────────────────────────────────

  group('getDistinctEmplacements', () {
    test('valeurs distinctes triées, consommées exclues', () async {
      await db.bouteilleDao.insertBouteilles([
        _b(id: 'e1', emplacement: 'Cave B'),
        _b(id: 'e2', emplacement: 'Cave A'),
        _b(id: 'e3', emplacement: 'Cave A'),
        _b(id: 'e4', emplacement: 'Chambre', dateSortie: '2026-01-01'),
      ]);

      final emplacements = await db.bouteilleDao.getDistinctEmplacements();

      expect(emplacements, ['Cave A', 'Cave B']);
    });
  });

  // ── getDistinctCouleurs ──────────────────────────────────────────────────

  group('getDistinctCouleurs', () {
    test('valeurs distinctes triées (stock uniquement)', () async {
      await db.bouteilleDao.insertBouteilles([
        _b(id: 'col1', couleur: 'Rouge'),
        _b(id: 'col2', couleur: 'Blanc'),
        _b(id: 'col3', couleur: 'Rouge'),
      ]);

      final couleurs = await db.bouteilleDao.getDistinctCouleurs();

      expect(couleurs, ['Blanc', 'Rouge']);
    });
  });
}
