// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

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
  void _onDestinationSelected(BuildContext context, int index) {
    context.go(_destinations[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncServiceProvider);
    final syncService = ref.read(syncServiceProvider.notifier);
    final isSyncing = syncState is SyncSyncing;

    // Feedback post-sync (transition syncing→idle ou syncing→locked/error)
    ref.listen<SyncState>(syncServiceProvider, (previous, next) {
      if (previous is SyncSyncing && mounted) {
        switch (next) {
          case SyncIdle():
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Synchronisation réussie')),
            );
          case SyncLocked(:final lockedBy):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cave verrouillée par $lockedBy — réessayez plus tard')),
            );
          case SyncError(:final message):
            showDialog<void>(
              context: context,
              builder: (_) => _SyncErrorDialog(
                message: message,
                onRetry: () => syncService.sync(),
              ),
            );
          case SyncSyncing():
            break;
        }
      }
    });

    final desktop = isDesktop(context);

    Widget shellContent;
    if (desktop) {
      shellContent = Scaffold(
        body: Row(
          children: [
            _DesktopRail(
              selectedIndex: widget.selectedIndex,
              syncService: syncService,
              syncState: syncState,
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
          syncState: syncState,
          onDestinationSelected: (i) => _onDestinationSelected(context, i),
        ),
      );
    }

    // Overlay de blocage pendant la sync (fermeture/réouverture de drift)
    if (isSyncing) {
      return Stack(
        children: [
          shellContent,
          const IgnorePointer(
            ignoring: false,
            child: ColoredBox(
              color: Color(0x80000000),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Synchronisation en cours…',
                      style: TextStyle(color: Colors.white, fontSize: 16),
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
}

// ── Navigation Desktop ────────────────────────────────────────────────────────

class _DesktopRail extends StatelessWidget {
  final int selectedIndex;
  final SyncService syncService;
  final SyncState syncState;
  final void Function(int) onDestinationSelected;

  const _DesktopRail({
    required this.selectedIndex,
    required this.syncService,
    required this.syncState,
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
                  const SizedBox(height: 4),
                  _SyncButton(syncService: syncService, syncState: syncState),
                ],
              ),
            )
          : null,
      destinations: _destinations
          .map(
            (d) => NavigationRailDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon),
              label: Text(d.label),
            ),
          )
          .toList(),
    );
  }
}

// ── Navigation Mobile ─────────────────────────────────────────────────────────

class _MobileBar extends StatelessWidget {
  final int selectedIndex;
  final SyncService syncService;
  final SyncState syncState;
  final void Function(int) onDestinationSelected;

  const _MobileBar({
    required this.selectedIndex,
    required this.syncService,
    required this.syncState,
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
                const SizedBox(width: 8),
                _SyncButton(syncService: syncService, syncState: syncState),
              ],
            ),
          ),
        NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: _destinations
              .map(
                (d) => NavigationDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: d.label,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

// ── Bouton Synchroniser ───────────────────────────────────────────────────────

class _SyncButton extends StatelessWidget {
  final SyncService syncService;
  final SyncState syncState;

  const _SyncButton({required this.syncService, required this.syncState});

  @override
  Widget build(BuildContext context) {
    final isSyncing = syncState is SyncSyncing;
    return TextButton.icon(
      onPressed: isSyncing ? null : () => syncService.sync(),
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
