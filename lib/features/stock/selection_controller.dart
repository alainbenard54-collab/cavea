// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectionState {
  final bool isSelectMode;
  final Set<String> selectedIds;

  const SelectionState({
    this.isSelectMode = false,
    this.selectedIds = const {},
  });

  SelectionState copyWith({bool? isSelectMode, Set<String>? selectedIds}) {
    return SelectionState(
      isSelectMode: isSelectMode ?? this.isSelectMode,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }

  int get count => selectedIds.length;
}

class SelectionController extends StateNotifier<SelectionState> {
  SelectionController() : super(const SelectionState());

  void enterSelectMode(String id) {
    state = SelectionState(
      isSelectMode: true,
      selectedIds: {id},
    );
  }

  void toggleId(String id) {
    if (!state.isSelectMode) return;
    final next = Set<String>.of(state.selectedIds);
    if (next.contains(id)) {
      next.remove(id);
    } else {
      next.add(id);
    }
    state = state.copyWith(selectedIds: next);
  }

  void reset() {
    state = const SelectionState();
  }
}

final selectionProvider =
    StateNotifierProvider.autoDispose<SelectionController, SelectionState>(
  (ref) => SelectionController(),
);
