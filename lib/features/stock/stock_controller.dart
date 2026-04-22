// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/maturity/maturity_service.dart';
import '../../data/database.dart';
import '../../data/providers.dart';

class StockFilterState {
  final Set<String> couleurs;
  final String? appellation;
  final int? millesime;
  final String texte;
  final String sortColumn;
  final bool sortAscending;
  final MaturityLevel? maturite;

  const StockFilterState({
    this.couleurs = const {},
    this.appellation,
    this.millesime,
    this.texte = '',
    this.sortColumn = 'domaine',
    this.sortAscending = true,
    this.maturite,
  });

  bool get hasActiveFilters =>
      couleurs.isNotEmpty ||
      appellation != null ||
      millesime != null ||
      texte.isNotEmpty ||
      maturite != null;

  StockFilterState copyWith({
    Set<String>? couleurs,
    Object? appellation = _sentinel,
    Object? millesime = _sentinel,
    String? texte,
    String? sortColumn,
    bool? sortAscending,
    Object? maturite = _sentinel,
  }) {
    return StockFilterState(
      couleurs: couleurs ?? this.couleurs,
      appellation:
          appellation == _sentinel ? this.appellation : appellation as String?,
      millesime: millesime == _sentinel ? this.millesime : millesime as int?,
      texte: texte ?? this.texte,
      sortColumn: sortColumn ?? this.sortColumn,
      sortAscending: sortAscending ?? this.sortAscending,
      maturite: maturite == _sentinel
          ? this.maturite
          : maturite as MaturityLevel?,
    );
  }
}

const _sentinel = Object();

class StockFilterController extends StateNotifier<StockFilterState> {
  StockFilterController() : super(const StockFilterState());

  void toggleCouleur(String value) {
    final updated = Set<String>.from(state.couleurs);
    if (updated.contains(value)) {
      updated.remove(value);
    } else {
      updated.add(value);
    }
    state = state.copyWith(couleurs: updated, appellation: null, millesime: null);
  }

  void clearCouleurs() =>
      state = state.copyWith(couleurs: {}, appellation: null, millesime: null);

  void setAppellation(String? value) =>
      state = state.copyWith(appellation: value, millesime: null);

  void setMillesime(int? value) => state = state.copyWith(millesime: value);

  void setTexte(String value) => state = state.copyWith(texte: value);

  void setMaturite(MaturityLevel? value) {
    state = state.copyWith(maturite: value);
  }

  void setSort(String column) {
    if (state.sortColumn == column) {
      state = state.copyWith(sortAscending: !state.sortAscending);
    } else {
      state = state.copyWith(sortColumn: column, sortAscending: true);
    }
  }

  void reset() => state = const StockFilterState();
}

final stockFilterProvider =
    StateNotifierProvider<StockFilterController, StockFilterState>(
  (ref) => StockFilterController(),
);

List<Bouteille> _sorted(
  List<Bouteille> list,
  String col,
  bool asc,
  MaturityLevel? maturiteFilter,
) {
  final s = [...list];

  if (maturiteFilter != null) {
    // Tri par urgence secondaire dans le groupe de maturité actif
    s.sort((a, b) {
      final scoreA = urgencyScore(
        millesime: a.millesime,
        gardeMin: a.gardeMin,
        gardeMax: a.gardeMax,
      );
      final scoreB = urgencyScore(
        millesime: b.millesime,
        gardeMin: b.gardeMin,
        gardeMax: b.gardeMax,
      );
      return scoreB.compareTo(scoreA); // décroissant = plus urgent en premier
    });
    return s;
  }

  int cmp(Bouteille a, Bouteille b) => switch (col) {
        'appellation' => a.appellation.compareTo(b.appellation),
        'millesime' => a.millesime.compareTo(b.millesime),
        'couleur' => a.couleur.compareTo(b.couleur),
        'emplacement' => a.emplacement.compareTo(b.emplacement),
        'gardeMin' => (a.gardeMin ?? 0).compareTo(b.gardeMin ?? 0),
        'prixAchat' => (a.prixAchat ?? 0).compareTo(b.prixAchat ?? 0),
        _ => a.domaine.compareTo(b.domaine),
      };
  s.sort((a, b) => asc ? cmp(a, b) : cmp(b, a));
  return s;
}

final stockProvider = StreamProvider.autoDispose<List<Bouteille>>((ref) {
  final filters = ref.watch(stockFilterProvider);
  final dao = ref.watch(bouteillesDaoProvider);
  return dao
      .watchStockFiltered(
        couleurs: filters.couleurs.isEmpty ? null : filters.couleurs.toList(),
        appellation: filters.appellation,
        millesime: filters.millesime,
        texte: filters.texte.isEmpty ? null : filters.texte,
      )
      .map((list) {
    var result = list;
    // Filtre maturité appliqué en Dart
    if (filters.maturite != null) {
      result = result.where((b) {
        final level = computeMaturity(
          millesime: b.millesime,
          gardeMin: b.gardeMin,
          gardeMax: b.gardeMax,
        );
        return level == filters.maturite;
      }).toList();
    }
    return _sorted(result, filters.sortColumn, filters.sortAscending, filters.maturite);
  });
});

final stockTotalCountProvider = StreamProvider.autoDispose<int>((ref) {
  return ref
      .watch(bouteillesDaoProvider)
      .watchStock()
      .map((list) => list.length);
});

final couleursProvider = FutureProvider.autoDispose<List<String>>((ref) {
  return ref.watch(bouteillesDaoProvider).getDistinctCouleurs();
});

final appellationsProvider = FutureProvider.autoDispose<List<String>>((ref) {
  final couleurs = ref.watch(stockFilterProvider.select((s) => s.couleurs));
  // cascade : si une seule couleur sélectionnée on filtre les appellations
  final couleur = couleurs.length == 1 ? couleurs.first : null;
  return ref
      .watch(bouteillesDaoProvider)
      .getDistinctAppellations(couleur: couleur);
});

final millesimesProvider = FutureProvider.autoDispose<List<int>>((ref) {
  final couleurs = ref.watch(stockFilterProvider.select((s) => s.couleurs));
  final appellation =
      ref.watch(stockFilterProvider.select((s) => s.appellation));
  final couleur = couleurs.length == 1 ? couleurs.first : null;
  return ref
      .watch(bouteillesDaoProvider)
      .getDistinctMillesimes(couleur: couleur, appellation: appellation);
});
