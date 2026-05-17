// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter_test/flutter_test.dart';
import 'package:cavea/features/bulk_add/bulk_add_controller.dart';

void main() {
  BulkAddState _validState() => BulkAddState(
        domaine: 'Dom',
        appellation: 'App',
        millesime: '2018',
        couleur: 'Rouge',
        dateEntree: DateTime(2026, 1, 1),
        quantiteTotal: 1,
        groupes: const [RepartitionGroup(quantite: 1, emplacement: 'Cave A')],
      );

  // ── état initial ─────────────────────────────────────────────────────────

  group('état initial', () {
    test('domaine et appellation vides, isValid false', () {
      final state = BulkAddState(dateEntree: DateTime(2026, 1, 1));

      expect(state.domaine, '');
      expect(state.appellation, '');
      expect(state.couleur, '');
      expect(state.quantiteTotal, 1);
      expect(state.groupes.length, 1);
      expect(state.isValid, isFalse);
    });
  });

  // ── isValid ───────────────────────────────────────────────────────────────

  group('isValid', () {
    test('true quand tous les champs obligatoires remplis et somme correcte', () {
      expect(_validState().isValid, isTrue);
    });

    test('false si domaine vide', () {
      expect(_validState().copyWith(domaine: '').isValid, isFalse);
    });

    test('false si appellation vide', () {
      expect(_validState().copyWith(appellation: '').isValid, isFalse);
    });

    test('false si millesime vide', () {
      expect(_validState().copyWith(millesime: '').isValid, isFalse);
    });

    test('false si couleur vide', () {
      expect(_validState().copyWith(couleur: '').isValid, isFalse);
    });

    test('false si emplacement invalide', () {
      final state = _validState().copyWith(
        groupes: const [RepartitionGroup(quantite: 1, emplacement: 'Cave>>Mauvais')],
      );
      expect(state.isValid, isFalse);
    });

    test('false si somme groupes ≠ quantiteTotal', () {
      final state = _validState().copyWith(
        quantiteTotal: 3,
        groupes: const [
          RepartitionGroup(quantite: 1, emplacement: 'Cave A'),
          RepartitionGroup(quantite: 1, emplacement: 'Cave B'),
        ],
      );
      expect(state.isValid, isFalse);
    });
  });

  // ── setQuantiteTotal ──────────────────────────────────────────────────────

  group('setQuantiteTotal', () {
    test('1 seul groupe → quantite du groupe ajustée', () {
      final notifier = BulkAddNotifier();
      notifier.setQuantiteTotal(3);

      expect(notifier.state.quantiteTotal, 3);
      expect(notifier.state.groupes[0].quantite, 3);
      expect(notifier.state.sommeGroupes, 3);
    });

    test('2 groupes → répartition conservée', () {
      final notifier = BulkAddNotifier();
      notifier.addGroupe();
      expect(notifier.state.groupes.length, 2);

      notifier.setQuantiteTotal(5);

      expect(notifier.state.groupes[0].quantite, 1);
      expect(notifier.state.groupes[1].quantite, 1);
    });
  });

  // ── addGroupe ─────────────────────────────────────────────────────────────

  group('addGroupe', () {
    test('ajoute un groupe vide', () {
      final notifier = BulkAddNotifier();
      notifier.addGroupe();

      expect(notifier.state.groupes.length, 2);
      expect(notifier.state.groupes.last.quantite, 1);
      expect(notifier.state.groupes.last.emplacement, '');
    });
  });

  // ── removeGroupe ──────────────────────────────────────────────────────────

  group('removeGroupe', () {
    test('supprime le groupe à l\'index donné', () {
      final notifier = BulkAddNotifier();
      notifier.addGroupe();
      expect(notifier.state.groupes.length, 2);

      notifier.removeGroupe(0);

      expect(notifier.state.groupes.length, 1);
    });

    test('ignoré si 1 seul groupe', () {
      final notifier = BulkAddNotifier();
      notifier.removeGroupe(0);

      expect(notifier.state.groupes.length, 1);
    });
  });

  // ── updateGroupe ──────────────────────────────────────────────────────────

  group('updateGroupe', () {
    test('met à jour quantite et emplacement', () {
      final notifier = BulkAddNotifier();
      notifier.updateGroupe(
        0,
        const RepartitionGroup(quantite: 2, emplacement: 'Cave A'),
      );

      expect(notifier.state.groupes[0].quantite, 2);
      expect(notifier.state.groupes[0].emplacement, 'Cave A');
    });
  });

  // ── sommeGroupes ──────────────────────────────────────────────────────────

  group('sommeGroupes', () {
    test('somme des quantités de tous les groupes', () {
      final notifier = BulkAddNotifier();
      notifier.addGroupe();
      notifier.updateGroupe(0, const RepartitionGroup(quantite: 3, emplacement: ''));
      notifier.updateGroupe(1, const RepartitionGroup(quantite: 2, emplacement: ''));

      expect(notifier.state.sommeGroupes, 5);
    });
  });
}
