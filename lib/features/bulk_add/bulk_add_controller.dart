// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter_riverpod/flutter_riverpod.dart';

class RepartitionGroup {
  final int quantite;
  final String emplacement;

  const RepartitionGroup({required this.quantite, required this.emplacement});

  RepartitionGroup copyWith({int? quantite, String? emplacement}) =>
      RepartitionGroup(
        quantite: quantite ?? this.quantite,
        emplacement: emplacement ?? this.emplacement,
      );
}

class BulkAddState {
  final String domaine;
  final String appellation;
  final String millesime;
  final String couleur;
  final String cru;
  final String contenance;
  final String prixAchat;
  final String gardeMin;
  final String gardeMax;
  final String commentaireEntree;
  final String fournisseurNom;
  final String fournisseurInfos;
  final String producteur;
  final DateTime dateEntree;
  final int quantiteTotal;
  final List<RepartitionGroup> groupes;

  const BulkAddState({
    this.domaine = '',
    this.appellation = '',
    this.millesime = '',
    this.couleur = '',
    this.cru = '',
    this.contenance = '75 cl',
    this.prixAchat = '',
    this.gardeMin = '',
    this.gardeMax = '',
    this.commentaireEntree = '',
    this.fournisseurNom = '',
    this.fournisseurInfos = '',
    this.producteur = '',
    required this.dateEntree,
    this.quantiteTotal = 1,
    this.groupes = const [RepartitionGroup(quantite: 1, emplacement: '')],
  });

  int get sommeGroupes => groupes.fold(0, (s, g) => s + g.quantite);

  bool get isValid {
    if (domaine.trim().isEmpty) return false;
    if (appellation.trim().isEmpty) return false;
    if (millesime.trim().isEmpty) return false;
    if (couleur.trim().isEmpty) return false;
    if (quantiteTotal < 1) return false;
    if (sommeGroupes != quantiteTotal) return false;
    if (groupes.any((g) => g.quantite < 1)) return false;
    if (groupes.any((g) => !_emplacementValide(g.emplacement))) return false;
    return true;
  }

  static final _levelRe = RegExp(
    r'^[a-zA-ZÀ-ÿ0-9][a-zA-ZÀ-ÿ0-9 ]*( > [a-zA-ZÀ-ÿ0-9][a-zA-ZÀ-ÿ0-9 ]*)*$',
  );

  static bool _emplacementValide(String e) {
    final t = e.trim();
    if (t.isEmpty) return false;
    return _levelRe.hasMatch(t);
  }

  BulkAddState copyWith({
    String? domaine,
    String? appellation,
    String? millesime,
    String? couleur,
    String? cru,
    String? contenance,
    String? prixAchat,
    String? gardeMin,
    String? gardeMax,
    String? commentaireEntree,
    String? fournisseurNom,
    String? fournisseurInfos,
    String? producteur,
    DateTime? dateEntree,
    int? quantiteTotal,
    List<RepartitionGroup>? groupes,
  }) => BulkAddState(
    domaine: domaine ?? this.domaine,
    appellation: appellation ?? this.appellation,
    millesime: millesime ?? this.millesime,
    couleur: couleur ?? this.couleur,
    cru: cru ?? this.cru,
    contenance: contenance ?? this.contenance,
    prixAchat: prixAchat ?? this.prixAchat,
    gardeMin: gardeMin ?? this.gardeMin,
    gardeMax: gardeMax ?? this.gardeMax,
    commentaireEntree: commentaireEntree ?? this.commentaireEntree,
    fournisseurNom: fournisseurNom ?? this.fournisseurNom,
    fournisseurInfos: fournisseurInfos ?? this.fournisseurInfos,
    producteur: producteur ?? this.producteur,
    dateEntree: dateEntree ?? this.dateEntree,
    quantiteTotal: quantiteTotal ?? this.quantiteTotal,
    groupes: groupes ?? this.groupes,
  );
}

class BulkAddNotifier extends StateNotifier<BulkAddState> {
  BulkAddNotifier()
      : super(BulkAddState(dateEntree: DateTime.now()));

  void set(BulkAddState Function(BulkAddState) updater) {
    state = updater(state);
  }

  void setQuantiteTotal(int v) {
    final clamped = v < 1 ? 1 : v;
    // Ajuster le premier groupe si un seul groupe et correspond à l'ancienne valeur
    final groupes = state.groupes.length == 1
        ? [state.groupes[0].copyWith(quantite: clamped)]
        : state.groupes;
    state = state.copyWith(quantiteTotal: clamped, groupes: groupes);
  }

  void updateGroupe(int index, RepartitionGroup groupe) {
    final list = [...state.groupes];
    list[index] = groupe;
    state = state.copyWith(groupes: list);
  }

  void addGroupe() {
    state = state.copyWith(
      groupes: [...state.groupes, const RepartitionGroup(quantite: 1, emplacement: '')],
    );
  }

  void removeGroupe(int index) {
    if (state.groupes.length <= 1) return;
    final list = [...state.groupes]..removeAt(index);
    state = state.copyWith(groupes: list);
  }
}

final bulkAddProvider =
    StateNotifierProvider.autoDispose<BulkAddNotifier, BulkAddState>(
  (_) => BulkAddNotifier(),
);
