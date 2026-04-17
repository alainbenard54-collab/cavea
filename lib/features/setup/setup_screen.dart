// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config_service.dart';
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
                onSelect:
                    ref.read(setupControllerProvider.notifier).selectMode,
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
            },
          ),
        ),
      ),
    );
  }
}

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
        _ModeCard(
          title: 'PC seul (local)',
          description: 'La base de données est stockée localement sur ce PC.',
          icon: Icons.computer,
          onTap: () => onSelect('local'),
        ),
        const SizedBox(height: 12),
        _ModeCard(
          title: 'PC + Android',
          description: 'Non disponible dans cette version.',
          icon: Icons.sync,
          enabled: false,
          onTap: null,
        ),
        const SizedBox(height: 12),
        _ModeCard(
          title: 'Mobile seul',
          description: 'Non disponible dans cette version.',
          icon: Icons.phone_android,
          enabled: false,
          onTap: null,
        ),
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
        trailing:
            enabled ? const Icon(Icons.chevron_right) : null,
        onTap: onTap,
        enabled: enabled,
      ),
    );
  }
}

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
