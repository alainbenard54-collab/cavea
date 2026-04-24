// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'dart:io';

import 'dart:ui' show AppExitType;

import 'package:flutter/services.dart' show ServicesBinding;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config_service.dart';
import 'storage_adapter.dart';
import 'drive_storage_adapter.dart';

// ── États ─────────────────────────────────────────────────────────────────────

sealed class SyncState {
  const SyncState();
}

class SyncIdle extends SyncState {
  const SyncIdle();
}

/// Sync de démarrage en cours — UI bloquée.
class SyncStarting extends SyncState {
  const SyncStarting();
}

/// Upload ou download en cours (bouton Sync ou recovery).
class SyncSyncing extends SyncState {
  const SyncSyncing();
}

/// Lock à nous depuis une session précédente interrompue — choix utilisateur requis.
class SyncNeedsCrashRecovery extends SyncState {
  const SyncNeedsCrashRecovery();
}

/// Lock appartient à un autre appareil — choix utilisateur requis.
class SyncNeedsLockChoice extends SyncState {
  final String lockedBy;
  const SyncNeedsLockChoice(this.lockedBy);
}

/// Mode lecture seule — lock tiers actif, aucune écriture Drive possible.
class SyncReadOnly extends SyncState {
  const SyncReadOnly();
}

/// Fermeture en cours — upload + unlock avant quitter.
class SyncExiting extends SyncState {
  const SyncExiting();
}

class SyncError extends SyncState {
  final String message;
  const SyncError(this.message);
}

// ── Callbacks close/reopen drift ─────────────────────────────────────────────
// Permettent à SyncService de fermer/rouvrir la base sans dépendre de Flutter.

typedef CloseDbCallback = Future<void> Function();
typedef ReopenDbCallback = Future<void> Function({String? message});

CloseDbCallback? _closeDbCallback;
ReopenDbCallback? _reopenDbCallback;

void registerSyncDbCallbacks({
  required CloseDbCallback onClose,
  required ReopenDbCallback onReopen,
}) {
  _closeDbCallback = onClose;
  _reopenDbCallback = onReopen;
}

// ── État persisté entre recréations du ProviderScope ─────────────────────────
// Survit à la recréation du ProviderScope déclenchée par _reopenDbCallback.

bool _startWithLock = false;
bool _startAsReadOnly = false;

/// À appeler juste avant de basculer storageModeProvider vers 'drive' après
/// une migration (Settings). Le prochain SyncService démarrera avec le lock.
void primeNextSyncWithLock() => _startWithLock = true;

// ── Référence globale pour didRequestAppExit (main.dart) ─────────────────────

SyncService? activeSyncService;

// ── Service ───────────────────────────────────────────────────────────────────

class SyncService extends StateNotifier<SyncState> {
  final StorageAdapter? _adapter;
  bool _isDisposed = false;
  bool _lockHeldByUs = false;

  SyncService(this._adapter)
      : super(_startAsReadOnly ? const SyncReadOnly() : const SyncIdle()) {
    _lockHeldByUs = _startWithLock;
    _startWithLock = false;
    _startAsReadOnly = false;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _lockHeldByUs = false;
    super.dispose();
  }

  bool get isActive => _adapter != null;

  /// Vrai si cet appareil détient le lock et peut écrire sur Drive.
  bool get isWriteMode {
    final s = state;
    return s is SyncIdle || s is SyncSyncing;
  }

  /// Vrai si on est en lecture seule (lock appartient à un autre appareil).
  bool get isReadOnly => state is SyncReadOnly;

  // ── Démarrage automatique ─────────────────────────────────────────────────

  /// Appelé automatiquement au démarrage en Mode 2 (depuis _AppWrapperState).
  /// Gère les trois cas : lock libre, lock à nous (crash), lock tiers.
  Future<void> syncOnStartup() async {
    final adapter = _adapter;
    if (adapter == null) return;
    if (_isDisposed) return;

    state = const SyncStarting();

    try {
      final status = await adapter.getLockStatus();

      if (status.isOurs) {
        if (_isDisposed) return;
        state = const SyncNeedsCrashRecovery();
        return;
      }

      if (status.isLocked) {
        if (_isDisposed) return;
        state = SyncNeedsLockChoice(status.lockedBy!);
        return;
      }

      // Lock libre — acquérir et synchroniser
      await adapter.lock();
      _lockHeldByUs = true;

      final remoteExists = await adapter.remoteDbExists();
      if (remoteExists) {
        _startWithLock = true;
        if (_closeDbCallback != null) await _closeDbCallback!();
        await adapter.downloadDb(configService.config!.dbPath);
        if (_reopenDbCallback != null) await _reopenDbCallback!(message: null);
        // Le ProviderScope peut avoir été recréé — le nouveau SyncService
        // a repris _startWithLock=true et démarre avec _lockHeldByUs=true.
        if (_isDisposed) return;
        _lockHeldByUs = true; // fallback si ProviderScope non recréé
        _startWithLock = false;
      } else {
        // Premier lancement : uploader la base locale
        await adapter.uploadDb(File(configService.config!.dbPath));
      }

      if (_isDisposed) return;
      state = const SyncIdle();
    } catch (e) {
      _startWithLock = false;
      _startAsReadOnly = false;
      if (_lockHeldByUs) {
        try { await adapter.unlock(); } catch (_) {}
        _lockHeldByUs = false;
      }
      if (_isDisposed) return;
      state = SyncError(e.toString());
    }
  }

  // ── Résolution crash recovery ─────────────────────────────────────────────

  /// Choix "Envoyer mes données locales" : upload local → garde le lock → écriture.
  Future<void> resolveOwnLockWithUpload() async {
    final adapter = _adapter;
    if (adapter == null) return;

    state = const SyncSyncing();
    try {
      await adapter.uploadDb(File(configService.config!.dbPath));
      _lockHeldByUs = true;
      if (_isDisposed) return;
      state = const SyncIdle();
    } catch (e) {
      if (_isDisposed) return;
      state = SyncError(e.toString());
    }
  }

  /// Choix "Repartir depuis Google Drive" : download Drive → garde le lock → écriture.
  Future<void> resolveOwnLockWithDownload() async {
    final adapter = _adapter;
    if (adapter == null) return;

    state = const SyncSyncing();
    bool dbWasClosed = false;
    try {
      _startWithLock = true;
      if (_closeDbCallback != null) {
        await _closeDbCallback!();
        dbWasClosed = true;
      }
      await adapter.downloadDb(configService.config!.dbPath);
      if (_reopenDbCallback != null) await _reopenDbCallback!(message: null);
      if (_isDisposed) return;
      _lockHeldByUs = true;
      _startWithLock = false;
      state = const SyncIdle();
    } catch (e) {
      _startWithLock = false;
      if (dbWasClosed && _reopenDbCallback != null) {
        try { await _reopenDbCallback!(message: null); } catch (_) {}
      }
      if (_isDisposed) return;
      state = SyncError(e.toString());
    }
  }

  // ── Mode lecture seule ────────────────────────────────────────────────────

  /// Choix "Consulter en lecture seule" : download sans lock → lecture seule.
  Future<void> enterReadOnly() async {
    final adapter = _adapter;
    if (adapter == null) return;

    state = const SyncSyncing();
    bool dbWasClosed = false;
    try {
      final remoteExists = await adapter.remoteDbExists();
      if (remoteExists) {
        _startAsReadOnly = true;
        if (_closeDbCallback != null) {
          await _closeDbCallback!();
          dbWasClosed = true;
        }
        await adapter.downloadDb(configService.config!.dbPath);
        if (_reopenDbCallback != null) await _reopenDbCallback!(message: null);
        if (_isDisposed) return;
        _startAsReadOnly = false;
      }
      _lockHeldByUs = false;
      if (_isDisposed) return;
      state = const SyncReadOnly();
    } catch (e) {
      _startAsReadOnly = false;
      if (dbWasClosed && _reopenDbCallback != null) {
        try { await _reopenDbCallback!(message: null); } catch (_) {}
      }
      if (_isDisposed) return;
      state = SyncError(e.toString());
    }
  }

  // ── Re-acquisition du lock (Android resume) ──────────────────────────────

  /// Repose le lock après un releaseIfNeeded() sur Android pause.
  /// Ne télécharge PAS depuis Drive (la version locale est à jour).
  Future<void> reacquireLock() async {
    final adapter = _adapter;
    if (adapter == null || _isDisposed || _lockHeldByUs) return;

    state = const SyncStarting();
    try {
      final status = await adapter.getLockStatus();
      if (status.isOurs) {
        _lockHeldByUs = true;
        if (_isDisposed) return;
        state = const SyncIdle();
        return;
      }
      if (status.isLocked) {
        if (_isDisposed) return;
        state = SyncNeedsLockChoice(status.lockedBy!);
        return;
      }
      await adapter.lock();
      _lockHeldByUs = true;
      if (_isDisposed) return;
      state = const SyncIdle();
    } catch (e) {
      if (_isDisposed) return;
      state = SyncError(e.toString());
    }
  }

  // ── Sync manuelle (bouton) ────────────────────────────────────────────────

  /// Upload uniquement — lock conservé. N'a d'effet qu'en mode écriture.
  Future<void> sync() async {
    final adapter = _adapter;
    if (adapter == null) return;
    if (!isWriteMode) return;
    if (state is SyncSyncing) return;

    state = const SyncSyncing();
    try {
      await adapter.uploadDb(File(configService.config!.dbPath));
      if (_isDisposed) return;
      state = const SyncIdle();
    } catch (e) {
      if (_isDisposed) return;
      state = SyncError(e.toString());
    }
  }

  // ── Fermeture ─────────────────────────────────────────────────────────────

  /// Déclenché par didRequestAppExit() — upload + unlock puis quitter.
  Future<void> releaseAndExit() async {
    if (_isDisposed) return;
    state = const SyncExiting();
    await releaseIfNeeded();
    if (_isDisposed) return;
    await ServicesBinding.instance.exitApplication(AppExitType.required);
  }

  /// Upload + unlock si on détient le lock. Appelé à la fermeture ou best-effort Android.
  Future<void> releaseIfNeeded() async {
    final adapter = _adapter;
    if (adapter == null || !_lockHeldByUs) return;
    try {
      await adapter.uploadDb(File(configService.config!.dbPath));
      await adapter.unlock();
      _lockHeldByUs = false;
    } catch (_) {}
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final storageModeProvider = StateProvider<String>((ref) {
  return configService.config?.storageMode ?? 'local';
});

final syncServiceProvider = StateNotifierProvider<SyncService, SyncState>((ref) {
  final mode = ref.watch(storageModeProvider);
  final service = mode == 'drive'
      ? SyncService(DriveStorageAdapter())
      : SyncService(null);
  activeSyncService = service;
  ref.onDispose(() {
    if (identical(activeSyncService, service)) activeSyncService = null;
  });
  return service;
});
