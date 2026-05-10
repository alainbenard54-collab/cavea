// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/daos/bouteille_dao.dart';
import '../../data/database.dart';
import '../../data/providers.dart';

final locationLeavesProvider = StreamProvider<List<LocationLeaf>>((ref) {
  return ref.watch(bouteillesDaoProvider).watchLocationStats();
});

// Toujours match exact — les stats agrègent les enfants en Dart (pas en SQL).
final locationBottleListProvider =
    StreamProvider.family<List<Bouteille>, String>((ref, emplacement) {
  return ref.watch(bouteillesDaoProvider).watchBouteillesParEmplacement(emplacement);
});
