// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter_test/flutter_test.dart';
import 'package:cavea/core/maturity/maturity_service.dart';

void main() {
  group('computeMaturity', () {
    group('sansDonnee', () {
      test('gardeMin null', () {
        expect(
          computeMaturity(millesime: 2010, gardeMin: null, gardeMax: 10, annee: 2026),
          MaturityLevel.sansDonnee,
        );
      });

      test('gardeMax null', () {
        expect(
          computeMaturity(millesime: 2010, gardeMin: 5, gardeMax: null, annee: 2026),
          MaturityLevel.sansDonnee,
        );
      });

      test('gardeMin égal à 0', () {
        expect(
          computeMaturity(millesime: 2010, gardeMin: 0, gardeMax: 10, annee: 2026),
          MaturityLevel.sansDonnee,
        );
      });

      test('millesime égal à 0', () {
        expect(
          computeMaturity(millesime: 0, gardeMin: 5, gardeMax: 10, annee: 2026),
          MaturityLevel.sansDonnee,
        );
      });
    });

    group('tropJeune', () {
      test('âge < gardeMin', () {
        // age = 2026 - 2020 = 6, gardeMin = 7
        expect(
          computeMaturity(millesime: 2020, gardeMin: 7, gardeMax: 15, annee: 2026),
          MaturityLevel.tropJeune,
        );
      });
    });

    group('optimal', () {
      test('âge = gardeMin (limite inférieure)', () {
        // age = 2026 - 2019 = 7 = gardeMin
        expect(
          computeMaturity(millesime: 2019, gardeMin: 7, gardeMax: 15, annee: 2026),
          MaturityLevel.optimal,
        );
      });

      test('âge dans la fenêtre de garde', () {
        // age = 2026 - 2015 = 11
        expect(
          computeMaturity(millesime: 2015, gardeMin: 5, gardeMax: 15, annee: 2026),
          MaturityLevel.optimal,
        );
      });

      test('âge = gardeMax (limite supérieure)', () {
        // age = 2026 - 2011 = 15 = gardeMax
        expect(
          computeMaturity(millesime: 2011, gardeMin: 5, gardeMax: 15, annee: 2026),
          MaturityLevel.optimal,
        );
      });
    });

    group('aBoireUrgent', () {
      test('âge > gardeMax', () {
        // age = 2026 - 2010 = 16 > gardeMax 15
        expect(
          computeMaturity(millesime: 2010, gardeMin: 5, gardeMax: 15, annee: 2026),
          MaturityLevel.aBoireUrgent,
        );
      });
    });
  });

  group('urgencyScore', () {
    test('aBoireUrgent : score = age - gardeMax (positif)', () {
      // age = 2026 - 2005 = 21, gardeMax = 10 → score = 11
      expect(
        urgencyScore(millesime: 2005, gardeMin: 5, gardeMax: 10, annee: 2026),
        11,
      );
    });

    test('optimal : score = age - gardeMax (négatif)', () {
      // age = 2026 - 2014 = 12, gardeMax = 15 → score = -3
      expect(
        urgencyScore(millesime: 2014, gardeMin: 5, gardeMax: 15, annee: 2026),
        -3,
      );
    });

    test('tropJeune : score = age - gardeMin (négatif)', () {
      // age = 2026 - 2022 = 4, gardeMin = 7 → score = -3
      expect(
        urgencyScore(millesime: 2022, gardeMin: 7, gardeMax: 15, annee: 2026),
        -3,
      );
    });

    test('sansDonnee : score = 0', () {
      expect(
        urgencyScore(millesime: 2010, gardeMin: null, gardeMax: null, annee: 2026),
        0,
      );
    });
  });

  group('maturitySortOrder', () {
    test('ordre relatif : aBoireUrgent < optimal < tropJeune < sansDonnee', () {
      final orders = [
        maturitySortOrder(MaturityLevel.aBoireUrgent),
        maturitySortOrder(MaturityLevel.optimal),
        maturitySortOrder(MaturityLevel.tropJeune),
        maturitySortOrder(MaturityLevel.sansDonnee),
      ];
      for (var i = 0; i < orders.length - 1; i++) {
        expect(orders[i], lessThan(orders[i + 1]));
      }
    });
  });
}
