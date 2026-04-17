// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'tables/bouteilles.dart';
import 'daos/bouteille_dao.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Bouteilles])
class AppDatabase extends _$AppDatabase {
  AppDatabase(String dbPath) : super(NativeDatabase(File(dbPath)));

  @override
  int get schemaVersion => 1;

  late final bouteilleDao = BouteilleDao(this);
}
