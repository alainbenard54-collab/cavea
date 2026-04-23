// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config_service.dart';
import 'storage_adapter.dart';
import 'drive_storage_adapter.dart';

// ── État ─────────────────────────────────────────────────────────────────────

sealed class SyncState {
  const SyncState();
}

class SyncIdle extends SyncState {
  const SyncIdle();
}

class SyncSyncing extends SyncState {
  const SyncSyncing();
}

class SyncLocked extends SyncState {
  final String lockedBy;
  const SyncLocked(this.lockedBy);
}

class SyncError extends SyncState {
  final String message;
  const SyncError(this.message);
}

// ── Callbacks close/reopen drift ─────────────────────────────────────────────
// Enregistrés par _AppWrapperState au démarrage.
// Permettent à SyncService de fermer/rouvrir la base sans dépendre de Flutter.

typedef CloseDbCallback = Future<void> Function();
typedef ReopenDbCallback = Future<void> Function();

CloseDbCallback? _closeDbCallback;
ReopenDbCallback? _reopenDbCallback;

/// À appeler depuis _AppWrapperState.initState() dès que la DB est ouverte.
void registerSyncDbCallbacks({
  required CloseDbCallback onClose,
  required ReopenDbCallback onReopen,
}) {
  _closeDbCallback = onClose;
  _reopenDbCallback = onReopen;
}

// ── Service ───────────────────────────────────────────────────────────────────

class SyncService extends StateNotifier<SyncState> {
  final StorageAdapter? _adapter; // null en Mode 1

  SyncService(this._adapter) : super(const SyncIdle());

  bool get isActive => _adapter != null;

  /// Synchronise cave.db avec Google Drive.
  ///
  /// Protocole :
  /// 1. Si le lock est à nous → upload local → unlock
  /// 2. Si le lock est à un autre → état locked, arrêt
  /// 3. Sinon → lock → download → close drift → replace → reopen drift → idle
  Future<void> sync() async {
    final adapter = _adapter;
    if (adapter == null) return; // Mode 1 : no-op
    if (state is SyncSyncing) return;

    state = const SyncSyncing();
    bool lockAcquired = false;

    try {
      final status = await adapter.getLockStatus();

      if (status.isOurs) {
        // On détient déjà le lock d'une sync précédente → upload d'abord
        await adapter.uploadDb(File(configService.config!.dbPath));
        await adapter.unlock();
      } else if (status.isLocked) {
        // Lock appartient à un autre appareil
        state = SyncLocked(status.lockedBy!);
        return;
      }

      // Acquérir le lock
      await adapter.lock();
      lockAcquired = true;

      // Fermer drift (l'overlay bloque toute interaction UI à ce stade)
      if (_closeDbCallback != null) await _closeDbCallback!();

      // Télécharger le fichier (remplace le fichier local)
      await adapter.downloadDb(configService.config!.dbPath);

      // Rouvrir drift sur le nouveau fichier
      if (_reopenDbCallback != null) await _reopenDbCallback!();

      // Le lock reste posé : il sera libéré lors de la prochaine sync (upload)
      state = const SyncIdle();
    } catch (e) {
      if (lockAcquired) {
        try {
          await adapter.unlock();
        } catch (_) {}
      }
      // Tenter de rouvrir la base même en cas d'erreur
      if (_reopenDbCallback != null) {
        try {
          await _reopenDbCallback!();
        } catch (_) {}
      }
      state = SyncError(e.toString());
    }
  }

  /// Uploade et libère le lock (à appeler avant de quitter l'app en Mode 2).
  Future<void> releaseIfNeeded() async {
    final adapter = _adapter;
    if (adapter == null) return;
    try {
      final status = await adapter.getLockStatus();
      if (status.isOurs) {
        await adapter.uploadDb(File(configService.config!.dbPath));
        await adapter.unlock();
      }
    } catch (_) {}
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

/// Provider no-op pour Mode 1 (sans StorageAdapter).
final _noOpSyncServiceProvider = StateNotifierProvider<SyncService, SyncState>(
  (ref) => SyncService(null),
);

/// Provider avec DriveStorageAdapter pour Mode 2.
final _driveSyncServiceProvider = StateNotifierProvider<SyncService, SyncState>(
  (ref) {
    final adapter = DriveStorageAdapter();
    return SyncService(adapter);
  },
);

/// Provider actif selon le mode configuré.
/// En Mode 1 : SyncService inactif (state toujours idle, sync = no-op).
/// En Mode 2 : SyncService avec DriveStorageAdapter.
final syncServiceProvider = StateNotifierProvider<SyncService, SyncState>((ref) {
  final mode = configService.config?.storageMode ?? 'local';
  if (mode == 'drive') {
    return ref.watch(_driveSyncServiceProvider.notifier);
  }
  return ref.watch(_noOpSyncServiceProvider.notifier);
});
