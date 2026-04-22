// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/maturity/maturity_service.dart';
import '../../../data/database.dart';
import '../../../data/providers.dart';

class QuoiBoireFilterController extends StateNotifier<String?> {
  QuoiBoireFilterController() : super(null);

  void setCouleur(String? value) => state = value;
}

final quoiBoireFilterProvider =
    StateNotifierProvider<QuoiBoireFilterController, String?>(
  (ref) => QuoiBoireFilterController(),
);

typedef BouteilleAvecMaturite = ({Bouteille bouteille, MaturityLevel maturite});

final quoiBoireProvider =
    StreamProvider.autoDispose<List<BouteilleAvecMaturite>>((ref) {
  final couleur = ref.watch(quoiBoireFilterProvider);
  final dao = ref.watch(bouteillesDaoProvider);
  return dao.watchStockFiltered(couleur: couleur).map((list) {
    final enriched = list.map((b) {
      final level = computeMaturity(
        millesime: b.millesime,
        gardeMin: b.gardeMin,
        gardeMax: b.gardeMax,
      );
      return (bouteille: b, maturite: level);
    }).toList();
    enriched.sort(
      (a, b) =>
          maturitySortOrder(a.maturite).compareTo(maturitySortOrder(b.maturite)),
    );
    return enriched;
  });
});

final quoiBoireCouleursProvider = FutureProvider.autoDispose<List<String>>(
  (ref) => ref.watch(bouteillesDaoProvider).getDistinctCouleurs(),
);
