// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/daos/bouteille_dao.dart';
import '../../data/database.dart';
import '../../data/providers.dart';

final locationLeavesProvider = StreamProvider<List<LocationLeaf>>((ref) {
  return ref.watch(bouteillesDaoProvider).watchLocationStats();
});

// autoDispose : réinitialisé à false quand l'utilisateur quitte l'onglet Emplacements.
final includeSublocationsProvider = StateProvider.autoDispose<bool>((ref) => false);

final locationBottleListProvider =
    StreamProvider.family<List<Bouteille>, (String, bool)>((ref, params) {
  final (emplacement, includeSublocations) = params;
  return ref.watch(bouteillesDaoProvider).watchBouteillesParEmplacement(
        emplacement,
        includeSublocations: includeSublocations,
      );
});
