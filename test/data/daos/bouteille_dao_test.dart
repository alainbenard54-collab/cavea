// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:drift/drift.dart' hide isNull, isNotNull;
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

  // ── getBouteilleById ─────────────────────────────────────────────────────

  group('getBouteilleById', () {
    test('retourne la bouteille si elle existe', () async {
      await db.bouteilleDao.insertBouteille(_b(id: 'found1'));

      final b = await db.bouteilleDao.getBouteilleById('found1');

      expect(b, isNotNull);
      expect(b!.id, 'found1');
    });

    test('retourne null si id inconnu', () async {
      final b = await db.bouteilleDao.getBouteilleById('inconnu');

      expect(b, isNull);
    });
  });

  // ── updateBouteille ──────────────────────────────────────────────────────

  group('updateBouteille', () {
    test('met à jour le domaine, autres champs inchangés', () async {
      await db.bouteilleDao.insertBouteille(
        _b(id: 'u1', domaine: 'DomA', appellation: 'AppX'),
      );

      await db.bouteilleDao.updateBouteille(
        _b(id: 'u1', domaine: 'DomB', appellation: 'AppX'),
      );

      final b = await db.bouteilleDao.getBouteilleById('u1');
      expect(b!.domaine, 'DomB');
      expect(b.appellation, 'AppX');
    });

    test('met à jour updatedAt', () async {
      await db.bouteilleDao.insertBouteille(_b(id: 'u2'));

      await db.bouteilleDao.updateBouteille(
        BouteillesCompanion(
          id: const Value('u2'),
          domaine: const Value('Domaine Test'),
          appellation: const Value('Bordeaux'),
          millesime: const Value(2015),
          couleur: const Value('Rouge'),
          contenance: const Value('75 cl'),
          emplacement: const Value('Cave A'),
          dateEntree: const Value('2026-01-01'),
          updatedAt: const Value('2030-01-01T00:00:00Z'),
        ),
      );

      final b = await db.bouteilleDao.getBouteilleById('u2');
      expect(b!.updatedAt, '2030-01-01T00:00:00Z');
    });
  });

  // ── deplacerBouteilles (batch) ───────────────────────────────────────────

  group('deplacerBouteilles', () {
    test('déplace tous les ids, date_sortie reste null', () async {
      await db.bouteilleDao.insertBouteilles([
        _b(id: 'db1', emplacement: 'Cave A'),
        _b(id: 'db2', emplacement: 'Cave A'),
      ]);

      await db.bouteilleDao.deplacerBouteilles(['db1', 'db2'], 'Cave B');

      final b1 = await db.bouteilleDao.getBouteilleById('db1');
      final b2 = await db.bouteilleDao.getBouteilleById('db2');
      expect(b1!.emplacement, 'Cave B');
      expect(b2!.emplacement, 'Cave B');
      expect(b1.dateSortie, isNull);
      expect(b2.dateSortie, isNull);
    });
  });

  // ── consommerBouteilles (batch) ──────────────────────────────────────────

  group('consommerBouteilles', () {
    test('consomme tous les ids avec date et note', () async {
      await db.bouteilleDao.insertBouteilles([
        _b(id: 'cb1'),
        _b(id: 'cb2'),
      ]);

      await db.bouteilleDao.consommerBouteilles(
        ['cb1', 'cb2'],
        dateSortie: '2026-05-01',
        noteDegus: 9.0,
      );

      final b1 = await db.bouteilleDao.getBouteilleById('cb1');
      final b2 = await db.bouteilleDao.getBouteilleById('cb2');
      expect(b1!.dateSortie, '2026-05-01');
      expect(b2!.dateSortie, '2026-05-01');
      expect(b1.noteDegus, 9.0);
      expect(b2.noteDegus, 9.0);
    });

    test('les bouteilles disparaissent du stock', () async {
      await db.bouteilleDao.insertBouteilles([
        _b(id: 'cb3'),
        _b(id: 'cb4'),
      ]);

      await db.bouteilleDao.consommerBouteilles(
        ['cb3', 'cb4'],
        dateSortie: '2026-05-01',
      );

      final stock = await db.bouteilleDao.watchStock().first;
      expect(stock.any((b) => b.id == 'cb3'), isFalse);
      expect(stock.any((b) => b.id == 'cb4'), isFalse);
    });
  });

  // ── rehabiliterBouteille ─────────────────────────────────────────────────

  group('rehabiliterBouteille', () {
    test('efface date_sortie, note et commentaire, réapparaît dans le stock',
        () async {
      await db.bouteilleDao.insertBouteille(
        _b(
          id: 'rh1',
          dateSortie: '2026-04-01',
          noteDegus: 8.0,
          commentaireDegus: 'Très bon',
        ),
      );

      await db.bouteilleDao.rehabiliterBouteille('rh1');

      final b = await db.bouteilleDao.getBouteilleById('rh1');
      expect(b!.dateSortie, isNull);
      expect(b.noteDegus, isNull);
      expect(b.commentaireDegus, isNull);

      final stock = await db.bouteilleDao.watchStock().first;
      expect(stock.any((s) => s.id == 'rh1'), isTrue);
    });
  });

  // ── watchHistorique ──────────────────────────────────────────────────────

  group('watchHistorique', () {
    test('triée date_sortie desc, exclut le stock', () async {
      await db.bouteilleDao.insertBouteilles([
        _b(id: 'h1', dateSortie: '2026-03-01'),
        _b(id: 'h2', dateSortie: '2026-05-01'),
        _b(id: 'h3'),
      ]);

      final histo = await db.bouteilleDao.watchHistorique().first;

      expect(histo.length, 2);
      expect(histo.first.id, 'h2');
      expect(histo.last.id, 'h1');
      expect(histo.any((b) => b.id == 'h3'), isFalse);
    });
  });

  // ── watchBouteillesParEmplacement ────────────────────────────────────────

  group('watchBouteillesParEmplacement', () {
    test('match exact — exclut sous-emplacements', () async {
      await db.bouteilleDao.insertBouteilles([
        _b(id: 'wp1', emplacement: 'Cave A'),
        _b(id: 'wp2', emplacement: 'Cave A > Étagère 1'),
      ]);

      final result = await db.bouteilleDao
          .watchBouteillesParEmplacement('Cave A')
          .first;

      expect(result.length, 1);
      expect(result.first.id, 'wp1');
    });

    test('includeSublocations=true — inclut les sous-emplacements', () async {
      await db.bouteilleDao.insertBouteilles([
        _b(id: 'ws1', emplacement: 'Cave A'),
        _b(id: 'ws2', emplacement: 'Cave A > Étagère 1'),
      ]);

      final result = await db.bouteilleDao
          .watchBouteillesParEmplacement('Cave A', includeSublocations: true)
          .first;

      expect(result.length, 2);
      expect(result.map((b) => b.id), containsAll(['ws1', 'ws2']));
    });
  });

  // ── watchLocationStats ───────────────────────────────────────────────────

  group('watchLocationStats', () {
    test('groupé par emplacement, stock uniquement, sumPrix et nullPrixCount',
        () async {
      await db.bouteilleDao.insertBouteilles([
        BouteillesCompanion(
          id: const Value('ls1'),
          domaine: const Value('D'),
          appellation: const Value('A'),
          millesime: const Value(2020),
          couleur: const Value('Rouge'),
          contenance: const Value('75 cl'),
          emplacement: const Value('Cave A'),
          dateEntree: const Value('2026-01-01'),
          updatedAt: const Value('2026-01-01T00:00:00Z'),
          prixAchat: const Value(10.0),
        ),
        BouteillesCompanion(
          id: const Value('ls2'),
          domaine: const Value('D'),
          appellation: const Value('A'),
          millesime: const Value(2020),
          couleur: const Value('Rouge'),
          contenance: const Value('75 cl'),
          emplacement: const Value('Cave A'),
          dateEntree: const Value('2026-01-01'),
          updatedAt: const Value('2026-01-01T00:00:00Z'),
        ),
        BouteillesCompanion(
          id: const Value('ls3'),
          domaine: const Value('D'),
          appellation: const Value('A'),
          millesime: const Value(2020),
          couleur: const Value('Rouge'),
          contenance: const Value('75 cl'),
          emplacement: const Value('Cave B'),
          dateEntree: const Value('2026-01-01'),
          updatedAt: const Value('2026-01-01T00:00:00Z'),
          prixAchat: const Value(5.0),
        ),
        _b(id: 'ls4', emplacement: 'Cave A', dateSortie: '2026-01-15'),
      ]);

      final leaves = await db.bouteilleDao.watchLocationStats().first;
      leaves.sort((a, b) => a.emplacement.compareTo(b.emplacement));

      expect(leaves.length, 2);

      final caveA = leaves.firstWhere((l) => l.emplacement == 'Cave A');
      expect(caveA.count, 2);
      expect(caveA.sumPrix, 10.0);
      expect(caveA.nullPrixCount, 1);

      final caveB = leaves.firstWhere((l) => l.emplacement == 'Cave B');
      expect(caveB.count, 1);
      expect(caveB.sumPrix, 5.0);
      expect(caveB.nullPrixCount, 0);
    });
  });

  // ── getDistinctDomaines ──────────────────────────────────────────────────

  group('getDistinctDomaines', () {
    test('retourne toutes bouteilles (stock + consommées), triées', () async {
      await db.bouteilleDao.insertBouteilles([
        _b(id: 'gd1', domaine: 'Petrus'),
        _b(id: 'gd2', domaine: 'Mouton'),
        _b(id: 'gd3', domaine: 'Ausone', dateSortie: '2026-01-01'),
      ]);

      final domaines = await db.bouteilleDao.getDistinctDomaines();

      expect(domaines, ['Ausone', 'Mouton', 'Petrus']);
    });
  });

  // ── getAllDistinctAppellations ────────────────────────────────────────────

  group('getAllDistinctAppellations', () {
    test('retourne toutes bouteilles (stock + consommées), triées', () async {
      await db.bouteilleDao.insertBouteilles([
        _b(id: 'ga1', appellation: 'Pomerol'),
        _b(id: 'ga2', appellation: 'Chablis'),
        _b(id: 'ga3', appellation: 'Bandol', dateSortie: '2026-01-01'),
      ]);

      final appellations = await db.bouteilleDao.getAllDistinctAppellations();

      expect(appellations, ['Bandol', 'Chablis', 'Pomerol']);
    });
  });

  // ── getAllDistinctContenances ─────────────────────────────────────────────

  group('getAllDistinctContenances', () {
    test('retourne toutes bouteilles, exclut les null, triées', () async {
      await db.bouteilleDao.insertBouteilles([
        BouteillesCompanion(
          id: const Value('gc1'),
          domaine: const Value('D'),
          appellation: const Value('A'),
          millesime: const Value(2020),
          couleur: const Value('Rouge'),
          contenance: const Value('75 cl'),
          emplacement: const Value('Cave A'),
          dateEntree: const Value('2026-01-01'),
          updatedAt: const Value('2026-01-01T00:00:00Z'),
        ),
        BouteillesCompanion(
          id: const Value('gc2'),
          domaine: const Value('D'),
          appellation: const Value('A'),
          millesime: const Value(2020),
          couleur: const Value('Rouge'),
          contenance: const Value('1,5 L'),
          emplacement: const Value('Cave A'),
          dateEntree: const Value('2026-01-01'),
          updatedAt: const Value('2026-01-01T00:00:00Z'),
        ),
        BouteillesCompanion(
          id: const Value('gc3'),
          domaine: const Value('D'),
          appellation: const Value('A'),
          millesime: const Value(2020),
          couleur: const Value('Rouge'),
          contenance: const Value(''),
          emplacement: const Value('Cave A'),
          dateEntree: const Value('2026-01-01'),
          updatedAt: const Value('2026-01-01T00:00:00Z'),
        ),
      ]);

      final contenances = await db.bouteilleDao.getAllDistinctContenances();

      expect(contenances.length, 2);
      expect(contenances, containsAll(['75 cl', '1,5 L']));
    });
  });

  // ── getAllDistinctCrus ───────────────────────────────────────────────────

  group('getAllDistinctCrus', () {
    test('retourne toutes bouteilles, exclut les null', () async {
      await db.bouteilleDao.insertBouteilles([
        BouteillesCompanion(
          id: const Value('gcr1'),
          domaine: const Value('D'),
          appellation: const Value('A'),
          millesime: const Value(2020),
          couleur: const Value('Rouge'),
          contenance: const Value('75 cl'),
          emplacement: const Value('Cave A'),
          dateEntree: const Value('2026-01-01'),
          updatedAt: const Value('2026-01-01T00:00:00Z'),
          cru: const Value('Grand Cru'),
        ),
        BouteillesCompanion(
          id: const Value('gcr2'),
          domaine: const Value('D'),
          appellation: const Value('A'),
          millesime: const Value(2020),
          couleur: const Value('Rouge'),
          contenance: const Value('75 cl'),
          emplacement: const Value('Cave A'),
          dateEntree: const Value('2026-01-01'),
          updatedAt: const Value('2026-01-01T00:00:00Z'),
          cru: const Value('Premier Cru'),
        ),
        _b(id: 'gcr3'),
      ]);

      final crus = await db.bouteilleDao.getAllDistinctCrus();

      expect(crus.length, 2);
      expect(crus, containsAll(['Grand Cru', 'Premier Cru']));
    });
  });

  // ── getDistinctFournisseurs ──────────────────────────────────────────────

  group('getDistinctFournisseurs', () {
    test('retourne toutes bouteilles, exclut les null, triées', () async {
      await db.bouteilleDao.insertBouteilles([
        BouteillesCompanion(
          id: const Value('gf1'),
          domaine: const Value('D'),
          appellation: const Value('A'),
          millesime: const Value(2020),
          couleur: const Value('Rouge'),
          contenance: const Value('75 cl'),
          emplacement: const Value('Cave A'),
          dateEntree: const Value('2026-01-01'),
          updatedAt: const Value('2026-01-01T00:00:00Z'),
          fournisseurNom: const Value('Fournisseur A'),
        ),
        BouteillesCompanion(
          id: const Value('gf2'),
          domaine: const Value('D'),
          appellation: const Value('A'),
          millesime: const Value(2020),
          couleur: const Value('Rouge'),
          contenance: const Value('75 cl'),
          emplacement: const Value('Cave A'),
          dateEntree: const Value('2026-01-01'),
          updatedAt: const Value('2026-01-01T00:00:00Z'),
          fournisseurNom: const Value('Fournisseur B'),
        ),
        _b(id: 'gf3'),
      ]);

      final fournisseurs = await db.bouteilleDao.getDistinctFournisseurs();

      expect(fournisseurs, ['Fournisseur A', 'Fournisseur B']);
    });
  });
}
