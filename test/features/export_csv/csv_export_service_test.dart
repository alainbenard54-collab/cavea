// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter_test/flutter_test.dart';
import 'package:cavea/data/database.dart';
import 'package:cavea/features/export_csv/csv_export_service.dart';
import '../../helpers/fake_app_localizations.dart';

void main() {
  const l10n = FakeAppLocalizations();
  final service = CsvExportService();

  Bouteille bouteille({
    String id = 'b1',
    String domaine = 'Domaine Test',
    String appellation = 'Bordeaux',
    int millesime = 2018,
    String couleur = 'Rouge',
    String? cru,
    String contenance = '75 cl',
    String emplacement = 'Cave A',
    String dateEntree = '2026-01-01',
    String? dateSortie,
    double? prixAchat,
    int? gardeMin,
    int? gardeMax,
    String? commentaireEntree,
    double? noteDegus,
    String? commentaireDegus,
    String? fournisseurNom,
    String? fournisseurInfos,
    String? producteur,
    String updatedAt = '2026-01-01T00:00:00Z',
  }) {
    return Bouteille(
      id: id,
      domaine: domaine,
      appellation: appellation,
      millesime: millesime,
      couleur: couleur,
      cru: cru,
      contenance: contenance,
      emplacement: emplacement,
      dateEntree: dateEntree,
      dateSortie: dateSortie,
      prixAchat: prixAchat,
      gardeMin: gardeMin,
      gardeMax: gardeMax,
      commentaireEntree: commentaireEntree,
      noteDegus: noteDegus,
      commentaireDegus: commentaireDegus,
      fournisseurNom: fournisseurNom,
      fournisseurInfos: fournisseurInfos,
      producteur: producteur,
      updatedAt: updatedAt,
    );
  }

  // ── BOM ──────────────────────────────────────────────────────────────────

  group('BOM UTF-8', () {
    test('le fichier commence par le BOM', () {
      final csv = service.buildCsv([], separator: ';', l10n: l10n);

      expect(csv.startsWith('\u{FEFF}'), isTrue);
    });
  });

  // ── En-tête ──────────────────────────────────────────────────────────────

  group('en-tête', () {
    test('20 colonnes après le BOM', () {
      final csv = service.buildCsv([], separator: ';', l10n: l10n);
      final lines = csv.replaceFirst('\u{FEFF}', '').split('\n');
      final headers = lines.first.split(';');

      expect(headers.length, 20);
    });

    test("contient la colonne 'updated_at'", () {
      final csv = service.buildCsv([], separator: ';', l10n: l10n);
      final headerLine = csv.replaceFirst('\u{FEFF}', '').split('\n').first;

      expect(headerLine.contains('updated_at'), isTrue);
    });
  });

  // ── Séparateur ───────────────────────────────────────────────────────────

  group('séparateur', () {
    test('point-virgule dans les données', () {
      final csv = service.buildCsv([bouteille()], separator: ';', l10n: l10n);
      final dataLine = csv.replaceFirst('\u{FEFF}', '').split('\n')[1];

      expect(dataLine.split(';').length, 20);
    });

    test('virgule dans les données', () {
      final csv = service.buildCsv([bouteille()], separator: ',', l10n: l10n);
      // L'en-tête avec la virgule doit avoir 20 champs
      final headerLine = csv.replaceFirst('\u{FEFF}', '').split('\n').first;
      expect(headerLine.split(',').length, 20);
    });
  });

  // ── Échappement ──────────────────────────────────────────────────────────

  group('échappement', () {
    test('champ contenant le séparateur → entouré de guillemets', () {
      final b = bouteille(domaine: 'Château;Test');
      final csv = service.buildCsv([b], separator: ';', l10n: l10n);
      final dataLine = csv.replaceFirst('\u{FEFF}', '').split('\n')[1];

      expect(dataLine.contains('"Château;Test"'), isTrue);
    });

    test('champ avec guillemets → guillemets doublés', () {
      final b = bouteille(domaine: 'Dom "Grand"');
      final csv = service.buildCsv([b], separator: ';', l10n: l10n);

      expect(csv.contains('"Dom ""Grand"""'), isTrue);
    });
  });

  // ── Valeurs null ─────────────────────────────────────────────────────────

  group('valeurs null', () {
    test('cru=null → chaîne vide, pas "null"', () {
      final b = bouteille(cru: null);
      final csv = service.buildCsv([b], separator: ';', l10n: l10n);

      expect(csv.contains('null'), isFalse);
    });

    test('prix_achat=null → chaîne vide', () {
      final b = bouteille(prixAchat: null);
      final csv = service.buildCsv([b], separator: ';', l10n: l10n);

      expect(csv.contains('null'), isFalse);
    });
  });
}
