// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:cavea/data/database.dart';
import 'package:cavea/features/import_csv/import_service.dart';

void main() {
  late AppDatabase db;
  late ImportService service;

  setUp(() {
    db = AppDatabase.memory();
    service = ImportService(db.bouteilleDao);
  });

  tearDown(() async {
    await db.close();
  });

  BouteillesCompanion _companion({
    required String id,
    String domaine = 'Domaine Test',
    String appellation = 'Bordeaux',
    int millesime = 2018,
    String couleur = 'Rouge',
    String updatedAt = '2026-01-01T00:00:00Z',
  }) {
    return BouteillesCompanion(
      id: Value(id),
      domaine: Value(domaine),
      appellation: Value(appellation),
      millesime: Value(millesime),
      couleur: Value(couleur),
      contenance: const Value('75 cl'),
      emplacement: const Value('Cave A'),
      dateEntree: const Value('2026-01-01'),
      updatedAt: Value(updatedAt),
    );
  }

  // ── insert ───────────────────────────────────────────────────────────────

  group('insert', () {
    test('id absent de la base → insert, result.inserted == 1', () async {
      final companion = _companion(id: 'new-uuid-001');

      final result = await service.run([companion]);

      expect(result.inserted, 1);
      expect(result.updated, 0);
      expect(result.skipped, 0);
      expect(result.errors, 0);

      final b = await db.bouteilleDao.getBouteilleById('new-uuid-001');
      expect(b, isNotNull);
    });

    test('id fixe absent de la base → insert avec cet UUID exact', () async {
      final companion = _companion(id: 'fixed-uuid-123');

      await service.run([companion]);

      final b = await db.bouteilleDao.getBouteilleById('fixed-uuid-123');
      expect(b!.id, 'fixed-uuid-123');
    });
  });

  // ── overwrite ────────────────────────────────────────────────────────────

  group('overwrite', () {
    test('id existant + overwrite=true → UPDATE, result.updated == 1', () async {
      await db.bouteilleDao.insertBouteille(_companion(id: 'exist-1', domaine: 'DomA'));

      final result = await service.run(
        [_companion(id: 'exist-1', domaine: 'DomB')],
        overwrite: true,
      );

      expect(result.updated, 1);
      expect(result.inserted, 0);

      final b = await db.bouteilleDao.getBouteilleById('exist-1');
      expect(b!.domaine, 'DomB');
    });

    test('id existant + overwrite=false → SKIP, result.skipped == 1', () async {
      await db.bouteilleDao.insertBouteille(_companion(id: 'exist-2', domaine: 'DomA'));

      final result = await service.run(
        [_companion(id: 'exist-2', domaine: 'DomB')],
        overwrite: false,
      );

      expect(result.skipped, 1);
      expect(result.inserted, 0);
      expect(result.updated, 0);

      final b = await db.bouteilleDao.getBouteilleById('exist-2');
      expect(b!.domaine, 'DomA');
    });
  });

  // ── updatedAt ────────────────────────────────────────────────────────────

  group('updatedAt', () {
    test('valide ISO8601 → préservé tel quel', () async {
      final companion = _companion(
        id: 'ua-1',
        updatedAt: '2025-01-15T10:00:00Z',
      );

      await service.run([companion]);

      final b = await db.bouteilleDao.getBouteilleById('ua-1');
      expect(b!.updatedAt, '2025-01-15T10:00:00Z');
    });
  });

  // ── rapport compteurs ────────────────────────────────────────────────────

  group('rapport compteurs', () {
    test('1 insert + 1 update + 1 skip → compteurs corrects', () async {
      await db.bouteilleDao.insertBouteille(_companion(id: 'r-update'));
      await db.bouteilleDao.insertBouteille(_companion(id: 'r-skip'));

      final result = await service.run(
        [
          _companion(id: 'r-new'),
          _companion(id: 'r-update', domaine: 'Modifié'),
          _companion(id: 'r-skip'),
        ],
        overwrite: true,
      );

      expect(result.inserted, 1);
      expect(result.updated, 1);
      expect(result.skipped, 0);
      expect(result.errors, 0);
    });

    test('skip ne modifie pas les données existantes', () async {
      await db.bouteilleDao.insertBouteille(_companion(id: 'r-skip2', domaine: 'OriginalDom'));

      final result = await service.run(
        [_companion(id: 'r-skip2', domaine: 'NewDom')],
        overwrite: false,
      );

      expect(result.skipped, 1);
      final b = await db.bouteilleDao.getBouteilleById('r-skip2');
      expect(b!.domaine, 'OriginalDom');
    });
  });
}
