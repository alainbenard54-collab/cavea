// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'dart:io' show Platform, exit;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/sync_service.dart';
import '../widgets/sync_status_indicator.dart';

const kDesktopBreakpoint = 600.0;

bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= kDesktopBreakpoint;

class _AppDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;

  const _AppDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });
}

const _destinations = [
  _AppDestination(
    label: 'Stock',
    icon: Icons.wine_bar_outlined,
    selectedIcon: Icons.wine_bar,
    route: '/',
  ),
  _AppDestination(
    label: 'Ajouter',
    icon: Icons.add_circle_outline,
    selectedIcon: Icons.add_circle,
    route: '/bulk-add',
  ),
  _AppDestination(
    label: 'Import CSV',
    icon: Icons.upload_file_outlined,
    selectedIcon: Icons.upload_file,
    route: '/import-csv',
  ),
  _AppDestination(
    label: 'Paramètres',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    route: '/settings',
  ),
];

class AppShell extends ConsumerStatefulWidget {
  final int selectedIndex;
  final Widget child;

  const AppShell({super.key, required this.selectedIndex, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  // Indices des destinations réservées à l'écriture (Ajouter=1, Import CSV=2).
  static const _writeOnlyIndices = {1, 2};

  void _onDestinationSelected(BuildContext context, int index) {
    final syncState = ref.read(syncServiceProvider);
    if (syncState is SyncReadOnly && _writeOnlyIndices.contains(index)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indisponible en mode lecture seule')),
      );
      return;
    }
    context.go(_destinations[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncServiceProvider);
    ref.watch(storageModeProvider);
    final syncService = ref.read(syncServiceProvider.notifier);

    // Réactions aux transitions d'état
    ref.listen<SyncState>(syncServiceProvider, (previous, next) {
      if (!mounted) return;
      switch (next) {
        case SyncIdle():
          // Snackbar uniquement après un upload manuel (SyncSyncing → SyncIdle)
          // Pas après startup (SyncStarting → SyncIdle)
          if (previous is SyncSyncing) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cave sauvegardée sur Drive')),
            );
          }
        case SyncError(:final message):
          showDialog<void>(
            context: context,
            builder: (_) => _SyncErrorDialog(
              message: message,
              onRetry: syncService.sync,
            ),
          );
        case SyncNeedsCrashRecovery():
          _showCrashRecoveryDialog(context, syncService);
        case SyncNeedsLockChoice(:final lockedBy):
          _showLockTiersDialog(context, syncService, lockedBy);
        default:
          break;
      }
    });

    // États qui bloquent l'UI (overlay plein écran)
    final isBlocking = syncState is SyncSyncing ||
        syncState is SyncStarting ||
        syncState is SyncNeedsCrashRecovery ||
        syncState is SyncNeedsLockChoice ||
        syncState is SyncExiting;

    final isReadOnly = syncState is SyncReadOnly;

    // Le bouton Sync n'est visible qu'en mode écriture
    final showSyncButton =
        syncService.isActive && (syncState is SyncIdle || syncState is SyncSyncing);

    final desktop = isDesktop(context);
    final isAndroid = Platform.isAndroid;

    Widget shellContent;
    if (desktop) {
      shellContent = Scaffold(
        body: Row(
          children: [
            _DesktopRail(
              selectedIndex: widget.selectedIndex,
              syncService: syncService,
              showSyncButton: showSyncButton,
              isReadOnly: isReadOnly,
              onDestinationSelected: (i) => _onDestinationSelected(context, i),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: widget.child),
          ],
        ),
      );
    } else {
      shellContent = Scaffold(
        body: widget.child,
        bottomNavigationBar: _MobileBar(
          selectedIndex: widget.selectedIndex,
          syncService: syncService,
          showSyncButton: showSyncButton,
          isReadOnly: isReadOnly,
          isAndroid: isAndroid,
          onDestinationSelected: (i) => _onDestinationSelected(context, i),
        ),
      );
    }

    if (isBlocking) {
      return Stack(
        children: [
          shellContent,
          IgnorePointer(
            ignoring: false,
            child: ColoredBox(
              color: const Color(0x80000000),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      _overlayMessage(syncState),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return shellContent;
  }

  String _overlayMessage(SyncState state) => switch (state) {
        SyncStarting() || SyncNeedsCrashRecovery() || SyncNeedsLockChoice() =>
          'Connexion à Google Drive…',
        SyncExiting() => 'Sauvegarde en cours…',
        _ => 'Synchronisation en cours…',
      };

  void _showCrashRecoveryDialog(BuildContext context, SyncService syncService) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Session précédente interrompue'),
        content: const Text('La dernière session ne s\'est pas terminée correctement.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              syncService.resolveOwnLockWithUpload();
            },
            child: const Text('Envoyer mes données locales'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              syncService.resolveOwnLockWithDownload();
            },
            child: const Text(
              'Repartir depuis Google Drive\n(perte de modifications locales possible)',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _showLockTiersDialog(
    BuildContext context,
    SyncService syncService,
    String lockedBy,
  ) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cave utilisée sur un autre appareil'),
        content: const Text(
          'Votre cave est actuellement ouverte sur un autre appareil.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              exit(0); // Terminate process — SystemNavigator.pop() laisserait l'app en arrière-plan.
            },
            child: const Text('Quitter'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              syncService.enterReadOnly();
            },
            child: const Text('Consulter en lecture seule'),
          ),
        ],
      ),
    );
  }
}

// ── Navigation Desktop ────────────────────────────────────────────────────────

class _DesktopRail extends StatelessWidget {
  final int selectedIndex;
  final SyncService syncService;
  final bool showSyncButton;
  final bool isReadOnly;
  final void Function(int) onDestinationSelected;

  const _DesktopRail({
    required this.selectedIndex,
    required this.syncService,
    required this.showSyncButton,
    required this.isReadOnly,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      labelType: NavigationRailLabelType.all,
      onDestinationSelected: onDestinationSelected,
      leading: syncService.isActive
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  const SyncStatusIndicator(),
                  if (showSyncButton) ...[
                    const SizedBox(height: 4),
                    _SyncButton(syncService: syncService),
                  ],
                ],
              ),
            )
          : const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: SyncStatusIndicator(),
            ),
      destinations: _destinations.asMap().entries.map((e) {
        final disabled = isReadOnly && _AppShellState._writeOnlyIndices.contains(e.key);
        final color = disabled ? Theme.of(context).colorScheme.outline : null;
        final d = e.value;
        return NavigationRailDestination(
          icon: Icon(d.icon, color: color),
          selectedIcon: Icon(d.selectedIcon, color: color),
          label: Text(d.label, style: TextStyle(color: color)),
        );
      }).toList(),
    );
  }
}

// ── Navigation Mobile ─────────────────────────────────────────────────────────

class _MobileBar extends StatelessWidget {
  final int selectedIndex;
  final SyncService syncService;
  final bool showSyncButton;
  final bool isReadOnly;
  final bool isAndroid;
  final void Function(int) onDestinationSelected;

  const _MobileBar({
    required this.selectedIndex,
    required this.syncService,
    required this.showSyncButton,
    required this.isReadOnly,
    required this.isAndroid,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (syncService.isActive)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SyncStatusIndicator(),
                // Android écriture : "Sauvegarder et libérer" (remplace "Synchroniser")
                if (isAndroid && showSyncButton) ...[
                  const SizedBox(width: 8),
                  _SaveAndReleaseButton(syncService: syncService),
                ],
                // Android lecture seule : "Prendre la main"
                if (isAndroid && isReadOnly) ...[
                  const SizedBox(width: 8),
                  _AcquireLockButton(syncService: syncService),
                ],
                // PC uniquement : "Synchroniser"
                if (!isAndroid && showSyncButton) ...[
                  const SizedBox(width: 8),
                  _SyncButton(syncService: syncService),
                ],
              ],
            ),
          ),
        NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: _destinations.asMap().entries.map((e) {
            final disabled = isReadOnly && _AppShellState._writeOnlyIndices.contains(e.key);
            final color = disabled ? Theme.of(context).colorScheme.outline : null;
            final d = e.value;
            return NavigationDestination(
              icon: Icon(d.icon, color: color),
              selectedIcon: Icon(d.selectedIcon, color: color),
              label: d.label,
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Bouton Prendre la main (Android lecture seule) ────────────────────────────

class _AcquireLockButton extends StatelessWidget {
  final SyncService syncService;

  const _AcquireLockButton({required this.syncService});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _showConfirmDialog(context),
      icon: const Icon(Icons.lock_open, size: 16),
      label: const Text('Prendre la main'),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Passer en mode écriture ?'),
        content: const Text(
          'Vos modifications seront sauvegardées sur Drive et le verrou libéré '
          "uniquement en appuyant sur 'Sauvegarder et libérer' avant de quitter. "
          "En cas d'oubli, la session suivante proposera de récupérer vos données.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) syncService.acquireLock();
    });
  }
}

// ── Bouton Sauvegarder et libérer (Android écriture) ─────────────────────────

class _SaveAndReleaseButton extends StatelessWidget {
  final SyncService syncService;

  const _SaveAndReleaseButton({required this.syncService});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () async {
        final success = await syncService.releaseManual();
        if (!context.mounted) return;
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cave sauvegardée et verrou libéré')),
          );
        }
      },
      icon: const Icon(Icons.cloud_done, size: 16),
      label: const Text('Sauvegarder et libérer'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        textStyle: const TextStyle(fontSize: 12),
        backgroundColor: Colors.green,
      ),
    );
  }
}

// ── Bouton Synchroniser ───────────────────────────────────────────────────────

class _SyncButton extends StatelessWidget {
  final SyncService syncService;

  const _SyncButton({required this.syncService});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: syncService.sync,
      icon: const Icon(Icons.sync, size: 16),
      label: const Text('Synchroniser'),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}

// ── Dialogue d'erreur ─────────────────────────────────────────────────────────

class _SyncErrorDialog extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SyncErrorDialog({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Erreur de synchronisation'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop();
            onRetry();
          },
          child: const Text('Réessayer'),
        ),
      ],
    );
  }
}
