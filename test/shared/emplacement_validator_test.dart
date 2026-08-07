// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter_test/flutter_test.dart';
import 'package:cavea/shared/emplacement_validator.dart';

void main() {
  group('EmplacementValidator.isValid', () {
    group('valeurs valides', () {
      test('niveau unique simple', () {
        expect(EmplacementValidator.isValid('Cave'), isTrue);
      });

      test('niveau unique avec espace interne', () {
        expect(EmplacementValidator.isValid('Cave principale'), isTrue);
      });

      test('hiérarchie multi-niveaux avec lettre accentuée', () {
        expect(
          EmplacementValidator.isValid('Cave > Étagère 3'),
          isTrue,
        );
      });

      test('hiérarchie à 3 niveaux', () {
        expect(
          EmplacementValidator.isValid('Cave > Rangée A > Position 2'),
          isTrue,
        );
      });

      test('underscore dans un niveau', () {
        expect(
          EmplacementValidator.isValid(
            'Liebherr Vinothek > sortie_réfrigérateur ou habitat',
          ),
          isTrue,
        );
      });

      test('tiret dans un niveau', () {
        expect(EmplacementValidator.isValid('Cave-à-vin'), isTrue);
      });

      test('underscore et tiret combinés', () {
        expect(
          EmplacementValidator.isValid('Niveau_1 > Sous-niveau_2'),
          isTrue,
        );
      });

      test('espaces superflus en début/fin sont retirés (trim)', () {
        expect(EmplacementValidator.isValid('  Cave  '), isTrue);
      });
    });

    group('valeurs invalides', () {
      test('chaîne vide', () {
        expect(EmplacementValidator.isValid(''), isFalse);
      });

      test('chaîne composée uniquement d\'espaces', () {
        expect(EmplacementValidator.isValid('   '), isFalse);
      });

      test('commence par underscore', () {
        expect(EmplacementValidator.isValid('_Cave'), isFalse);
      });

      test('commence par tiret', () {
        expect(EmplacementValidator.isValid('-Cave'), isFalse);
      });

      test('séparateur mal formé (sans espaces autour de >)', () {
        expect(EmplacementValidator.isValid('Cave>Rangée'), isFalse);
      });

      test('niveau vide entre deux séparateurs', () {
        expect(EmplacementValidator.isValid('Cave >  > Position'), isFalse);
      });

      test('niveau final vide après séparateur final', () {
        expect(EmplacementValidator.isValid('Cave > '), isFalse);
      });

      test('caractère non autorisé (apostrophe)', () {
        expect(EmplacementValidator.isValid("L'entrée"), isFalse);
      });

      test('caractère non autorisé (parenthèses)', () {
        expect(EmplacementValidator.isValid('Cave (haut)'), isFalse);
      });

      test('séparateur avec double espace après >', () {
        expect(EmplacementValidator.isValid('Cave >  Rack'), isFalse);
      });

      test('séparateur avec tabulation', () {
        expect(EmplacementValidator.isValid('Cave >\tRack'), isFalse);
      });

      test('séparateur sans espace avant >', () {
        expect(EmplacementValidator.isValid('Cave> Rack'), isFalse);
      });

      test('séparateur sans espace après >', () {
        expect(EmplacementValidator.isValid('Cave >Rack'), isFalse);
      });

      test('caractère non autorisé (signe multiplié ×)', () {
        expect(EmplacementValidator.isValid('Cave × 3'), isFalse);
      });

      test('caractère non autorisé (signe divisé ÷)', () {
        expect(EmplacementValidator.isValid('Cave ÷ 2'), isFalse);
      });
    });
  });
}
