// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'dart:io' show Platform, exit;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/config_service.dart';
import '../l10n/l10n.dart';
import '../services/sync_service.dart';
import '../widgets/sync_status_indicator.dart';

const kDesktopBreakpoint = 600.0;

const _kSaveColor = Colors.green;

bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= kDesktopBreakpoint;

class _AppDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String route;

  const _AppDestination({
    required this.icon,
    required this.selectedIcon,
    required this.route,
  });
}

const _destinations = [
  _AppDestination(
    icon: Icons.wine_bar_outlined,
    selectedIcon: Icons.wine_bar,
    route: '/',
  ),
  _AppDestination(
    icon: Icons.add_circle_outline,
    selectedIcon: Icons.add_circle,
    route: '/bulk-add',
  ),
  _AppDestination(
    icon: Icons.shelves,
    selectedIcon: Icons.shelves,
    route: '/locations',
  ),
  _AppDestination(
    icon: Icons.history,
    selectedIcon: Icons.history,
    route: '/history',
  ),
  _AppDestination(
    icon: Icons.import_export,
    selectedIcon: Icons.import_export,
    route: '/data',
  ),
  _AppDestination(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    route: '/settings',
  ),
];

String _navLabel(int index, AppLocalizations l10n) => [
      l10n.navStock,
      l10n.navAjouter,
      l10n.navEmplacements,
      l10n.navHistorique,
      l10n.navDonnees,
      l10n.navParametres,
    ][index];

class AppShell extends ConsumerStatefulWidget {
  final int selectedIndex;
  final Widget child;

  const AppShell({super.key, required this.selectedIndex, required this.child});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  static const _writeOnlyIndices = {1};

  @override
  void initState() {
    super.initState();
    // Cas ProviderScope recréé après download Drive : le nouveau SyncService
    // démarre directement en SyncIdle — ref.listen ne voit pas SyncStarting→SyncIdle.
    // On vérifie pendingWriteOnboarding après le premier frame, quand il est posé.
    if (Platform.isAndroid) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!pendingWriteOnboarding || !mounted) return;
        pendingWriteOnboarding = false;
        final seen = await configService.getAndroidWriteWarningSeen();
        if (seen || !mounted) return;
        showDialog<void>(context: context, builder: (_) => const _WriteOnboardingDialog());
      });
    }
  }

  void _triggerWriteOnboarding(BuildContext context) {
    pendingWriteOnboarding = false;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final seen = await configService.getAndroidWriteWarningSeen();
      if (seen || !mounted) return;
      showDialog<void>(context: context, builder: (_) => const _WriteOnboardingDialog());
    });
  }

  void _onDestinationSelected(BuildContext context, int index) {
    if (Platform.isAndroid && index == 4) {
      _showMoreMenuSheet(context);
      return;
    }
    final syncState = ref.read(syncServiceProvider);
    if (syncState is SyncReadOnly && _writeOnlyIndices.contains(index)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.syncReadOnlyUnavailable)),
      );
      return;
    }
    context.go(_destinations[index].route);
  }

  void _showMoreMenuSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => _MoreMenuSheet(
        onImportCsv: () {
          Navigator.of(ctx).pop();
          context.go('/data');
        },
        onSettings: () {
          Navigator.of(ctx).pop();
          context.go('/settings');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final syncState = ref.watch(syncServiceProvider);
    ref.watch(storageModeProvider);
    final syncService = ref.read(syncServiceProvider.notifier);

    ref.listen<SyncState>(syncServiceProvider, (previous, next) {
      if (!mounted) return;
      switch (next) {
        case SyncIdle():
          if (previous is SyncSyncing) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.syncSavedToDrive)),
            );
          }
          if (Platform.isAndroid && pendingWriteOnboarding) {
            _triggerWriteOnboarding(context);
          }
        case SyncReadOnly():
          if (previous is SyncSyncing) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.syncSavedAndUnlocked)),
            );
          }
        case SyncError(:final message):
          final wasAcquiringLock = previous is SyncStarting;
          if (wasAcquiringLock) syncService.resetToReadOnly();
          showDialog<void>(
            context: context,
            builder: (_) => _SyncErrorDialog(
              title: wasAcquiringLock ? l10n.syncAcquireLockFailedTitle : null,
              message: wasAcquiringLock ? l10n.syncAcquireLockFailedBody : message,
              onRetry: wasAcquiringLock ? syncService.acquireLock : syncService.sync,
              onClose: null,
              closeLabel: wasAcquiringLock ? l10n.syncStayReadOnly : null,
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

    final isBlocking = syncState is SyncSyncing ||
        syncState is SyncStarting ||
        syncState is SyncNeedsCrashRecovery ||
        syncState is SyncNeedsLockChoice ||
        syncState is SyncExiting;

    final isReadOnly = syncState is SyncReadOnly;

    final showSyncButton = syncService.isActive &&
        (syncState is SyncIdle || syncState is SyncSyncing || syncState is SyncError);

    final isAndroid = Platform.isAndroid;
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
                      _overlayMessage(syncState, l10n),
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

  String _overlayMessage(SyncState state, AppLocalizations l10n) => switch (state) {
        SyncStarting() || SyncNeedsCrashRecovery() || SyncNeedsLockChoice() =>
          l10n.syncConnecting,
        SyncExiting() || SyncSyncing() => l10n.syncSaving,
        _ => l10n.syncSyncing,
      };

  void _showCrashRecoveryDialog(BuildContext context, SyncService syncService) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.syncCrashRecoveryTitle),
        content: Text(l10n.syncCrashRecoveryBody),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _showCrashRecoveryConfirm(
                context,
                syncService,
                title: l10n.syncCrashSendLocalConfirmTitle,
                content: l10n.syncCrashSendLocalConfirmBody,
                confirmLabel: l10n.syncCrashConfirmSend,
                onConfirm: syncService.resolveOwnLockWithUpload,
                onCancel: () => _showCrashRecoveryDialog(context, syncService),
              );
            },
            child: Text(l10n.syncCrashSendLocal),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _showCrashRecoveryConfirm(
                context,
                syncService,
                title: l10n.syncCrashDownloadConfirmTitle,
                content: l10n.syncCrashDownloadConfirmBody,
                confirmLabel: l10n.syncCrashConfirmReplace,
                onConfirm: syncService.resolveOwnLockWithDownload,
                onCancel: () => _showCrashRecoveryDialog(context, syncService),
              );
            },
            child: Text(l10n.syncCrashDownloadDrive),
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
    final l10n = context.l10n;
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
            child: Text(l10n.actionRetour),
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
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.syncLockTiersTitle),
        content: Text(l10n.syncLockTiersBody),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              exit(0);
            },
            child: Text(l10n.actionQuitter),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              syncService.enterReadOnly();
            },
            child: Text(l10n.syncEnterReadOnly),
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
    final l10n = context.l10n;

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
          label: Text(
            _navLabel(e.key, l10n),
            style: TextStyle(color: disabled ? cs.outline : null),
          ),
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
    final l10n = context.l10n;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      color: cs.surfaceContainer,
      padding: EdgeInsets.only(bottom: bottomPad),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
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
            _NavBtn(
              tooltip: l10n.navStock,
              icon: Icons.wine_bar_outlined,
              selectedIcon: Icons.wine_bar,
              selected: selectedIndex == 0,
              onTap: () => onDestinationSelected(0),
            ),
            _NavBtn(
              tooltip: isReadOnly
                  ? '${l10n.navAjouter} — ${l10n.syncReadOnlyUnavailable}'
                  : l10n.navAjouter,
              icon: Icons.add_circle_outline,
              selectedIcon: Icons.add_circle,
              selected: selectedIndex == 1,
              enabled: !isReadOnly,
              onTap: () => onDestinationSelected(1),
            ),
            _NavBtn(
              tooltip: l10n.navEmplacements,
              icon: Icons.shelves,
              selectedIcon: Icons.shelves,
              selected: selectedIndex == 2,
              onTap: () => onDestinationSelected(2),
              compact: true,
            ),
            _NavBtn(
              tooltip: l10n.navHistorique,
              icon: Icons.history,
              selectedIcon: Icons.history,
              selected: selectedIndex == 3,
              onTap: () => onDestinationSelected(3),
              compact: true,
            ),
            const Spacer(),
            _NavBtn(
              tooltip: l10n.navPlus,
              icon: Icons.more_horiz,
              selectedIcon: Icons.more_horiz,
              selected: selectedIndex >= 4,
              onTap: () => onDestinationSelected(4),
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
  final l10n = context.l10n;
  showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.syncAcquireLockTitle),
      content: Text(
        isAndroid ? l10n.syncAcquireLockBodyAndroid : l10n.syncAcquireLockBodyDesktop,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l10n.actionAnnuler),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(l10n.actionConfirmer),
        ),
      ],
    ),
  ).then((confirmed) {
    if (confirmed == true) syncService.acquireLock();
  });
}

// ── Dialog onboarding mode écriture Android ───────────────────────────────────

class _WriteOnboardingDialog extends StatefulWidget {
  const _WriteOnboardingDialog();

  @override
  State<_WriteOnboardingDialog> createState() => _WriteOnboardingDialogState();
}

class _WriteOnboardingDialogState extends State<_WriteOnboardingDialog> {
  bool _dontShowAgain = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.syncWriteOnboardingTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.syncWriteOnboardingBody),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: _dontShowAgain,
                onChanged: (v) => setState(() => _dontShowAgain = v ?? false),
              ),
              Text(l10n.syncWriteOnboardingDontShow),
            ],
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () {
            if (_dontShowAgain) configService.setAndroidWriteWarningSeen();
            Navigator.of(context).pop();
          },
          child: Text(l10n.actionOk),
        ),
      ],
    );
  }
}

// ── Boutons icône compacts pour la barre Android ─────────────────────────────

class _AcquireLockIconBtn extends StatelessWidget {
  final SyncService syncService;
  const _AcquireLockIconBtn({required this.syncService});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.l10n.tooltipPrendreLaMain,
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
      label: Text(context.l10n.syncPrendreLaMain),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}

class _SaveIconBtn extends StatelessWidget {
  final SyncService syncService;
  const _SaveIconBtn({required this.syncService});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.l10n.tooltipSauvegarder,
      preferBelow: false,
      child: IconButton(
        icon: const Icon(Icons.save, size: 20, color: _kSaveColor),
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
      message: context.l10n.actionQuitter,
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
    final l10n = context.l10n;
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.quitDialogTitle),
        content: Text(l10n.quitDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionAnnuler),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.actionQuitter),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed != true) return;
      try {
        await syncService.tryRelease();
        exit(0);
      } catch (_) {
        if (!context.mounted) {
          exit(0);
          return;
        }
        final forceQuit = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx2) => AlertDialog(
            title: Text(l10n.quitFailTitle),
            content: Text(l10n.quitFailBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx2).pop(false),
                child: Text(l10n.actionAnnuler),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(ctx2).pop(true),
                child: Text(l10n.quitAnyway),
              ),
            ],
          ),
        );
        if (forceQuit == true) exit(0);
      }
    });
  }
}

class _SyncIconBtn extends StatelessWidget {
  final SyncService syncService;
  const _SyncIconBtn({required this.syncService});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.l10n.tooltipSauvegarder,
      preferBelow: false,
      child: IconButton(
        icon: const Icon(Icons.save, size: 20, color: _kSaveColor),
        onPressed: syncService.sync,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
      ),
    );
  }
}

// ── Bouton Sauvegarder ────────────────────────────────────────────────────────

class _SyncButton extends StatelessWidget {
  final SyncService syncService;

  const _SyncButton({required this.syncService});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: syncService.sync,
      icon: const Icon(Icons.save, size: 16, color: _kSaveColor),
      label: Text(context.l10n.syncSauvegarder),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}

// ── Menu Plus (Android) ───────────────────────────────────────────────────────

class _MoreMenuSheet extends StatelessWidget {
  final VoidCallback onImportCsv;
  final VoidCallback onSettings;

  const _MoreMenuSheet({
    required this.onImportCsv,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.import_export),
            title: Text(l10n.navDonnees),
            onTap: onImportCsv,
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(l10n.navParametres),
            onTap: onSettings,
          ),
        ],
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
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(title ?? l10n.syncErrorTitle),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onClose?.call();
          },
          child: Text(closeLabel ?? l10n.actionFermer),
        ),
        if (onRetry != null)
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            child: Text(l10n.actionReessayer),
          ),
      ],
    );
  }
}
