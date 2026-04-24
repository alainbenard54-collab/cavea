// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config_service.dart';
import '../../services/drive_storage_adapter.dart';
import '../../services/sync_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMode2 = ref.watch(storageModeProvider) == 'drive';

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle('Mode de synchronisation'),
          if (!isMode2)
            _DriveActivationTile(ref: ref)
          else
            _DriveActiveTile(ref: ref),
          const Divider(height: 32),
          _SectionTitle('À propos'),
          ListTile(
            leading: const Icon(Icons.wine_bar),
            title: const Text('Cavea'),
            subtitle: const Text('Gestionnaire de cave à vin personnel'),
            trailing: TextButton(
              onPressed: () => showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Cavea'),
                  content: const Text(
                    'Version 1.0.0\n\n© 2026 Alain Benard\nLicence Apache 2.0',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        showLicensePage(
                          context: context,
                          applicationName: 'Cavea',
                          applicationVersion: '1.0.0',
                          applicationLegalese: '© 2026 Alain Benard',
                        );
                      },
                      child: const Text('Voir les licences'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Fermer'),
                    ),
                  ],
                ),
              ),
              child: const Text('À propos'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

// ── Mode 1 → Mode 2 ───────────────────────────────────────────────────────────

class _DriveActivationTile extends ConsumerWidget {
  final WidgetRef ref;
  const _DriveActivationTile({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    return ListTile(
      leading: const Icon(Icons.cloud_outlined),
      title: const Text('Mode partagé (Google Drive)'),
      subtitle: const Text('Mode actuel : PC seul (local)'),
      trailing: FilledButton(
        onPressed: () => _activateDrive(context, widgetRef),
        child: const Text('Activer'),
      ),
    );
  }

  Future<void> _activateDrive(BuildContext context, WidgetRef ref) async {
    // Vérifier que le fichier de credentials Desktop existe
    final secretsPath = DriveStorageAdapter.desktopSecretsPath;
    if (!Platform.isAndroid && !File(secretsPath).existsSync()) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Fichier google_desktop_secrets.json introuvable à côté de l\'exécutable.\n'
            'Copiez-le depuis le template dans assets/.',
          ),
          duration: const Duration(seconds: 6),
        ),
      );
      return;
    }

    final adapter = DriveStorageAdapter();

    // Lancer l'authentification
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ouverture de l\'authentification Google…')),
    );

    try {
      if (!Platform.isAndroid) {
        final creds = await DriveStorageAdapter.loadDesktopCredentials(secretsPath);
        await adapter.authenticate(
          desktopClientId: creds.clientId,
          desktopClientSecret: creds.clientSecret,
        );
      } else {
        await adapter.authenticate();
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentification échouée : $e')),
      );
      return;
    }

    if (!context.mounted) return;

    // Proposer la migration
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Migrer vers Google Drive ?'),
        content: const Text(
          'Voulez-vous envoyer votre cave.db actuel vers Google Drive ?\n\n'
          'Tout fichier cave.db existant dans Drive sera écrasé.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Migrer'),
          ),
        ],
      ),
    );

    if (confirm != true) {
      await adapter.signOut();
      return;
    }

    // Upload
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Upload en cours…'), duration: Duration(minutes: 1)),
    );

    try {
      final dbFile = File(configService.config!.dbPath);
      await adapter.uploadDb(dbFile);
      await adapter.lock();
    } catch (e) {
      messenger.clearSnackBars();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload échoué : $e')),
      );
      return;
    }

    // Le prochain SyncService démarrera avec le lock déjà acquis
    primeNextSyncWithLock();

    // Basculer en Mode 2
    final newConfig = AppConfig(
      storageMode: 'drive',
      dbPath: configService.config!.dbPath,
    );
    await configService.save(newConfig);

    messenger.clearSnackBars();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mode 2 activé — synchronisation Google Drive disponible')),
    );

    ref.read(storageModeProvider.notifier).state = 'drive';
  }
}

// ── Mode 2 actif ──────────────────────────────────────────────────────────────

class _DriveActiveTile extends ConsumerWidget {
  final WidgetRef ref;
  const _DriveActiveTile({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    return ListTile(
      leading: const Icon(Icons.cloud_done, color: Colors.green),
      title: const Text('Mode partagé (Google Drive)'),
      subtitle: const Text('Mode actuel : synchronisation activée'),
      trailing: OutlinedButton(
        onPressed: () => _deactivateDrive(context, widgetRef),
        child: const Text('Revenir en local'),
      ),
    );
  }

  Future<void> _deactivateDrive(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Revenir en mode local ?'),
        content: const Text(
          'L\'app passera en mode PC seul.\n'
          'Votre cave.db local est conservé tel quel.\n'
          'Le fichier Drive n\'est pas supprimé.',
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
    );

    if (confirm != true) return;

    // Supprimer le token OAuth pour forcer un nouveau flow à la prochaine activation
    await DriveStorageAdapter().signOut();

    final newConfig = AppConfig(
      storageMode: 'local',
      dbPath: configService.config!.dbPath,
    );
    await configService.save(newConfig);

    ref.read(storageModeProvider.notifier).state = 'local';

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mode local activé')),
    );
  }
}
