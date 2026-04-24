// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config_service.dart';
import '../../services/drive_storage_adapter.dart';
import 'setup_controller.dart';

class SetupScreen extends ConsumerWidget {
  final void Function(AppConfig config) onComplete;

  const SetupScreen({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(setupControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuration de Cavea')),
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
              SetupStep.driveAuth => _DriveAuthStep(
                state: state,
                controller: ref.read(setupControllerProvider.notifier),
              ),
              SetupStep.driveChoice => _DriveChoiceStep(
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Bienvenue dans Cavea',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text('Choisissez votre mode de fonctionnement :'),
        const SizedBox(height: 24),
        if (!Platform.isAndroid) ...[
          _ModeCard(
            title: 'PC seul (local)',
            description: 'La base de données est stockée localement sur ce PC.',
            icon: Icons.computer,
            onTap: () => onSelect('local'),
          ),
          const SizedBox(height: 12),
        ],
        _ModeCard(
          title: 'Mode partagé (Google Drive)',
          description: Platform.isAndroid
              ? 'Synchronisation via Google Drive — nécessite un compte Google.'
              : 'Synchronisation via Google Drive — nécessite un compte Google et le fichier google_desktop_secrets.json.',
          icon: Icons.sync,
          onTap: () => onSelect('drive'),
        ),
        if (!Platform.isAndroid) ...[
          const SizedBox(height: 12),
          _ModeCard(
            title: 'Mobile seul',
            description: 'Non disponible dans cette version.',
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Dossier de la base de données',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        const Text(
          'Choisissez le dossier où sera stocké cave.db.\n'
          'Ce dossier doit exister.',
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: 'Chemin du dossier',
                  errorText: state.errorMessage,
                  border: const OutlineInputBorder(),
                ),
                onChanged: controller.setFolderPath,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              icon: const Icon(Icons.folder_open),
              tooltip: 'Parcourir',
              onPressed: () async {
                final dir = await FilePicker.platform.getDirectoryPath(
                  dialogTitle: 'Choisir le dossier de cave.db',
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
          child: const Text('Suivant'),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Confirmer la configuration',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
        _ConfigRow(label: 'Mode', value: 'PC seul (local)'),
        const SizedBox(height: 8),
        _ConfigRow(
          label: 'Base de données',
          value: '${state.folderPath}/cave.db',
        ),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: () async {
            final config = await controller.confirm();
            onComplete(config);
          },
          child: const Text('Démarrer Cavea'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: controller.backToPathInput,
          child: const Text('Modifier le chemin'),
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Connexion Google Drive',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        if (Platform.isAndroid) ...[
          const Text(
            'Un cache local de la base sera maintenu dans le stockage privé de l\'application '
            '(non accessible depuis l\'explorateur de fichiers Android).\n'
            'Connectez votre compte Google pour continuer.',
          ),
        ] else ...[
          const Text(
            'Choisissez d\'abord le dossier local pour cave.db (cache de travail), '
            'puis connectez votre compte Google.',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: folderController,
                  decoration: InputDecoration(
                    labelText: 'Dossier local (cache)',
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
                    dialogTitle: 'Dossier local pour cave.db',
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
            label: const Text('Connecter Google Drive'),
            onPressed: () async {
              if (!Platform.isAndroid &&
                  (state.folderPath.isEmpty || !Directory(state.folderPath).existsSync())) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Choisissez un dossier local valide.')),
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
          child: const Text('Retour'),
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
        SnackBar(content: Text('Téléchargement échoué : $e')),
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
      builder: (ctx) => AlertDialog(
        title: const Text('Écraser la cave existante ?'),
        content: const Text(
          'Cette action supprimera définitivement cave.db du Drive '
          'et le remplacera par une base vide. '
          'Toutes les données actuelles seront perdues.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
    if (confirm1 != true || !mounted) return;

    final confirm2 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmation finale'),
        content: const Text(
          'Cette opération est IRRÉVERSIBLE.\n\n'
          'La cave existante sera définitivement effacée. '
          'Confirmez-vous vouloir créer une nouvelle cave vide ?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Oui, écraser définitivement'),
          ),
        ],
      ),
    );
    if (confirm2 != true || !mounted) return;

    try {
      final config = await widget.controller.confirmDriveOverwrite();
      widget.onComplete(config);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Google Drive connecté',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
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
          child: const Text('Retour'),
        ),
      ],
    );
  }

  Widget _buildNoCave(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DetectionCard(
          icon: Icons.cloud_off_outlined,
          text: 'Aucune cave n\'a été détectée sur Google Drive.',
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Créer une cave vide'),
          onPressed: _handleNew,
        ),
      ],
    );
  }

  Widget _buildCaveFound(BuildContext context, SetupState state) {
    final locked = state.driveLockedByOther;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DetectionCard(
          icon: Icons.cloud_done_outlined,
          text: 'Une cave a été détectée sur Google Drive.',
        ),
        const SizedBox(height: 24),

        // Rejoindre — toujours actif ; label adapté selon verrou
        FilledButton.icon(
          icon: const Icon(Icons.cloud_download),
          label: Text(locked
              ? 'Rejoindre la cave existante (lecture seule)'
              : 'Rejoindre la cave existante'),
          onPressed: _handleJoin,
        ),

        const SizedBox(height: 12),

        // Écraser — désactivé si verrou tiers
        OutlinedButton.icon(
          icon: Icon(Icons.delete_forever, color: locked ? Colors.grey : Colors.red),
          label: Text(
            'Écraser par une nouvelle cave vide',
            style: TextStyle(color: locked ? Colors.grey : Colors.red),
          ),
          onPressed: locked ? null : _handleOverwrite,
        ),

        if (locked) ...[
          const SizedBox(height: 6),
          Text(
            'Impossible d\'écraser : la cave est verrouillée par un autre appareil'
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
