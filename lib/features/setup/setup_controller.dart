// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../core/config_service.dart';
import '../../services/drive_storage_adapter.dart';

enum SetupStep {
  modeChoice,
  pathInput,      // Mode 1 : saisie du chemin
  confirmation,   // Mode 1 : confirmation
  driveAuth,      // Mode 2 : authentification Google
  driveChoice,    // Mode 2 : nouvelle cave ou télécharger
}

class SetupState {
  final SetupStep step;
  final String selectedMode;
  final String folderPath;
  final String? errorMessage;
  final bool isLoading;

  const SetupState({
    this.step = SetupStep.modeChoice,
    this.selectedMode = 'local',
    this.folderPath = '',
    this.errorMessage,
    this.isLoading = false,
  });

  SetupState copyWith({
    SetupStep? step,
    String? selectedMode,
    String? folderPath,
    String? errorMessage,
    bool? isLoading,
  }) {
    return SetupState(
      step: step ?? this.step,
      selectedMode: selectedMode ?? this.selectedMode,
      folderPath: folderPath ?? this.folderPath,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SetupController extends StateNotifier<SetupState> {
  SetupController() : super(const SetupState());

  DriveStorageAdapter? _driveAdapter;
  DriveStorageAdapter? get driveAdapter => _driveAdapter;

  void selectMode(String mode) {
    if (mode == 'local') {
      state = state.copyWith(selectedMode: mode, step: SetupStep.pathInput);
    } else if (mode == 'drive') {
      state = state.copyWith(selectedMode: mode, step: SetupStep.driveAuth);
    }
    // Mobile seul : non disponible
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

  // ── Mode 1 ──────────────────────────────────────────────────────────────────

  Future<AppConfig> confirm() async {
    final dbPath = p.join(state.folderPath, 'cave.db');
    final config = AppConfig(storageMode: state.selectedMode, dbPath: dbPath);
    await configService.save(config);
    return config;
  }

  void backToPathInput() {
    state = state.copyWith(step: SetupStep.pathInput, errorMessage: null);
  }

  // ── Mode 2 ──────────────────────────────────────────────────────────────────

  /// Lance l'OAuth Google Drive et avance vers le choix (nouvelle/télécharger).
  Future<void> authenticateDrive({
    required String folderPath,
    required String secretsPath,
  }) async {
    state = state.copyWith(folderPath: folderPath, isLoading: true, errorMessage: null);
    try {
      _driveAdapter = DriveStorageAdapter();
      if (!Platform.isAndroid) {
        final creds = await DriveStorageAdapter.loadDesktopCredentials(secretsPath);
        await _driveAdapter!.authenticate(
          desktopClientId: creds.clientId,
          desktopClientSecret: creds.clientSecret,
        );
      } else {
        await _driveAdapter!.authenticate();
      }
      state = state.copyWith(step: SetupStep.driveChoice, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  /// Confirme "Nouvelle cave" en Mode 2 (aucun téléchargement).
  Future<AppConfig> confirmDriveNew() async {
    final dbPath = p.join(state.folderPath, 'cave.db');
    final config = AppConfig(storageMode: 'drive', dbPath: dbPath);
    await configService.save(config);
    return config;
  }

  /// Confirme "Télécharger depuis Drive" : download puis confirme.
  Future<AppConfig> confirmDriveDownload() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final dbPath = p.join(state.folderPath, 'cave.db');
    try {
      await _driveAdapter!.downloadDb(dbPath);
      final config = AppConfig(storageMode: 'drive', dbPath: dbPath);
      await configService.save(config);
      state = state.copyWith(isLoading: false);
      return config;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
      rethrow;
    }
  }

  void backToModeChoice() {
    state = state.copyWith(step: SetupStep.modeChoice, errorMessage: null);
  }
}

final setupControllerProvider =
    StateNotifierProvider.autoDispose<SetupController, SetupState>(
      (ref) => SetupController(),
    );
