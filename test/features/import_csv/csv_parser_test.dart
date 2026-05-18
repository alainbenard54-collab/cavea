// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter_test/flutter_test.dart';
import 'package:cavea/features/import_csv/csv_parser.dart';

void main() {
  // Ligne CSV minimale valide avec tous les champs obligatoires
  const headers = 'domaine;appellation;millesime;couleur';
  const validRow = 'Test;Bordeaux;2018;Rouge';

  // ── Séparateurs ──────────────────────────────────────────────────────────

  group('séparateurs', () {
    test('point-virgule (défaut)', () {
      final result = parseCsv('$headers\n$validRow');

      expect(result.companions.length, 1);
      expect(result.errors, isEmpty);
      expect(result.companions.first.domaine.value, 'Test');
    });

    test('virgule', () {
      final csv = 'domaine,appellation,millesime,couleur\nTest,Bordeaux,2018,Rouge';
      final result = parseCsv(csv, separator: ',');

      expect(result.companions.length, 1);
      expect(result.companions.first.domaine.value, 'Test');
    });

    test('tabulation', () {
      final csv = 'domaine\tappellation\tmillesime\tcouleur\nTest\tBordeaux\t2018\tRouge';
      final result = parseCsv(csv, separator: '\t');

      expect(result.companions.length, 1);
      expect(result.companions.first.domaine.value, 'Test');
    });
  });

  // ── BOM UTF-8 ────────────────────────────────────────────────────────────

  group('BOM UTF-8', () {
    test('BOM retiré automatiquement — companion parsé correctement', () {
      final csv = '\u{FEFF}$headers\n$validRow';
      final result = parseCsv(csv);

      expect(result.companions.length, 1);
      expect(result.errors, isEmpty);
    });
  });

  // ── Champs quotés ────────────────────────────────────────────────────────

  group('champs quotés', () {
    test('champ contenant le séparateur virgule — valeur intacte', () {
      final csv = 'domaine,appellation,millesime,couleur\n"Château, Grand",Bordeaux,2018,Rouge';
      final result = parseCsv(csv, separator: ',');

      expect(result.companions.length, 1);
      expect(result.companions.first.domaine.value, 'Château, Grand');
    });

    test('champ contenant le séparateur point-virgule', () {
      final csv = 'domaine;appellation;millesime;couleur\n"Dom;Test";Bordeaux;2018;Rouge';
      final result = parseCsv(csv);

      expect(result.companions.first.domaine.value, 'Dom;Test');
    });
  });

  // ── Types ────────────────────────────────────────────────────────────────

  group('conversion de types', () {
    test('millesime → int', () {
      final result = parseCsv('$headers\nTest;Bordeaux;2018;Rouge');

      expect(result.companions.first.millesime.value, 2018);
    });

    test('garde_min vide → null, garde_max renseigné → int', () {
      final csv = 'domaine;appellation;millesime;couleur;garde_min;garde_max\nTest;Bordeaux;2018;Rouge;;15';
      final result = parseCsv(csv);

      expect(result.companions.first.gardeMin.value, isNull);
      expect(result.companions.first.gardeMax.value, 15);
    });

    test('prix_achat vide → null', () {
      final csv = 'domaine;appellation;millesime;couleur;prix_achat\nTest;Bordeaux;2018;Rouge;';
      final result = parseCsv(csv);

      expect(result.companions.first.prixAchat.value, isNull);
    });

    test('prix_achat avec virgule décimale → double', () {
      final csv = 'domaine;appellation;millesime;couleur;prix_achat\nTest;Bordeaux;2018;Rouge;15,50';
      final result = parseCsv(csv);

      expect(result.companions.first.prixAchat.value, 15.5);
    });
  });

  // ── Lignes invalides ─────────────────────────────────────────────────────

  group('lignes invalides', () {
    test('ligne vide ignorée — 2 lignes valides conservées', () {
      final csv = '$headers\n$validRow\n\n$validRow';
      final result = parseCsv(csv);

      expect(result.companions.length, 2);
      expect(result.errors, isEmpty);
    });

    test('domaine vide → erreur, 0 companion', () {
      final csv = '$headers\n;Bordeaux;2018;Rouge';
      final result = parseCsv(csv);

      expect(result.companions, isEmpty);
      expect(result.errors.length, 1);
    });

    test('appellation vide → erreur', () {
      final csv = '$headers\nTest;;2018;Rouge';
      final result = parseCsv(csv);

      expect(result.companions, isEmpty);
      expect(result.errors.length, 1);
    });

    test('millesime invalide → erreur', () {
      final csv = '$headers\nTest;Bordeaux;abc;Rouge';
      final result = parseCsv(csv);

      expect(result.companions, isEmpty);
      expect(result.errors.length, 1);
    });
  });

  // ── updatedAt ────────────────────────────────────────────────────────────

  group('updatedAt', () {
    test('valide ISO8601 → préservé tel quel', () {
      final csv = 'domaine;appellation;millesime;couleur;updated_at\nTest;Bordeaux;2018;Rouge;2025-06-01T10:00:00Z';
      final result = parseCsv(csv);

      expect(result.companions.first.updatedAt.value, '2025-06-01T10:00:00.000Z');
    });

    test('absent → DateTime générée non vide', () {
      final result = parseCsv('$headers\n$validRow');

      final updatedAt = result.companions.first.updatedAt.value;
      expect(updatedAt, isNotEmpty);
      expect(DateTime.tryParse(updatedAt), isNotNull);
    });
  });
}
