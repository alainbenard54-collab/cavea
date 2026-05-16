// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config_service.dart';
import '../../l10n/l10n.dart';
import '../../services/drive_storage_adapter.dart';
import '../../services/dropbox_storage_adapter.dart';
import 'setup_controller.dart';

class SetupScreen extends ConsumerWidget {
  final void Function(AppConfig config) onComplete;

  const SetupScreen({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(setupControllerProvider);

    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.setupTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: switch (state.step) {
              SetupStep.modeChoice => _ModeChoiceStep(
                onSelect: ref.read(setupControllerProvider.notifier).selectMode,
              ),
              SetupStep.pathInput => _PathInputStep(
                state: state,
                controller: ref.read(setupControllerProvider.notifier),
                onComplete: onComplete,
              ),
              SetupStep.confirmation => _ConfirmationStep(
                state: state,
                controller: ref.read(setupControllerProvider.notifier),
                onComplete: onComplete,
              ),
              SetupStep.providerChoice => _ProviderChoiceStep(
                onSelectProvider: ref.read(setupControllerProvider.notifier).selectProvider,
                onBack: ref.read(setupControllerProvider.notifier).backToModeChoice,
              ),
              SetupStep.driveAuth => _DriveAuthStep(
                state: state,
                controller: ref.read(setupControllerProvider.notifier),
              ),
              SetupStep.driveChoice => _DriveChoiceStep(
                state: state,
                controller: ref.read(setupControllerProvider.notifier),
                onComplete: onComplete,
              ),
              SetupStep.dropboxAuth => _DropboxAuthStep(
                state: state,
                controller: ref.read(setupControllerProvider.notifier),
              ),
              SetupStep.dropboxChoice => _DropboxChoiceStep(
                state: state,
                controller: ref.read(setupControllerProvider.notifier),
                onComplete: onComplete,
              ),
            },
          ),
        ),
      ),
    );
  }
}

// ── Choix du mode ─────────────────────────────────────────────────────────────

class _ModeChoiceStep extends StatelessWidget {
  final void Function(String) onSelect;

  const _ModeChoiceStep({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.setupWelcome, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(l10n.setupChooseMode),
        const SizedBox(height: 24),
        if (!Platform.isAndroid) ...[
          _ModeCard(
            title: l10n.setupModeLocal,
            description: l10n.setupModeLocalDesc,
            icon: Icons.computer,
            onTap: () => onSelect('local'),
          ),
          const SizedBox(height: 12),
        ],
        _ModeCard(
          title: l10n.setupModeDrive,
          description: l10n.setupModeDriveDesc,
          icon: Icons.sync,
          onTap: () => onSelect('shared'),
        ),
        if (!Platform.isAndroid) ...[
          const SizedBox(height: 12),
          _ModeCard(
            title: l10n.setupModeMobile,
            description: l10n.setupModeMobileDesc,
            icon: Icons.phone_android,
            enabled: false,
            onTap: null,
          ),
        ],
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  const _ModeCard({
    required this.title,
    required this.description,
    required this.icon,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: enabled ? null : Colors.grey),
        title: Text(
          title,
          style: TextStyle(color: enabled ? null : Colors.grey),
        ),
        subtitle: Text(description),
        trailing: enabled ? const Icon(Icons.chevron_right) : null,
        onTap: onTap,
        enabled: enabled,
      ),
    );
  }
}

// ── Mode 1 : saisie chemin ────────────────────────────────────────────────────

class _PathInputStep extends ConsumerWidget {
  final SetupState state;
  final SetupController controller;
  final void Function(AppConfig) onComplete;

  const _PathInputStep({
    required this.state,
    required this.controller,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController(text: state.folderPath);

    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.setupFolderTitle, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(l10n.setupFolderDesc),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: l10n.setupFolderPath,
                  errorText: state.errorMessage,
                  border: const OutlineInputBorder(),
                ),
                onChanged: controller.setFolderPath,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              icon: const Icon(Icons.folder_open),
              tooltip: l10n.setupParcourir,
              onPressed: () async {
                final dir = await FilePicker.platform.getDirectoryPath(
                  dialogTitle: l10n.setupPickerTitle,
                );
                if (dir != null) {
                  controller.setFolderPath(dir);
                  textController.text = dir;
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => controller.validateAndAdvance(),
          child: Text(l10n.actionSuivant),
        ),
      ],
    );
  }
}

// ── Mode 1 : confirmation ─────────────────────────────────────────────────────

class _ConfirmationStep extends StatelessWidget {
  final SetupState state;
  final SetupController controller;
  final void Function(AppConfig) onComplete;

  const _ConfirmationStep({
    required this.state,
    required this.controller,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.setupConfirmTitle, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        _ConfigRow(label: l10n.setupConfirmMode, value: l10n.setupModeLocal),
        const SizedBox(height: 8),
        _ConfigRow(
          label: l10n.setupConfirmDb,
          value: '${state.folderPath}/cave.db',
        ),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: () async {
            final config = await controller.confirm();
            onComplete(config);
          },
          child: Text(l10n.setupDemarrer),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: controller.backToPathInput,
          child: Text(l10n.setupModifierChemin),
        ),
      ],
    );
  }
}

// ── Mode 2 : authentification Drive ──────────────────────────────────────────

class _DriveAuthStep extends ConsumerWidget {
  final SetupState state;
  final SetupController controller;

  const _DriveAuthStep({required this.state, required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folderController = TextEditingController(text: state.folderPath);

    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.setupDriveTitle, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        if (Platform.isAndroid) ...[
          Text(l10n.setupDriveDescAndroid),
        ] else ...[
          Text(l10n.setupDriveDescDesktop),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: folderController,
                  decoration: InputDecoration(
                    labelText: l10n.setupDriveLocalFolder,
                    errorText: state.errorMessage,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: controller.setFolderPath,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.folder_open),
                onPressed: () async {
                  final dir = await FilePicker.platform.getDirectoryPath(
                    dialogTitle: l10n.setupDrivePickerTitle,
                  );
                  if (dir != null) {
                    controller.setFolderPath(dir);
                    folderController.text = dir;
                  }
                },
              ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        if (state.isLoading)
          const Center(child: CircularProgressIndicator())
        else
          FilledButton.icon(
            icon: const Icon(Icons.login),
            label: Text(l10n.setupConnectDrive),
            onPressed: () async {
              if (!Platform.isAndroid &&
                  (state.folderPath.isEmpty || !Directory(state.folderPath).existsSync())) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.setupFolderRequired)),
                );
                return;
              }
              await controller.authenticateDrive(
                folderPath: state.folderPath,
                secretsPath: DriveStorageAdapter.desktopSecretsPath,
              );
            },
          ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: controller.backToModeChoice,
          child: Text(l10n.actionRetour),
        ),
      ],
    );
  }
}

// ── Mode 2 : choix après vérification état Drive ──────────────────────────────

class _DriveChoiceStep extends StatefulWidget {
  final SetupState state;
  final SetupController controller;
  final void Function(AppConfig) onComplete;

  const _DriveChoiceStep({
    required this.state,
    required this.controller,
    required this.onComplete,
  });

  @override
  State<_DriveChoiceStep> createState() => _DriveChoiceStepState();
}

class _DriveChoiceStepState extends State<_DriveChoiceStep> {
  Future<void> _handleJoin() async {
    try {
      final config = await widget.controller.confirmDriveDownload();
      widget.onComplete(config);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.driveDownloadFailed(e.toString()))),
      );
    }
  }

  Future<void> _handleNew() async {
    final config = await widget.controller.confirmDriveNew();
    widget.onComplete(config);
  }

  Future<void> _handleOverwrite() async {
    final confirm1 = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dl10n = ctx.l10n;
        return AlertDialog(
          title: Text(dl10n.setupOverwriteTitle),
          content: Text(dl10n.setupOverwriteBody),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(dl10n.actionAnnuler)),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: Text(dl10n.actionContinuer),
            ),
          ],
        );
      },
    );
    if (confirm1 != true || !mounted) return;

    final confirm2 = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dl10n = ctx.l10n;
        return AlertDialog(
          title: Text(dl10n.setupFinalConfirmTitle),
          content: Text(dl10n.setupFinalConfirmBody),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(dl10n.actionAnnuler)),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: Text(dl10n.setupEcraserDefinitivement),
            ),
          ],
        );
      },
    );
    if (confirm2 != true || !mounted) return;

    try {
      final config = await widget.controller.confirmDriveOverwrite();
      widget.onComplete(config);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.setupEchec(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.setupDriveConnectedTitle, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),

        if (state.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (!state.driveHasCave)
          _buildNoCave(context)
        else
          _buildCaveFound(context, state),

        const SizedBox(height: 16),
        TextButton(
          onPressed: widget.controller.backToModeChoice,
          child: Text(l10n.actionRetour),
        ),
      ],
    );
  }

  Widget _buildNoCave(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DetectionCard(icon: Icons.cloud_off_outlined, text: l10n.setupNoCave),
        const SizedBox(height: 24),
        FilledButton.icon(
          icon: const Icon(Icons.add),
          label: Text(l10n.setupCreerCave),
          onPressed: _handleNew,
        ),
      ],
    );
  }

  Widget _buildCaveFound(BuildContext context, SetupState state) {
    final l10n = context.l10n;
    final locked = state.driveLockedByOther;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DetectionCard(icon: Icons.cloud_done_outlined, text: l10n.setupCaveFound),
        const SizedBox(height: 24),

        FilledButton.icon(
          icon: const Icon(Icons.cloud_download),
          label: Text(locked ? l10n.setupJoinReadOnly : l10n.setupJoin),
          onPressed: _handleJoin,
        ),

        const SizedBox(height: 12),

        OutlinedButton.icon(
          icon: Icon(Icons.delete_forever, color: locked ? Colors.grey : Colors.red),
          label: Text(
            l10n.setupOverwriteButton,
            style: TextStyle(color: locked ? Colors.grey : Colors.red),
          ),
          onPressed: locked ? null : _handleOverwrite,
        ),

        if (locked) ...[
          const SizedBox(height: 6),
          Text(
            '${l10n.setupOverwriteLocked}'
            '${state.driveLockOwner != null ? ' (${state.driveLockOwner})' : ''}.',
            style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _DetectionCard extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetectionCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mode 2 : choix du fournisseur ─────────────────────────────────────────────

class _ProviderChoiceStep extends StatelessWidget {
  final void Function(String) onSelectProvider;
  final VoidCallback onBack;

  const _ProviderChoiceStep({required this.onSelectProvider, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.setupChooseProvider, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 24),
        _ModeCard(
          title: 'Google Drive',
          description: l10n.setupProviderDriveDesc,
          icon: Icons.cloud,
          onTap: () => onSelectProvider('drive'),
        ),
        const SizedBox(height: 12),
        _ModeCard(
          title: 'Dropbox',
          description: l10n.setupProviderDropboxDesc,
          icon: Icons.cloud_queue,
          onTap: () => onSelectProvider('dropbox'),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: onBack,
          child: Text(l10n.actionRetour),
        ),
      ],
    );
  }
}

// ── Mode 2 Dropbox : authentification ─────────────────────────────────────────

class _DropboxAuthStep extends ConsumerStatefulWidget {
  final SetupState state;
  final SetupController controller;

  const _DropboxAuthStep({required this.state, required this.controller});

  @override
  ConsumerState<_DropboxAuthStep> createState() => _DropboxAuthStepState();
}

class _DropboxAuthStepState extends ConsumerState<_DropboxAuthStep> {
  final _folderController = TextEditingController();
  final _appKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _folderController.text = widget.state.folderPath;
  }

  @override
  void dispose() {
    _folderController.dispose();
    _appKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.setupDropboxTitle, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        if (Platform.isAndroid) ...[
          Text(l10n.setupDropboxDescAndroid),
          const SizedBox(height: 16),
          TextField(
            controller: _appKeyController,
            decoration: InputDecoration(
              labelText: l10n.setupDropboxAppKey,
              errorText: state.errorMessage,
              border: const OutlineInputBorder(),
            ),
          ),
        ] else ...[
          Text(l10n.setupDropboxDescDesktop),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _folderController,
                  decoration: InputDecoration(
                    labelText: l10n.setupDriveLocalFolder,
                    errorText: state.errorMessage,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: widget.controller.setFolderPath,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.folder_open),
                onPressed: () async {
                  final dir = await FilePicker.platform.getDirectoryPath(
                    dialogTitle: l10n.setupDrivePickerTitle,
                  );
                  if (dir != null) {
                    widget.controller.setFolderPath(dir);
                    _folderController.text = dir;
                  }
                },
              ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        if (state.isLoading)
          const Center(child: CircularProgressIndicator())
        else
          FilledButton.icon(
            icon: const Icon(Icons.login),
            label: Text(l10n.setupConnectDropbox),
            onPressed: () async {
              if (!Platform.isAndroid &&
                  (state.folderPath.isEmpty || !Directory(state.folderPath).existsSync())) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.setupFolderRequired)),
                );
                return;
              }
              await widget.controller.authenticateDropbox(
                folderPath: Platform.isAndroid ? widget.state.folderPath : state.folderPath,
                androidAppKey: Platform.isAndroid ? _appKeyController.text.trim() : null,
              );
            },
          ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: widget.controller.backToProviderChoice,
          child: Text(l10n.actionRetour),
        ),
      ],
    );
  }
}

// ── Mode 2 Dropbox : choix après vérification ────────────────────────────────

class _DropboxChoiceStep extends StatefulWidget {
  final SetupState state;
  final SetupController controller;
  final void Function(AppConfig) onComplete;

  const _DropboxChoiceStep({
    required this.state,
    required this.controller,
    required this.onComplete,
  });

  @override
  State<_DropboxChoiceStep> createState() => _DropboxChoiceStepState();
}

class _DropboxChoiceStepState extends State<_DropboxChoiceStep> {
  Future<void> _handleJoin() async {
    try {
      final config = await widget.controller.confirmDropboxDownload();
      widget.onComplete(config);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.driveDownloadFailed(e.toString()))),
      );
    }
  }

  Future<void> _handleNew() async {
    final config = await widget.controller.confirmDropboxNew();
    widget.onComplete(config);
  }

  Future<void> _handleOverwrite() async {
    final confirm1 = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dl10n = ctx.l10n;
        return AlertDialog(
          title: Text(dl10n.setupOverwriteTitle),
          content: Text(dl10n.setupOverwriteBody),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(dl10n.actionAnnuler)),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: Text(dl10n.actionContinuer),
            ),
          ],
        );
      },
    );
    if (confirm1 != true || !mounted) return;

    final confirm2 = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dl10n = ctx.l10n;
        return AlertDialog(
          title: Text(dl10n.setupFinalConfirmTitle),
          content: Text(dl10n.setupFinalConfirmBody),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(dl10n.actionAnnuler)),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: Text(dl10n.setupEcraserDefinitivement),
            ),
          ],
        );
      },
    );
    if (confirm2 != true || !mounted) return;

    try {
      final config = await widget.controller.confirmDropboxOverwrite();
      widget.onComplete(config);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.setupEchec(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Dropbox connecté', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),

        if (state.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (!state.driveHasCave)
          _buildNoCave(context)
        else
          _buildCaveFound(context, state),

        const SizedBox(height: 16),
        TextButton(
          onPressed: widget.controller.backToProviderChoice,
          child: Text(l10n.actionRetour),
        ),
      ],
    );
  }

  Widget _buildNoCave(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DetectionCard(icon: Icons.cloud_off_outlined, text: 'Aucune cave n\'a été détectée sur Dropbox.'),
        const SizedBox(height: 24),
        FilledButton.icon(
          icon: const Icon(Icons.add),
          label: Text(l10n.setupCreerCave),
          onPressed: _handleNew,
        ),
      ],
    );
  }

  Widget _buildCaveFound(BuildContext context, SetupState state) {
    final l10n = context.l10n;
    final locked = state.driveLockedByOther;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DetectionCard(icon: Icons.cloud_done_outlined, text: 'Une cave a été détectée sur Dropbox.'),
        const SizedBox(height: 24),

        FilledButton.icon(
          icon: const Icon(Icons.cloud_download),
          label: Text(locked ? l10n.setupJoinReadOnly : l10n.setupJoin),
          onPressed: _handleJoin,
        ),

        const SizedBox(height: 12),

        OutlinedButton.icon(
          icon: Icon(Icons.delete_forever, color: locked ? Colors.grey : Colors.red),
          label: Text(
            l10n.setupOverwriteButton,
            style: TextStyle(color: locked ? Colors.grey : Colors.red),
          ),
          onPressed: locked ? null : _handleOverwrite,
        ),

        if (locked) ...[
          const SizedBox(height: 6),
          Text(
            '${l10n.setupOverwriteLocked}'
            '${state.driveLockOwner != null ? ' (${state.driveLockOwner})' : ''}.',
            style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _ConfigRow extends StatelessWidget {
  final String label;
  final String value;

  const _ConfigRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            '$label :',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}
