// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../core/config_service.dart';

enum SetupStep { modeChoice, pathInput, confirmation }

class SetupState {
  final SetupStep step;
  final String selectedMode;
  final String folderPath;
  final String? errorMessage;

  const SetupState({
    this.step = SetupStep.modeChoice,
    this.selectedMode = 'local',
    this.folderPath = '',
    this.errorMessage,
  });

  SetupState copyWith({
    SetupStep? step,
    String? selectedMode,
    String? folderPath,
    String? errorMessage,
  }) {
    return SetupState(
      step: step ?? this.step,
      selectedMode: selectedMode ?? this.selectedMode,
      folderPath: folderPath ?? this.folderPath,
      errorMessage: errorMessage,
    );
  }
}

class SetupController extends StateNotifier<SetupState> {
  SetupController() : super(const SetupState());

  void selectMode(String mode) {
    if (mode == 'local') {
      state = state.copyWith(selectedMode: mode, step: SetupStep.pathInput);
    }
    // Modes 2/3 : non disponibles, on reste sur l'écran de choix
  }

  void setFolderPath(String path) {
    state = state.copyWith(folderPath: path, errorMessage: null);
  }

  bool validateAndAdvance() {
    final dir = Directory(state.folderPath);
    if (state.folderPath.isEmpty || !dir.existsSync()) {
      state = state.copyWith(
        errorMessage: 'Le dossier spécifié n\'existe pas.',
      );
      return false;
    }
    state = state.copyWith(step: SetupStep.confirmation, errorMessage: null);
    return true;
  }

  Future<AppConfig> confirm() async {
    final dbPath = p.join(state.folderPath, 'cave.db');
    final config = AppConfig(storageMode: state.selectedMode, dbPath: dbPath);
    await configService.save(config);
    return config;
  }

  void backToPathInput() {
    state = state.copyWith(step: SetupStep.pathInput, errorMessage: null);
  }
}

final setupControllerProvider =
    StateNotifierProvider.autoDispose<SetupController, SetupState>(
      (ref) => SetupController(),
    );
