// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:drift/drift.dart';

class Bouteilles extends Table {
  TextColumn get id => text()();
  TextColumn get domaine => text()();
  TextColumn get appellation => text()();
  IntColumn get millesime => integer()();
  TextColumn get couleur => text()();
  TextColumn get cru => text().nullable()();
  TextColumn get contenance => text()();
  TextColumn get emplacement => text()();
  TextColumn get dateEntree => text()();
  TextColumn get dateSortie => text().nullable()();
  RealColumn get prixAchat => real().nullable()();
  IntColumn get gardeMin => integer().nullable()();
  IntColumn get gardeMax => integer().nullable()();
  TextColumn get commentaireEntree => text().nullable()();
  RealColumn get noteDegus => real().nullable()();
  TextColumn get commentaireDegus => text().nullable()();
  TextColumn get fournisseurNom => text().nullable()();
  TextColumn get fournisseurInfos => text().nullable()();
  TextColumn get producteur => text().nullable()();
  TextColumn get updatedAt => text()();

  @override
  Set<Column> get primaryKey => {id};
}
