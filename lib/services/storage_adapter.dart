// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'dart:io';

/// Statut du verrou sur la base partagée.
class LockStatus {
  final bool isLocked;
  final bool isOurs; // lock appartient à CET appareil
  final String? lockedBy; // device_id du titulaire, null si non verrouillé

  const LockStatus.notLocked()
      : isLocked = false,
        isOurs = false,
        lockedBy = null;

  const LockStatus.lockedByUs()
      : isLocked = true,
        isOurs = true,
        lockedBy = null;

  const LockStatus.lockedByOther(String by)
      : isLocked = true,
        isOurs = false,
        lockedBy = by;
}

/// Contrat entre SyncService et tout backend cloud.
/// SyncService ne connaît pas l'implémentation concrète.
abstract class StorageAdapter {
  /// Retourne le statut du verrou (absent / à nous / à un autre).
  Future<LockStatus> getLockStatus();

  /// Pose le verrou sur la base distante.
  Future<void> lock();

  /// Libère le verrou.
  Future<void> unlock();

  /// Télécharge cave.db depuis le stockage cloud et l'écrit à [localPath].
  Future<void> downloadDb(String localPath);

  /// Uploade [localDb] vers le stockage cloud (crée ou remplace).
  Future<void> uploadDb(File localDb);

  /// Retourne true si cave.db existe dans le stockage cloud.
  Future<bool> remoteDbExists();
}
