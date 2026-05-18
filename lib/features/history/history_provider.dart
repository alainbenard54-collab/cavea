// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database.dart';
import '../../data/providers.dart';

final historyProvider = StreamProvider<List<Bouteille>>((ref) {
  return ref.watch(bouteillesDaoProvider).watchHistorique();
});

class _HistorySearchNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String value) => state = value;
}

final historySearchProvider =
    NotifierProvider<_HistorySearchNotifier, String>(_HistorySearchNotifier.new);
