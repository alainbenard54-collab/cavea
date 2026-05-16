// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../core/config_service.dart';
import '../../services/drive_storage_adapter.dart';
import '../../services/dropbox_storage_adapter.dart';

enum SetupStep {
  modeChoice,
  pathInput,       // Mode 1 : saisie du chemin
  confirmation,    // Mode 1 : confirmation
  providerChoice,  // Mode 2 : choix du fournisseur (Drive ou Dropbox)
  driveAuth,       // Mode 2 Drive : authentification Google
  driveChoice,     // Mode 2 Drive : nouvelle cave ou télécharger
  dropboxAuth,     // Mode 2 Dropbox : authentification Dropbox
  dropboxChoice,   // Mode 2 Dropbox : nouvelle cave ou télécharger
}

class SetupState {
  final SetupStep step;
  final String selectedMode;
  final String folderPath;
  final String? errorMessage;
  final bool isLoading;
  final bool driveHasCave;
  final bool driveLockedByOther;
  final String? driveLockOwner;

  const SetupState({
    this.step = SetupStep.modeChoice,
    this.selectedMode = 'local',
    this.folderPath = '',
    this.errorMessage,
    this.isLoading = false,
    this.driveHasCave = false,
    this.driveLockedByOther = false,
    this.driveLockOwner,
  });

  SetupState copyWith({
    SetupStep? step,
    String? selectedMode,
    String? folderPath,
    String? errorMessage,
    bool? isLoading,
    bool? driveHasCave,
    bool? driveLockedByOther,
    String? driveLockOwner,
  }) {
    return SetupState(
      step: step ?? this.step,
      selectedMode: selectedMode ?? this.selectedMode,
      folderPath: folderPath ?? this.folderPath,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
      driveHasCave: driveHasCave ?? this.driveHasCave,
      driveLockedByOther: driveLockedByOther ?? this.driveLockedByOther,
      driveLockOwner: driveLockOwner ?? this.driveLockOwner,
    );
  }
}

class SetupController extends StateNotifier<SetupState> {
  SetupController() : super(const SetupState());

  DriveStorageAdapter? _driveAdapter;
  DriveStorageAdapter? get driveAdapter => _driveAdapter;
  DropboxStorageAdapter? _dropboxAdapter;

  void selectMode(String mode) {
    if (mode == 'local') {
      state = state.copyWith(selectedMode: mode, step: SetupStep.pathInput);
    } else if (mode == 'shared') {
      if (Platform.isAndroid) {
        _selectSharedAndroid();
      } else {
        state = state.copyWith(step: SetupStep.providerChoice);
      }
    }
    // Mobile seul : non disponible
  }

  Future<void> _selectSharedAndroid() async {
    final dir = await getApplicationDocumentsDirectory();
    state = state.copyWith(folderPath: dir.path, step: SetupStep.providerChoice);
  }

  void selectProvider(String provider) {
    if (provider == 'drive') {
      state = state.copyWith(selectedMode: 'drive', step: SetupStep.driveAuth);
    } else if (provider == 'dropbox') {
      state = state.copyWith(selectedMode: 'dropbox', step: SetupStep.dropboxAuth);
    }
  }

  void backToProviderChoice() {
    state = state.copyWith(step: SetupStep.providerChoice, errorMessage: null);
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

  /// Lance l'OAuth Google Drive, vérifie l'état du Drive, puis avance vers le choix.
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

      final hasCave = await _driveAdapter!.remoteDbExists();
      final lockStatus = await _driveAdapter!.getLockStatus();
      final lockedByOther = lockStatus.isLocked && !lockStatus.isOurs;

      state = state.copyWith(
        step: SetupStep.driveChoice,
        isLoading: false,
        driveHasCave: hasCave,
        driveLockedByOther: lockedByOther,
        driveLockOwner: lockedByOther ? lockStatus.lockedBy : null,
      );
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

  /// Confirme "Rejoindre la cave existante" : télécharge cave.db depuis Drive.
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

  /// Confirme "Écraser" : supprime cave.db du Drive, crée une nouvelle cave vide.
  Future<AppConfig> confirmDriveOverwrite() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final dbPath = p.join(state.folderPath, 'cave.db');
    try {
      await _driveAdapter!.deleteDb();
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

  // ── Mode 2 Dropbox ──────────────────────────────────────────────────────────

  Future<void> authenticateDropbox({
    required String folderPath,
    String? androidAppKey,
  }) async {
    state = state.copyWith(folderPath: folderPath, isLoading: true, errorMessage: null);
    try {
      _dropboxAdapter = DropboxStorageAdapter();
      if (Platform.isAndroid && androidAppKey != null && androidAppKey.isNotEmpty) {
        await DropboxStorageAdapter.saveAndroidAppKey(androidAppKey);
      }
      await _dropboxAdapter!.authenticate();

      final hasCave = await _dropboxAdapter!.remoteDbExists();
      final lockStatus = await _dropboxAdapter!.getLockStatus();
      final lockedByOther = lockStatus.isLocked && !lockStatus.isOurs;

      state = state.copyWith(
        step: SetupStep.dropboxChoice,
        isLoading: false,
        driveHasCave: hasCave,
        driveLockedByOther: lockedByOther,
        driveLockOwner: lockedByOther ? lockStatus.lockedBy : null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<AppConfig> confirmDropboxNew() async {
    final dbPath = p.join(state.folderPath, 'cave.db');
    final config = AppConfig(storageMode: 'dropbox', dbPath: dbPath);
    await configService.save(config);
    return config;
  }

  Future<AppConfig> confirmDropboxDownload() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final dbPath = p.join(state.folderPath, 'cave.db');
    try {
      await _dropboxAdapter!.downloadDb(dbPath);
      final config = AppConfig(storageMode: 'dropbox', dbPath: dbPath);
      await configService.save(config);
      state = state.copyWith(isLoading: false);
      return config;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
      rethrow;
    }
  }

  Future<AppConfig> confirmDropboxOverwrite() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final dbPath = p.join(state.folderPath, 'cave.db');
    try {
      await _dropboxAdapter!.deleteDb();
      final config = AppConfig(storageMode: 'dropbox', dbPath: dbPath);
      await configService.save(config);
      state = state.copyWith(isLoading: false);
      return config;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
      rethrow;
    }
  }
}

final setupControllerProvider =
    StateNotifierProvider.autoDispose<SetupController, SetupState>(
      (ref) => SetupController(),
    );
