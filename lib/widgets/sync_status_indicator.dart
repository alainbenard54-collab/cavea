// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/sync_service.dart';

/// Indicateur d'état permanent dans la navigation.
/// Icône de mode (PC / nuage) + icône de verrou (écriture / lecture seule) en Mode 2.
class SyncStatusIndicator extends ConsumerStatefulWidget {
  const SyncStatusIndicator({super.key});

  @override
  ConsumerState<SyncStatusIndicator> createState() => _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends ConsumerState<SyncStatusIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationCtrl;

  @override
  void initState() {
    super.initState();
    _rotationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _rotationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncServiceProvider);
    final mode = ref.watch(storageModeProvider);
    final isMode2 = mode == 'drive';

    // Icône de mode — toujours affichée
    final modeIcon = Tooltip(
      message: isMode2 ? 'Mode partagé — Google Drive' : 'Mode local — PC seul',
      child: Icon(
        isMode2 ? Icons.cloud : Icons.computer,
        color: isMode2 ? Colors.blue : Colors.grey,
        size: 20,
      ),
    );

    if (!isMode2) {
      _rotationCtrl.stop();
      return modeIcon;
    }

    // Icône de verrou / statut (Mode 2 uniquement)
    Widget? statusIcon;
    switch (syncState) {
      case SyncIdle():
        _rotationCtrl.stop();
        statusIcon = const Tooltip(
          message: 'Votre cave est ouverte en écriture',
          child: Icon(Icons.lock_open, color: Colors.green, size: 20),
        );

      case SyncReadOnly():
        _rotationCtrl.stop();
        statusIcon = const Tooltip(
          message: 'Consultation uniquement — cave ouverte sur un autre appareil',
          child: Icon(Icons.lock, color: Colors.amber, size: 20),
        );

      case SyncSyncing() || SyncExiting():
        _rotationCtrl.repeat();
        statusIcon = Tooltip(
          message: 'Synchronisation en cours…',
          child: RotationTransition(
            turns: _rotationCtrl,
            child: const Icon(Icons.sync, color: Colors.blue, size: 20),
          ),
        );

      case SyncError():
        _rotationCtrl.stop();
        statusIcon = const Tooltip(
          message: 'Erreur de synchronisation',
          child: Icon(Icons.sync_problem, color: Colors.red, size: 20),
        );

      case SyncStarting() || SyncNeedsCrashRecovery() || SyncNeedsLockChoice():
        _rotationCtrl.stop();
        statusIcon = null; // Rien pendant le démarrage (overlay affiché)
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        modeIcon,
        if (statusIcon != null) ...[
          const SizedBox(width: 4),
          statusIcon,
        ],
      ],
    );
  }
}
