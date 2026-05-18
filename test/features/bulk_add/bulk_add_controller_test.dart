// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cavea/features/bulk_add/bulk_add_controller.dart';

void main() {
  BulkAddNotifier makeNotifier() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container.read(bulkAddProvider.notifier);
  }

  BulkAddState validState() => BulkAddState(
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
      expect(validState().isValid, isTrue);
    });

    test('false si domaine vide', () {
      expect(validState().copyWith(domaine: '').isValid, isFalse);
    });

    test('false si appellation vide', () {
      expect(validState().copyWith(appellation: '').isValid, isFalse);
    });

    test('false si millesime vide', () {
      expect(validState().copyWith(millesime: '').isValid, isFalse);
    });

    test('false si couleur vide', () {
      expect(validState().copyWith(couleur: '').isValid, isFalse);
    });

    test('false si emplacement invalide', () {
      final state = validState().copyWith(
        groupes: const [RepartitionGroup(quantite: 1, emplacement: 'Cave>>Mauvais')],
      );
      expect(state.isValid, isFalse);
    });

    test('false si somme groupes ≠ quantiteTotal', () {
      final state = validState().copyWith(
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
      final notifier = makeNotifier();
      notifier.setQuantiteTotal(3);

      expect(notifier.stateOrNull!.quantiteTotal, 3);
      expect(notifier.stateOrNull!.groupes[0].quantite, 3);
      expect(notifier.stateOrNull!.sommeGroupes, 3);
    });

    test('2 groupes → répartition conservée', () {
      final notifier = makeNotifier();
      notifier.addGroupe();
      expect(notifier.stateOrNull!.groupes.length, 2);

      notifier.setQuantiteTotal(5);

      expect(notifier.stateOrNull!.groupes[0].quantite, 1);
      expect(notifier.stateOrNull!.groupes[1].quantite, 1);
    });
  });

  // ── addGroupe ─────────────────────────────────────────────────────────────

  group('addGroupe', () {
    test('ajoute un groupe vide', () {
      final notifier = makeNotifier();
      notifier.addGroupe();

      expect(notifier.stateOrNull!.groupes.length, 2);
      expect(notifier.stateOrNull!.groupes.last.quantite, 1);
      expect(notifier.stateOrNull!.groupes.last.emplacement, '');
    });
  });

  // ── removeGroupe ──────────────────────────────────────────────────────────

  group('removeGroupe', () {
    test('supprime le groupe à l\'index donné', () {
      final notifier = makeNotifier();
      notifier.addGroupe();
      expect(notifier.stateOrNull!.groupes.length, 2);

      notifier.removeGroupe(0);

      expect(notifier.stateOrNull!.groupes.length, 1);
    });

    test('ignoré si 1 seul groupe', () {
      final notifier = makeNotifier();
      notifier.removeGroupe(0);

      expect(notifier.stateOrNull!.groupes.length, 1);
    });
  });

  // ── updateGroupe ──────────────────────────────────────────────────────────

  group('updateGroupe', () {
    test('met à jour quantite et emplacement', () {
      final notifier = makeNotifier();
      notifier.updateGroupe(
        0,
        const RepartitionGroup(quantite: 2, emplacement: 'Cave A'),
      );

      expect(notifier.stateOrNull!.groupes[0].quantite, 2);
      expect(notifier.stateOrNull!.groupes[0].emplacement, 'Cave A');
    });
  });

  // ── sommeGroupes ──────────────────────────────────────────────────────────

  group('sommeGroupes', () {
    test('somme des quantités de tous les groupes', () {
      final notifier = makeNotifier();
      notifier.addGroupe();
      notifier.updateGroupe(0, const RepartitionGroup(quantite: 3, emplacement: ''));
      notifier.updateGroupe(1, const RepartitionGroup(quantite: 2, emplacement: ''));

      expect(notifier.stateOrNull!.sommeGroupes, 5);
    });
  });
}
