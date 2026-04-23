// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/sync_service.dart';

/// Icône d'état de synchronisation Google Drive.
/// Visible uniquement en Mode 2 (syncService.isActive).
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
    final service = ref.read(syncServiceProvider.notifier);

    if (!service.isActive) return const SizedBox.shrink();

    switch (syncState) {
      case SyncSyncing():
        _rotationCtrl.repeat();
        return Tooltip(
          message: 'Synchronisation en cours…',
          child: RotationTransition(
            turns: _rotationCtrl,
            child: const Icon(Icons.sync, color: Colors.blue),
          ),
        );

      case SyncLocked(:final lockedBy):
        _rotationCtrl.stop();
        return Tooltip(
          message: 'Cave verrouillée par $lockedBy',
          child: const Icon(Icons.lock_outline, color: Colors.orange),
        );

      case SyncError(:final message):
        _rotationCtrl.stop();
        return Tooltip(
          message: 'Erreur : $message',
          child: const Icon(Icons.sync_problem, color: Colors.red),
        );

      case SyncIdle():
        _rotationCtrl.stop();
        return const Tooltip(
          message: 'Synchronisation disponible',
          child: Icon(Icons.sync, color: Colors.grey),
        );
    }
  }
}
