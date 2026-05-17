// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter_test/flutter_test.dart';
import 'package:cavea/core/maturity/maturity_service.dart';
import 'package:cavea/features/stock/stock_controller.dart';

void main() {
  StockFilterController _controller() => StockFilterController();

  // ── état initial ─────────────────────────────────────────────────────────

  group('état initial', () {
    test('tous les filtres à leur valeur par défaut', () {
      final ctrl = _controller();
      final s = ctrl.state;

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
      expect(_controller().state.hasActiveFilters, isFalse);
    });

    test('true si texte renseigné', () {
      final ctrl = _controller();
      ctrl.setTexte('margaux');
      expect(ctrl.state.hasActiveFilters, isTrue);
    });

    test('true si couleur sélectionnée', () {
      final ctrl = _controller();
      ctrl.toggleCouleur('Rouge');
      expect(ctrl.state.hasActiveFilters, isTrue);
    });

    test('true si maturité sélectionnée', () {
      final ctrl = _controller();
      ctrl.toggleMaturite(MaturityLevel.optimal);
      expect(ctrl.state.hasActiveFilters, isTrue);
    });
  });

  // ── toggleCouleur ────────────────────────────────────────────────────────

  group('toggleCouleur', () {
    test('ajoute la couleur', () {
      final ctrl = _controller();
      ctrl.toggleCouleur('Rouge');
      expect(ctrl.state.couleurs, {'Rouge'});
    });

    test('retire la couleur si déjà présente', () {
      final ctrl = _controller();
      ctrl.toggleCouleur('Rouge');
      ctrl.toggleCouleur('Rouge');
      expect(ctrl.state.couleurs, isEmpty);
    });

    test('plusieurs couleurs simultanées', () {
      final ctrl = _controller();
      ctrl.toggleCouleur('Rouge');
      ctrl.toggleCouleur('Blanc');
      expect(ctrl.state.couleurs, {'Rouge', 'Blanc'});
    });
  });

  // ── toggleMaturite ───────────────────────────────────────────────────────

  group('toggleMaturite', () {
    test('active le filtre et bascule le tri sur gardeMin', () {
      final ctrl = _controller();
      ctrl.toggleMaturite(MaturityLevel.optimal);

      expect(ctrl.state.maturites, {MaturityLevel.optimal});
      expect(ctrl.state.sortColumn, 'gardeMin');
    });

    test('désactive le filtre — sortColumn reste gardeMin', () {
      final ctrl = _controller();
      ctrl.toggleMaturite(MaturityLevel.optimal);
      ctrl.toggleMaturite(MaturityLevel.optimal);

      expect(ctrl.state.maturites, isEmpty);
      expect(ctrl.state.sortColumn, 'gardeMin');
    });

    test('plusieurs niveaux de maturité actifs simultanément', () {
      final ctrl = _controller();
      ctrl.toggleMaturite(MaturityLevel.optimal);
      ctrl.toggleMaturite(MaturityLevel.tropJeune);

      expect(ctrl.state.maturites, {MaturityLevel.optimal, MaturityLevel.tropJeune});
    });
  });

  // ── setSort ──────────────────────────────────────────────────────────────

  group('setSort', () {
    test('même colonne → inverse l\'ordre', () {
      final ctrl = _controller();
      ctrl.setSort('millesime');
      expect(ctrl.state.sortColumn, 'millesime');
      expect(ctrl.state.sortAscending, isTrue);

      ctrl.setSort('millesime');
      expect(ctrl.state.sortAscending, isFalse);
    });

    test('nouvelle colonne → ordre remis à asc', () {
      final ctrl = _controller();
      ctrl.setSort('millesime');
      ctrl.setSort('millesime');
      expect(ctrl.state.sortAscending, isFalse);

      ctrl.setSort('couleur');
      expect(ctrl.state.sortColumn, 'couleur');
      expect(ctrl.state.sortAscending, isTrue);
    });
  });

  // ── reset ────────────────────────────────────────────────────────────────

  group('reset', () {
    test('efface tous les filtres et remet le tri par défaut', () {
      final ctrl = _controller();
      ctrl.toggleCouleur('Rouge');
      ctrl.toggleMaturite(MaturityLevel.aBoireUrgent);
      ctrl.setTexte('margaux');
      ctrl.setSort('millesime');

      ctrl.reset();
      final s = ctrl.state;

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
      final ctrl = _controller();
      ctrl.setAppellation('Pomerol');
      expect(ctrl.state.appellation, 'Pomerol');
      expect(ctrl.state.hasActiveFilters, isTrue);
    });

    test('setMillesime → millesime mis à jour', () {
      final ctrl = _controller();
      ctrl.setMillesime(2015);
      expect(ctrl.state.millesime, 2015);
      expect(ctrl.state.hasActiveFilters, isTrue);
    });

    test('setAppellation(null) → filtre effacé', () {
      final ctrl = _controller();
      ctrl.setAppellation('Pomerol');
      ctrl.setAppellation(null);
      expect(ctrl.state.appellation, isNull);
    });
  });
}
