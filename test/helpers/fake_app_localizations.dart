// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

// ignore_for_file: must_be_immutable
import 'package:cavea/l10n/app_localizations.dart';

/// Stub minimal d'AppLocalizations pour les tests de CsvExportService.
/// Seuls les 20 headers CSV sont implémentés — tout autre appel retourne ''.
class FakeAppLocalizations implements AppLocalizations {
  const FakeAppLocalizations();

  @override
  dynamic noSuchMethod(Invocation invocation) => '';

  @override
  String get csvHeaderId => 'id';
  @override
  String get csvHeaderDomaine => 'domaine';
  @override
  String get csvHeaderAppellation => 'appellation';
  @override
  String get csvHeaderMillesime => 'millesime';
  @override
  String get csvHeaderCouleur => 'couleur';
  @override
  String get csvHeaderCru => 'cru';
  @override
  String get csvHeaderContenance => 'contenance';
  @override
  String get csvHeaderEmplacement => 'emplacement';
  @override
  String get csvHeaderDateEntree => 'date_entree';
  @override
  String get csvHeaderDateSortie => 'date_sortie';
  @override
  String get csvHeaderPrixAchat => 'prix_achat';
  @override
  String get csvHeaderGardeMin => 'garde_min';
  @override
  String get csvHeaderGardeMax => 'garde_max';
  @override
  String get csvHeaderCommentaireEntree => 'commentaire_entree';
  @override
  String get csvHeaderNoteDegus => 'note_degus';
  @override
  String get csvHeaderCommentaireDegus => 'commentaire_degus';
  @override
  String get csvHeaderFournisseurNom => 'fournisseur_nom';
  @override
  String get csvHeaderFournisseurInfos => 'fournisseur_infos';
  @override
  String get csvHeaderProducteur => 'producteur';
  @override
  String get csvHeaderUpdatedAt => 'updated_at';
}
