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
          // Pas après startup (SyncStarting → SyncIdle) ni acquireLock (SyncStarting → SyncIdle)
          if (previous is SyncSyncing) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cave sauvegardée sur Drive')),
            );
          }
        case SyncReadOnly():
          // Snackbar après "Sauvegarder et libérer" (SyncSyncing → SyncReadOnly)
          if (previous is SyncSyncing) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cave sauvegardée et verrou libéré')),
            );
          }
        case SyncError(:final message):
          // SyncStarting → SyncError = acquireLock a échoué (verrou tiers).
          // On remet immédiatement en lecture seule : l'icône d'erreur sync
          // n'apparaît pas et le bouton "Prendre la main" reste visible.
          final wasAcquiringLock = previous is SyncStarting;
          if (wasAcquiringLock) syncService.resetToReadOnly();
          showDialog<void>(
            context: context,
            builder: (_) => _SyncErrorDialog(
              title: wasAcquiringLock ? 'Impossible de prendre la main' : null,
              message: wasAcquiringLock
                  ? 'La cave est actuellement verrouillée par un autre appareil.'
                  : message,
              onRetry: wasAcquiringLock
                  ? syncService.acquireLock
                  : (Platform.isAndroid ? null : syncService.sync),
              // wasAcquiringLock : état déjà SyncReadOnly, fermeture suffit.
              onClose: wasAcquiringLock
                  ? null
                  : (Platform.isAndroid ? syncService.resetToReadOnly : null),
              closeLabel: wasAcquiringLock ? 'Rester en lecture seule' : null,
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

    final isAndroid = Platform.isAndroid;
    // Sur Android (portrait ET paysage), on utilise toujours la BottomNavigationBar :
    // la NavigationRail ne tient pas en hauteur en paysage avec le clavier ouvert,
    // et le _MobileBar inclut déjà le bouton "Prendre la main" et l'indicateur sync.
    final useRail = isDesktop(context) && !isAndroid;

    Widget shellContent;
    if (useRail) {
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
        content: const Text(
          'La dernière session ne s\'est pas terminée correctement. '
          'Choisissez quelle version de la cave conserver.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _showCrashRecoveryConfirm(
                context,
                syncService,
                title: 'Envoyer mes données locales ?',
                content: 'Votre base locale va remplacer la version sur Google Drive. '
                    'Comme la cave était verrouillée, aucun autre appareil n\'a pu '
                    'la modifier depuis la dernière synchronisation.',
                confirmLabel: 'Envoyer',
                onConfirm: syncService.resolveOwnLockWithUpload,
                onCancel: () => _showCrashRecoveryDialog(context, syncService),
              );
            },
            child: const Text('Envoyer mes données locales'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _showCrashRecoveryConfirm(
                context,
                syncService,
                title: 'Repartir depuis Google Drive ?',
                content: 'La base Google Drive va remplacer votre base locale. '
                    'Toutes vos modifications locales non sauvegardées seront perdues.',
                confirmLabel: 'Remplacer ma base locale',
                onConfirm: syncService.resolveOwnLockWithDownload,
                onCancel: () => _showCrashRecoveryDialog(context, syncService),
              );
            },
            child: const Text('Repartir depuis Google Drive'),
          ),
        ],
      ),
    );
  }

  void _showCrashRecoveryConfirm(
    BuildContext context,
    SyncService syncService, {
    required String title,
    required String content,
    required String confirmLabel,
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onCancel();
            },
            child: const Text('Retour'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onConfirm();
            },
            child: Text(confirmLabel),
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
    final cs = Theme.of(context).colorScheme;

    // Badge cadenas sur les destinations verrouillées — même visuel que _MobileBar.
    Widget lockableIcon(IconData iconData, bool disabled) {
      if (!disabled) return Icon(iconData);
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(iconData, color: cs.outline),
          Positioned(
            right: -4,
            bottom: -4,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(color: cs.surface, shape: BoxShape.circle),
              child: Icon(Icons.lock, size: 11, color: Colors.orange.shade700),
            ),
          ),
        ],
      );
    }

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
                  if (isReadOnly) ...[
                    const SizedBox(height: 4),
                    _AcquireLockButton(syncService: syncService),
                  ],
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
        final d = e.value;
        return NavigationRailDestination(
          icon: lockableIcon(d.icon, disabled),
          selectedIcon: lockableIcon(d.selectedIcon, disabled),
          label: Text(d.label, style: TextStyle(color: disabled ? cs.outline : null)),
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
    final cs = Theme.of(context).colorScheme;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      color: cs.surfaceContainer,
      padding: EdgeInsets.only(bottom: bottomPad),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            // ── Zone sync (Mode 2 uniquement) ─────────────────────────
            if (syncService.isActive) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SyncStatusIndicator(),
                    if (isReadOnly && isAndroid)
                      _AcquireLockIconBtn(syncService: syncService),
                    if (!isReadOnly && isAndroid) ...[
                      _AbandonWriteIconBtn(syncService: syncService),
                      _SaveIconBtn(syncService: syncService),
                      _QuitIconBtn(syncService: syncService),
                    ],
                    if (!isAndroid && showSyncButton)
                      _SyncIconBtn(syncService: syncService),
                  ],
                ),
              ),
              VerticalDivider(
                indent: 10,
                endIndent: 10,
                color: cs.outlineVariant,
              ),
            ],
            // ── Navigation primaire ────────────────────────────────────
            _NavBtn(
              tooltip: 'Stock',
              icon: Icons.wine_bar_outlined,
              selectedIcon: Icons.wine_bar,
              selected: selectedIndex == 0,
              onTap: () => onDestinationSelected(0),
            ),
            _NavBtn(
              tooltip: isReadOnly
                  ? 'Ajouter (indisponible en lecture seule)'
                  : 'Ajouter',
              icon: Icons.add_circle_outline,
              selectedIcon: Icons.add_circle,
              selected: selectedIndex == 1,
              enabled: !isReadOnly,
              onTap: () => onDestinationSelected(1),
            ),
            const Spacer(),
            // ── Navigation secondaire ──────────────────────────────────
            _NavBtn(
              tooltip: isReadOnly
                  ? 'Import CSV (indisponible en lecture seule)'
                  : 'Import CSV',
              icon: Icons.upload_file_outlined,
              selectedIcon: Icons.upload_file,
              selected: selectedIndex == 2,
              enabled: !isReadOnly,
              onTap: () => onDestinationSelected(2),
              compact: true,
            ),
            _NavBtn(
              tooltip: 'Paramètres',
              icon: Icons.settings_outlined,
              selectedIcon: Icons.settings,
              selected: selectedIndex == 3,
              onTap: () => onDestinationSelected(3),
              compact: true,
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

// ── Bouton navigation (icône + tooltip) ──────────────────────────────────────

class _NavBtn extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final bool compact;

  const _NavBtn({
    required this.tooltip,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
    this.enabled = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = !enabled
        ? cs.outline
        : selected
            ? cs.primary
            : cs.onSurfaceVariant;
    final iconSize = compact ? 22.0 : 24.0;
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: InkWell(
        // Toujours déclencher onTap — _onDestinationSelected gère la snackbar
        // en mode lecture seule au lieu de bloquer silencieusement.
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10.0 : 14.0,
            vertical: 8,
          ),
          child: !enabled
              ? Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(selected ? selectedIcon : icon, color: color, size: iconSize),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.lock, size: 11, color: Colors.orange.shade700),
                      ),
                    ),
                  ],
                )
              : Icon(selected ? selectedIcon : icon, color: color, size: iconSize),
        ),
      ),
    );
  }
}

// ── Dialogue partagé : prise de verrou ───────────────────────────────────────

void _showAcquireLockDialog(
  BuildContext context,
  SyncService syncService, {
  bool isAndroid = false,
}) {
  showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Passer en mode écriture ?'),
      content: Text(
        isAndroid
            ? "Vos modifications seront sauvegardées sur Drive et le verrou libéré "
                "uniquement en appuyant sur 'Sauvegarder et libérer' avant de quitter. "
                "En cas d'oubli, la session suivante proposera de récupérer vos données "
                'si la base est toujours verrouillée.'
            : 'La cave sera verrouillée pendant toute votre session. '
                'Le verrou sera automatiquement libéré et vos modifications '
                'sauvegardées sur Google Drive à la fermeture de l\'application '
                'ou via le bouton "Synchroniser".',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Confirmer'),
        ),
      ],
    ),
  ).then((confirmed) {
    if (confirmed == true) syncService.acquireLock();
  });
}

// ── Boutons icône compacts pour la barre Android ─────────────────────────────

class _AcquireLockIconBtn extends StatelessWidget {
  final SyncService syncService;
  const _AcquireLockIconBtn({required this.syncService});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Passer en écriture',
      preferBelow: false,
      child: IconButton(
        icon: const Icon(Icons.lock_open, size: 20, color: Colors.green),
        onPressed: () => _showAcquireLockDialog(context, syncService, isAndroid: true),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

// ── Bouton texte "Prendre la main" pour le rail desktop ──────────────────────

class _AcquireLockButton extends StatelessWidget {
  final SyncService syncService;
  const _AcquireLockButton({required this.syncService});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _showAcquireLockDialog(context, syncService),
      icon: const Icon(Icons.lock_open, size: 16, color: Colors.green),
      label: const Text('Prendre la main'),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}

class _AbandonWriteIconBtn extends StatelessWidget {
  final SyncService syncService;
  const _AbandonWriteIconBtn({required this.syncService});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Retour lecture seule',
      preferBelow: false,
      child: IconButton(
        icon: const Icon(Icons.lock_reset, size: 20, color: Colors.orange),
        onPressed: () => _showConfirmDialog(context),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Abandonner les modifications ?'),
        content: const Text(
          'Vos modifications locales non sauvegardées seront perdues. '
          'La version Google Drive sera rechargée et le verrou libéré.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Abandonner'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) syncService.abandonWrite();
    });
  }
}

class _SaveIconBtn extends StatelessWidget {
  final SyncService syncService;
  const _SaveIconBtn({required this.syncService});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Sauvegarder',
      preferBelow: false,
      child: IconButton(
        icon: const Icon(Icons.save, size: 20, color: Colors.green),
        onPressed: syncService.sync,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _QuitIconBtn extends StatelessWidget {
  final SyncService syncService;
  const _QuitIconBtn({required this.syncService});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Quitter',
      preferBelow: false,
      child: IconButton(
        icon: const Icon(Icons.exit_to_app, size: 20, color: Colors.red),
        onPressed: () => _showQuitDialog(context),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _showQuitDialog(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sauvegarder et quitter ?'),
        content: const Text(
          'Vos modifications seront envoyées sur Drive et le verrou libéré.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Quitter'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) syncService.releaseAndExit();
    });
  }
}

class _SyncIconBtn extends StatelessWidget {
  final SyncService syncService;
  const _SyncIconBtn({required this.syncService});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Synchroniser',
      preferBelow: false,
      child: IconButton(
        icon: const Icon(Icons.sync, size: 20),
        onPressed: syncService.sync,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
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
  final String? title;
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onClose;
  final String? closeLabel;

  const _SyncErrorDialog({
    required this.message,
    this.title,
    this.onRetry,
    this.onClose,
    this.closeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title ?? 'Erreur de synchronisation'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onClose?.call();
          },
          child: Text(closeLabel ?? 'Fermer'),
        ),
        if (onRetry != null)
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            child: const Text('Réessayer'),
          ),
      ],
    );
  }
}
