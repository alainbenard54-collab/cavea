// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cavea/core/maturity/maturity_service.dart';
import 'package:cavea/features/stock/stock_controller.dart';

void main() {
  StockFilterController makeController() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container.read(stockFilterProvider.notifier);
  }

  // ── état initial ─────────────────────────────────────────────────────────

  group('état initial', () {
    test('tous les filtres à leur valeur par défaut', () {
      final ctrl = makeController();
      final s = ctrl.stateOrNull!;

      expect(s.couleurs, isEmpty);
      expect(s.appellation, isNull);
      expect(s.millesime, isNull);
      expect(s.texte, '');
      expect(s.sortColumn, 'domaine');
      expect(s.sortAscending, isTrue);
      expect(s.maturites, isEmpty);
    });
  });

  // ── hasActiveFilters ─────────────────────────────────────────────────────

  group('hasActiveFilters', () {
    test('false si état initial', () {
      expect(makeController().stateOrNull!.hasActiveFilters, isFalse);
    });

    test('true si texte renseigné', () {
      final ctrl = makeController();
      ctrl.setTexte('margaux');
      expect(ctrl.stateOrNull!.hasActiveFilters, isTrue);
    });

    test('true si couleur sélectionnée', () {
      final ctrl = makeController();
      ctrl.toggleCouleur('Rouge');
      expect(ctrl.stateOrNull!.hasActiveFilters, isTrue);
    });

    test('true si maturité sélectionnée', () {
      final ctrl = makeController();
      ctrl.toggleMaturite(MaturityLevel.optimal);
      expect(ctrl.stateOrNull!.hasActiveFilters, isTrue);
    });
  });

  // ── toggleCouleur ────────────────────────────────────────────────────────

  group('toggleCouleur', () {
    test('ajoute la couleur', () {
      final ctrl = makeController();
      ctrl.toggleCouleur('Rouge');
      expect(ctrl.stateOrNull!.couleurs, {'Rouge'});
    });

    test('retire la couleur si déjà présente', () {
      final ctrl = makeController();
      ctrl.toggleCouleur('Rouge');
      ctrl.toggleCouleur('Rouge');
      expect(ctrl.stateOrNull!.couleurs, isEmpty);
    });

    test('plusieurs couleurs simultanées', () {
      final ctrl = makeController();
      ctrl.toggleCouleur('Rouge');
      ctrl.toggleCouleur('Blanc');
      expect(ctrl.stateOrNull!.couleurs, {'Rouge', 'Blanc'});
    });
  });

  // ── toggleMaturite ───────────────────────────────────────────────────────

  group('toggleMaturite', () {
    test('active le filtre et bascule le tri sur gardeMin', () {
      final ctrl = makeController();
      ctrl.toggleMaturite(MaturityLevel.optimal);

      expect(ctrl.stateOrNull!.maturites, {MaturityLevel.optimal});
      expect(ctrl.stateOrNull!.sortColumn, 'gardeMin');
    });

    test('désactive le filtre — sortColumn reste gardeMin', () {
      final ctrl = makeController();
      ctrl.toggleMaturite(MaturityLevel.optimal);
      ctrl.toggleMaturite(MaturityLevel.optimal);

      expect(ctrl.stateOrNull!.maturites, isEmpty);
      expect(ctrl.stateOrNull!.sortColumn, 'gardeMin');
    });

    test('plusieurs niveaux de maturité actifs simultanément', () {
      final ctrl = makeController();
      ctrl.toggleMaturite(MaturityLevel.optimal);
      ctrl.toggleMaturite(MaturityLevel.tropJeune);

      expect(ctrl.stateOrNull!.maturites, {MaturityLevel.optimal, MaturityLevel.tropJeune});
    });
  });

  // ── setSort ──────────────────────────────────────────────────────────────

  group('setSort', () {
    test('même colonne → inverse l\'ordre', () {
      final ctrl = makeController();
      ctrl.setSort('millesime');
      expect(ctrl.stateOrNull!.sortColumn, 'millesime');
      expect(ctrl.stateOrNull!.sortAscending, isTrue);

      ctrl.setSort('millesime');
      expect(ctrl.stateOrNull!.sortAscending, isFalse);
    });

    test('nouvelle colonne → ordre remis à asc', () {
      final ctrl = makeController();
      ctrl.setSort('millesime');
      ctrl.setSort('millesime');
      expect(ctrl.stateOrNull!.sortAscending, isFalse);

      ctrl.setSort('couleur');
      expect(ctrl.stateOrNull!.sortColumn, 'couleur');
      expect(ctrl.stateOrNull!.sortAscending, isTrue);
    });
  });

  // ── reset ────────────────────────────────────────────────────────────────

  group('reset', () {
    test('efface tous les filtres et remet le tri par défaut', () {
      final ctrl = makeController();
      ctrl.toggleCouleur('Rouge');
      ctrl.toggleMaturite(MaturityLevel.aBoireUrgent);
      ctrl.setTexte('margaux');
      ctrl.setSort('millesime');

      ctrl.reset();
      final s = ctrl.stateOrNull!;

      expect(s.couleurs, isEmpty);
      expect(s.maturites, isEmpty);
      expect(s.texte, '');
      expect(s.sortColumn, 'domaine');
      expect(s.sortAscending, isTrue);
    });
  });

  // ── setAppellation / setMillesime / setTexte ─────────────────────────────

  group('autres filtres', () {
    test('setAppellation → appellation mise à jour', () {
      final ctrl = makeController();
      ctrl.setAppellation('Pomerol');
      expect(ctrl.stateOrNull!.appellation, 'Pomerol');
      expect(ctrl.stateOrNull!.hasActiveFilters, isTrue);
    });

    test('setMillesime → millesime mis à jour', () {
      final ctrl = makeController();
      ctrl.setMillesime(2015);
      expect(ctrl.stateOrNull!.millesime, 2015);
      expect(ctrl.stateOrNull!.hasActiveFilters, isTrue);
    });

    test('setAppellation(null) → filtre effacé', () {
      final ctrl = makeController();
      ctrl.setAppellation('Pomerol');
      ctrl.setAppellation(null);
      expect(ctrl.stateOrNull!.appellation, isNull);
    });
  });
}
