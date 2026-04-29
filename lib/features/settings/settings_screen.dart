// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'dart:io' show File, Platform, exit;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

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
          // ── Emplacement cave.db (Mode 1 uniquement) ──────────────────────
          if (!isMode2) ...[
            _SectionTitle('Emplacement de la cave'),
            const _DbPathSection(),
            const Divider(height: 32),
          ],

          // ── Valeurs par défaut ajout en lot ───────────────────────────────
          _SectionTitle('Ajout en lot — valeurs par défaut'),
          const _BulkAddDefaultsSection(),
          const Divider(height: 32),

          // ── Listes de référence ───────────────────────────────────────────
          _SectionTitle('Listes de référence'),
          _RefListEditor(
            title: 'Couleurs',
            initialValues: configService.refCouleurs,
            onSave: configService.saveRefCouleurs,
          ),
          _RefListEditor(
            title: 'Contenances',
            initialValues: configService.refContenances,
            onSave: configService.saveRefContenances,
          ),
          _RefListEditor(
            title: 'Crus',
            initialValues: configService.refCrus,
            onSave: configService.saveRefCrus,
          ),
          const Divider(height: 32),

          // ── Mode de synchronisation ───────────────────────────────────────
          _SectionTitle('Mode de synchronisation'),
          if (!isMode2)
            _DriveActivationTile(ref: ref)
          else
            _DriveActiveTile(ref: ref),
          const Divider(height: 32),

          // ── À propos ──────────────────────────────────────────────────────
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
                      onPressed: () => launchUrl(
                        Uri.parse('https://alainbenard54-collab.github.io/cavea/privacy.html'),
                        mode: LaunchMode.externalApplication,
                      ),
                      child: const Text('Confidentialité'),
                    ),
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
                      child: const Text('Licences'),
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

// ── Helpers ───────────────────────────────────────────────────────────────────

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

// ── Section chemin cave.db (Mode 1) ──────────────────────────────────────────

class _DbPathSection extends StatefulWidget {
  const _DbPathSection();

  @override
  State<_DbPathSection> createState() => _DbPathSectionState();
}

class _DbPathSectionState extends State<_DbPathSection> {
  late String _dirPath;

  @override
  void initState() {
    super.initState();
    final dbPath = configService.config?.dbPath ?? '';
    _dirPath = dbPath.isEmpty ? '(non configuré)' : p.dirname(dbPath);
  }

  Future<void> _pickDir() async {
    final dir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Dossier contenant cave.db',
    );
    if (dir == null || !mounted) return;
    final current = configService.config!;
    await configService.save(AppConfig(
      storageMode: current.storageMode,
      dbPath: p.join(dir, 'cave.db'),
    ));
    setState(() => _dirPath = dir);
    if (!mounted) return;
    // Forcer la fermeture — continuer avec l'ancien chemin risque une corruption.
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Redémarrage requis'),
        content: const Text(
          'Le dossier de la cave a été modifié.\n\n'
          'L\'application doit redémarrer pour utiliser le nouveau chemin.',
        ),
        actions: [
          FilledButton(
            onPressed: () => exit(0),
            child: const Text('Quitter l\'application'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.folder_outlined),
      title: const Text('Dossier cave.db'),
      subtitle: Text(_dirPath, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: OutlinedButton(
        onPressed: _pickDir,
        child: const Text('Modifier'),
      ),
    );
  }
}

// ── Section valeurs par défaut bulk-add ──────────────────────────────────────

class _BulkAddDefaultsSection extends StatefulWidget {
  const _BulkAddDefaultsSection();

  @override
  State<_BulkAddDefaultsSection> createState() => _BulkAddDefaultsSectionState();
}

class _BulkAddDefaultsSectionState extends State<_BulkAddDefaultsSection> {
  late String _couleur;
  late TextEditingController _contenanceCtrl;

  @override
  void initState() {
    super.initState();
    _couleur = configService.couleurDefaut;
    _contenanceCtrl = TextEditingController(text: configService.contenanceDefaut);
  }

  @override
  void dispose() {
    _contenanceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final couleurs = configService.refCouleurs;
    final displayCouleur = couleurs.contains(_couleur) ? _couleur : null;

    return Column(
      children: [
        ListTile(
          title: const Text('Couleur par défaut'),
          trailing: DropdownButton<String>(
            value: displayCouleur,
            hint: const Text('Choisir…'),
            items: couleurs
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() => _couleur = v);
              configService.saveBulkAddDefaults(couleur: v);
            },
          ),
        ),
        ListTile(
          title: const Text('Contenance par défaut'),
          trailing: SizedBox(
            width: 130,
            child: TextField(
              controller: _contenanceCtrl,
              textAlign: TextAlign.end,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onSubmitted: (v) => configService.saveBulkAddDefaults(contenance: v.trim()),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Éditeur de liste de référence ────────────────────────────────────────────

class _RefListEditor extends StatefulWidget {
  final String title;
  final List<String> initialValues;
  final Future<void> Function(List<String>) onSave;

  const _RefListEditor({
    required this.title,
    required this.initialValues,
    required this.onSave,
  });

  @override
  State<_RefListEditor> createState() => _RefListEditorState();
}

class _RefListEditorState extends State<_RefListEditor> {
  late List<String> _values;
  final _addCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _values = List.from(widget.initialValues);
  }

  @override
  void dispose() {
    _addCtrl.dispose();
    super.dispose();
  }

  void _remove(String v) {
    setState(() => _values.remove(v));
    widget.onSave(List.from(_values));
  }

  void _add() {
    final v = _addCtrl.text.trim();
    if (v.isEmpty || _values.contains(v)) return;
    setState(() => _values.add(v));
    _addCtrl.clear();
    widget.onSave(List.from(_values));
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(widget.title),
      subtitle: Text('${_values.length} valeur${_values.length > 1 ? 's' : ''}'),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _values
                    .map((v) => InputChip(
                          label: Text(v),
                          onDeleted: () => _remove(v),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _addCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Ajouter une valeur…',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _add(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _add,
                    tooltip: 'Ajouter',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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

    // Vérifier si une cave existe déjà sur Drive
    bool remoteExists = false;
    try {
      remoteExists = await adapter.remoteDbExists();
    } catch (_) {}

    if (!context.mounted) return;

    // Choix selon l'état du Drive
    final choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Migrer vers Google Drive'),
        content: Text(
          remoteExists
              ? 'Une cave existe déjà sur Google Drive.\n\n'
                'Que souhaitez-vous faire ?'
              : 'Voulez-vous envoyer votre cave locale vers Google Drive ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(null),
            child: const Text('Annuler'),
          ),
          if (remoteExists) ...[
            OutlinedButton(
              onPressed: () => Navigator.of(dialogContext).pop('download'),
              child: const Text('Récupérer la cave du Drive'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop('upload'),
              child: const Text('Écraser le Drive avec ma cave locale'),
            ),
          ] else
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop('upload'),
              child: const Text('Envoyer ma cave vers Drive'),
            ),
        ],
      ),
    );

    if (choice == null) {
      await adapter.signOut();
      return;
    }

    // Confirmation secondaire avant tout écrasement de données
    if (!context.mounted) return;
    final confirmTitle = choice == 'download'
        ? 'Écraser la base locale ?'
        : 'Écraser la version Drive ?';
    final confirmContent = choice == 'download'
        ? 'Votre base locale sera remplacée par la version Google Drive. Toutes les données locales non présentes sur Drive seront perdues.'
        : 'La version sur Google Drive sera remplacée par votre base locale. Toutes les données Drive non présentes localement seront perdues.';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(confirmTitle),
        content: Text(confirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirm != true) {
      await adapter.signOut();
      return;
    }

    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);

    if (choice == 'download') {
      messenger.showSnackBar(
        const SnackBar(content: Text('Téléchargement en cours…'), duration: Duration(minutes: 1)),
      );
      try {
        await adapter.downloadDb(configService.config!.dbPath);
        await adapter.lock();
      } catch (e) {
        messenger.clearSnackBars();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Téléchargement échoué : $e')),
        );
        return;
      }
    } else {
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
      trailing: Platform.isAndroid
          ? null
          : OutlinedButton(
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

    // Libérer le lock Drive si on le détient (upload + unlock).
    try {
      await activeSyncService?.releaseIfNeeded();
    } catch (_) {
      // Échec réseau : on bascule quand même en local, le lock expirera en 24h.
    }

    // Supprimer le token OAuth pour forcer un nouveau flow à la prochaine activation.
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
