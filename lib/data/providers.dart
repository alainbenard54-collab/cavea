// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'database.dart';
import 'daos/bouteille_dao.dart';

// Overridé dans ProviderScope après configuration (voir main.dart)
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('appDatabaseProvider must be overridden'),
);

final bouteillesDaoProvider = Provider<BouteilleDao>(
  (ref) => ref.watch(appDatabaseProvider).bouteilleDao,
);
