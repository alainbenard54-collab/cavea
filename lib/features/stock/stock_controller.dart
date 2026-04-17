// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database.dart';
import '../../data/providers.dart';

class StockFilterState {
  final String? couleur;
  final String? appellation;
  final int? millesime;
  final String texte;
  final String sortColumn;
  final bool sortAscending;

  const StockFilterState({
    this.couleur,
    this.appellation,
    this.millesime,
    this.texte = '',
    this.sortColumn = 'domaine',
    this.sortAscending = true,
  });

  bool get hasActiveFilters =>
      couleur != null ||
      appellation != null ||
      millesime != null ||
      texte.isNotEmpty;

  StockFilterState copyWith({
    Object? couleur = _sentinel,
    Object? appellation = _sentinel,
    Object? millesime = _sentinel,
    String? texte,
    String? sortColumn,
    bool? sortAscending,
  }) {
    return StockFilterState(
      couleur: couleur == _sentinel ? this.couleur : couleur as String?,
      appellation:
          appellation == _sentinel ? this.appellation : appellation as String?,
      millesime: millesime == _sentinel ? this.millesime : millesime as int?,
      texte: texte ?? this.texte,
      sortColumn: sortColumn ?? this.sortColumn,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }
}

const _sentinel = Object();

class StockFilterController extends StateNotifier<StockFilterState> {
  StockFilterController() : super(const StockFilterState());

  // Cascade : changer la couleur réinitialise appellation et millésime
  void setCouleur(String? value) => state = state.copyWith(
        couleur: value,
        appellation: null,
        millesime: null,
      );

  // Cascade : changer l'appellation réinitialise le millésime
  void setAppellation(String? value) =>
      state = state.copyWith(appellation: value, millesime: null);

  void setMillesime(int? value) => state = state.copyWith(millesime: value);

  void setTexte(String value) => state = state.copyWith(texte: value);

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

List<Bouteille> _sorted(List<Bouteille> list, String col, bool asc) {
  final s = [...list];
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
        couleur: filters.couleur,
        appellation: filters.appellation,
        millesime: filters.millesime,
        texte: filters.texte.isEmpty ? null : filters.texte,
      )
      .map((list) => _sorted(list, filters.sortColumn, filters.sortAscending));
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

// Filtré par couleur sélectionnée (cascade)
final appellationsProvider = FutureProvider.autoDispose<List<String>>((ref) {
  final couleur = ref.watch(stockFilterProvider.select((s) => s.couleur));
  return ref
      .watch(bouteillesDaoProvider)
      .getDistinctAppellations(couleur: couleur);
});

// Filtré par couleur + appellation sélectionnées (cascade)
final millesimesProvider = FutureProvider.autoDispose<List<int>>((ref) {
  final couleur = ref.watch(stockFilterProvider.select((s) => s.couleur));
  final appellation =
      ref.watch(stockFilterProvider.select((s) => s.appellation));
  return ref
      .watch(bouteillesDaoProvider)
      .getDistinctMillesimes(couleur: couleur, appellation: appellation);
});
