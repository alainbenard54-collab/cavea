// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'dart:io' show File, Platform, exit;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

import '../../core/config_service.dart';
import '../../core/locale_provider.dart';
import '../../l10n/l10n.dart';
import '../../services/drive_storage_adapter.dart';
import '../../services/dropbox_storage_adapter.dart';
import '../../services/sync_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final storageMode = ref.watch(storageModeProvider);
    final isMode2 = storageMode == 'drive' || storageMode == 'dropbox';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Emplacement cave.db (Mode 1 uniquement) ──────────────────────
          if (!isMode2) ...[
            _SectionTitle(l10n.settingsSectionCave),
            const _DbPathSection(),
            const Divider(height: 32),
          ],

          // ── Valeurs par défaut ajout en lot ───────────────────────────────
          _SectionTitle(l10n.settingsSectionDefaults),
          const _BulkAddDefaultsSection(),
          const Divider(height: 32),

          // ── Listes de référence ───────────────────────────────────────────
          _SectionTitle(l10n.settingsSectionListes),
          _RefListEditor(
            title: l10n.settingsRefCouleurs,
            initialValues: configService.refCouleurs,
            onSave: configService.saveRefCouleurs,
          ),
          _RefListEditor(
            title: l10n.settingsRefContenances,
            initialValues: configService.refContenances,
            onSave: configService.saveRefContenances,
          ),
          _RefListEditor(
            title: l10n.settingsRefCrus,
            initialValues: configService.refCrus,
            onSave: configService.saveRefCrus,
          ),
          const Divider(height: 32),

          // ── Langue ───────────────────────────────────────────────────────
          _SectionTitle(l10n.settingsSectionLangue),
          const _LanguageSection(),
          const Divider(height: 32),

          // ── Mode de synchronisation ───────────────────────────────────────
          _SectionTitle(l10n.settingsSectionSync),
          if (!isMode2)
            _CloudActivationTile(ref: ref)
          else
            _CloudActiveTile(storageMode: storageMode),
          const Divider(height: 32),

          // ── À propos ──────────────────────────────────────────────────────
          _SectionTitle(l10n.settingsSectionAbout),
          ListTile(
            leading: const Icon(Icons.wine_bar),
            title: Text(l10n.aboutTitle),
            subtitle: Text(l10n.aboutSubtitle),
            trailing: TextButton(
              onPressed: () => showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Text(l10n.aboutTitle),
                  content: Text('${l10n.aboutVersion}\n\n${l10n.aboutCopyright}'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        final lang = Localizations.localeOf(dialogContext).languageCode;
                        final page = lang == 'en' ? 'en' : 'fr';
                        launchUrl(
                          Uri.parse('https://alainbenard54-collab.github.io/cavea/privacy/$page.html'),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      child: Text(l10n.aboutConfidentialite),
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
                      child: Text(l10n.aboutLicences),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(l10n.actionFermer),
                    ),
                  ],
                ),
              ),
              child: Text(l10n.aboutButton),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section langue ────────────────────────────────────────────────────────────

class _LanguageSection extends ConsumerWidget {
  const _LanguageSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final selected = <String>{locale?.languageCode ?? 'auto'};

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SegmentedButton<String>(
        segments: [
          ButtonSegment(value: 'auto', label: Text(l10n.settingsLangAuto)),
          const ButtonSegment(value: 'fr', label: Text('Français')),
          const ButtonSegment(value: 'en', label: Text('English')),
        ],
        selected: selected,
        onSelectionChanged: (Set<String> s) {
          final code = s.first;
          ref.read(localeProvider.notifier).setLocale(code == 'auto' ? null : code);
        },
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
    _dirPath = dbPath.isEmpty ? '' : p.dirname(dbPath);
  }

  Future<void> _pickDir() async {
    final l10n = context.l10n;
    final dir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: l10n.settingsDbFolder,
    );
    if (dir == null || !mounted) return;
    final current = configService.config!;
    await configService.save(AppConfig(
      storageMode: current.storageMode,
      dbPath: p.join(dir, 'cave.db'),
    ));
    setState(() => _dirPath = dir);
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.settingsRestartTitle),
        content: Text(context.l10n.settingsRestartBody),
        actions: [
          FilledButton(
            onPressed: () => exit(0),
            child: Text(context.l10n.settingsQuitApp),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final displayDir = _dirPath.isEmpty ? l10n.settingsDbNotConfigured : _dirPath;
    return ListTile(
      leading: const Icon(Icons.folder_outlined),
      title: Text(l10n.settingsDbFolder),
      subtitle: Text(displayDir, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: OutlinedButton(
        onPressed: _pickDir,
        child: Text(l10n.actionModifier),
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
    final l10n = context.l10n;
    final couleurs = configService.refCouleurs;
    final displayCouleur = couleurs.contains(_couleur) ? _couleur : null;

    return Column(
      children: [
        ListTile(
          title: Text(l10n.settingsCouleurDefaut),
          trailing: DropdownButton<String>(
            value: displayCouleur,
            hint: Text(l10n.settingsChoisir),
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
          title: Text(l10n.settingsContenanceDefaut),
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
    final l10n = context.l10n;
    return ExpansionTile(
      title: Text(widget.title),
      subtitle: Text(l10n.settingsRefCount(_values.length)),
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
                      decoration: InputDecoration(
                        hintText: l10n.settingsRefAddHint,
                        isDense: true,
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _add(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _add,
                    tooltip: l10n.actionAjouter,
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

class _CloudActivationTile extends ConsumerWidget {
  final WidgetRef ref;
  const _CloudActivationTile({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final l10n = context.l10n;
    return ListTile(
      leading: const Icon(Icons.cloud_outlined),
      title: Text(l10n.settingsModePartage),
      subtitle: Text(l10n.settingsModeLocalCurrent),
      trailing: FilledButton(
        onPressed: () => _activateCloud(context, widgetRef),
        child: Text(l10n.settingsActiverDrive),
      ),
    );
  }

  Future<void> _activateCloud(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    // Choix du fournisseur
    final provider = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsChoisirFournisseur),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.cloud),
              title: const Text('Google Drive'),
              onTap: () => Navigator.of(ctx).pop('drive'),
            ),
            ListTile(
              leading: const Icon(Icons.cloud_queue),
              title: const Text('Dropbox'),
              onTap: () => Navigator.of(ctx).pop('dropbox'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: Text(l10n.actionAnnuler),
          ),
        ],
      ),
    );
    if (provider == null || !context.mounted) return;

    if (provider == 'drive') {
      await _activateDrive(context, ref);
    } else {
      await _activateDropbox(context, ref);
    }
  }

  Future<void> _activateDrive(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final secretsPath = DriveStorageAdapter.desktopSecretsPath;
    if (!Platform.isAndroid && !File(secretsPath).existsSync()) {
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.driveSetupMissingTitle),
          content: Text(l10n.driveSetupMissingBody),
          actions: [
            TextButton(
              onPressed: () => launchUrl(
                Uri.parse('https://alainbenard54-collab.github.io/cavea/setup-drive.html'),
                mode: LaunchMode.externalApplication,
              ),
              child: Text(l10n.driveGuideEnLigne),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.actionFermer),
            ),
          ],
        ),
      );
      return;
    }

    final adapter = DriveStorageAdapter();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.driveAuthOpening)),
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
        SnackBar(content: Text(l10n.driveAuthFailed(e.toString()))),
      );
      return;
    }

    if (!context.mounted) return;

    bool remoteExists = false;
    try {
      remoteExists = await adapter.remoteDbExists();
    } catch (_) {}

    if (!context.mounted) return;

    final choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.driveMigrateTitle),
        content: Text(
          remoteExists ? l10n.driveMigrateBodyExisting : l10n.driveMigrateBodyNew,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(null),
            child: Text(l10n.actionAnnuler),
          ),
          if (remoteExists) ...[
            OutlinedButton(
              onPressed: () => Navigator.of(dialogContext).pop('download'),
              child: Text(l10n.driveDownloadExisting),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop('upload'),
              child: Text(l10n.driveUploadOverwrite),
            ),
          ] else
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop('upload'),
              child: Text(l10n.driveSendNew),
            ),
        ],
      ),
    );

    if (choice == null) {
      await adapter.signOut();
      return;
    }

    if (!context.mounted) return;
    final confirmTitle = choice == 'download'
        ? l10n.driveConfirmOverwriteLocalTitle
        : l10n.driveConfirmOverwriteDriveTitle;
    final confirmContent = choice == 'download'
        ? l10n.driveConfirmOverwriteLocalBody
        : l10n.driveConfirmOverwriteDriveBody;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(confirmTitle),
        content: Text(confirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.actionAnnuler),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.actionConfirmer),
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
        SnackBar(
          content: Text(l10n.driveDownloading),
          duration: const Duration(minutes: 1),
        ),
      );
      try {
        await adapter.downloadDb(configService.config!.dbPath);
        await adapter.lock();
      } catch (e) {
        messenger.clearSnackBars();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.driveDownloadFailed(e.toString()))),
        );
        return;
      }
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.driveUploading),
          duration: const Duration(minutes: 1),
        ),
      );
      try {
        final dbFile = File(configService.config!.dbPath);
        await adapter.uploadDb(dbFile);
        await adapter.lock();
      } catch (e) {
        messenger.clearSnackBars();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.driveUploadFailed(e.toString()))),
        );
        return;
      }
    }

    primeNextSyncWithLock();

    final newConfig = AppConfig(
      storageMode: 'drive',
      dbPath: configService.config!.dbPath,
    );
    await configService.save(newConfig);

    messenger.clearSnackBars();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.driveModeActivated)),
    );

    ref.read(storageModeProvider.notifier).state = 'drive';
  }

  Future<void> _activateDropbox(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;

    // Desktop : vérifier le fichier secrets
    if (!Platform.isAndroid) {
      final secretsPath = DropboxStorageAdapter.desktopSecretsPath;
      if (!File(secretsPath).existsSync()) {
        if (!context.mounted) return;
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.dropboxSetupMissingTitle),
            content: Text(l10n.dropboxSetupMissingBody),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.actionFermer),
              ),
            ],
          ),
        );
        return;
      }
    }

    // Android : demander le App Key si pas encore stocké
    if (Platform.isAndroid) {
      final appKeyCtrl = TextEditingController();
      final appKey = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.setupDropboxAppKey),
          content: TextField(
            controller: appKeyCtrl,
            decoration: InputDecoration(
              labelText: l10n.dropboxAppKeyLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: Text(context.l10n.actionAnnuler),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(appKeyCtrl.text.trim()),
              child: Text(context.l10n.actionConfirmer),
            ),
          ],
        ),
      );
      if (appKey == null || appKey.isEmpty || !context.mounted) return;
      await DropboxStorageAdapter.saveAndroidAppKey(appKey);
    }

    final adapter = DropboxStorageAdapter();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.driveAuthOpening)),
    );

    try {
      await adapter.authenticate();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.driveAuthFailed(e.toString()))),
      );
      return;
    }

    if (!context.mounted) return;

    bool remoteExists = false;
    try {
      remoteExists = await adapter.remoteDbExists();
    } catch (_) {}

    if (!context.mounted) return;

    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.driveMigrateTitle),
        content: Text(
          remoteExists ? l10n.driveMigrateBodyExisting : l10n.driveMigrateBodyNew,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: Text(l10n.actionAnnuler),
          ),
          if (remoteExists) ...[
            OutlinedButton(
              onPressed: () => Navigator.of(ctx).pop('download'),
              child: Text(l10n.driveDownloadExisting),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop('upload'),
              child: Text(l10n.driveUploadOverwrite),
            ),
          ] else
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop('upload'),
              child: Text(l10n.driveSendNew),
            ),
        ],
      ),
    );

    if (choice == null) {
      await adapter.signOut();
      return;
    }

    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);

    if (choice == 'download') {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.driveDownloading), duration: const Duration(minutes: 1)),
      );
      try {
        await adapter.downloadDb(configService.config!.dbPath);
        await adapter.lock();
      } catch (e) {
        messenger.clearSnackBars();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.driveDownloadFailed(e.toString()))),
        );
        return;
      }
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.driveUploading), duration: const Duration(minutes: 1)),
      );
      try {
        await adapter.uploadDb(File(configService.config!.dbPath));
        await adapter.lock();
      } catch (e) {
        messenger.clearSnackBars();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.driveUploadFailed(e.toString()))),
        );
        return;
      }
    }

    primeNextSyncWithLock();

    final newConfig = AppConfig(
      storageMode: 'dropbox',
      dbPath: configService.config!.dbPath,
    );
    await configService.save(newConfig);

    messenger.clearSnackBars();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.driveModeActivated)),
    );

    ref.read(storageModeProvider.notifier).state = 'dropbox';
  }
}

// ── Mode 2 actif ──────────────────────────────────────────────────────────────

class _CloudActiveTile extends ConsumerStatefulWidget {
  final String storageMode;
  const _CloudActiveTile({required this.storageMode});

  @override
  ConsumerState<_CloudActiveTile> createState() => _CloudActiveTileState();
}

class _CloudActiveTileState extends ConsumerState<_CloudActiveTile> {
  bool _warningEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadWarningState();
  }

  Future<void> _loadWarningState() async {
    final seen = await configService.getAndroidWriteWarningSeen();
    if (mounted) setState(() => _warningEnabled = !seen);
  }

  String get _providerLabel =>
      widget.storageMode == 'dropbox' ? 'Dropbox' : 'Google Drive';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.cloud_done, color: Colors.green),
          title: Text(l10n.settingsModePartage),
          subtitle: Text(l10n.settingsModeSyncCurrent(_providerLabel)),
          trailing: Platform.isAndroid
              ? null
              : OutlinedButton(
                  onPressed: () => _deactivate(context),
                  child: Text(l10n.settingsRevenirLocal),
                ),
        ),
        if (!Platform.isAndroid)
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: Text(l10n.settingsChangerFournisseur),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _changeProvider(context),
          ),
        if (Platform.isAndroid)
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: Text(l10n.settingsResetWriteWarning),
            value: _warningEnabled,
            onChanged: (v) async {
              setState(() => _warningEnabled = v);
              if (v) {
                await configService.resetAndroidWriteWarningSeen();
              } else {
                await configService.setAndroidWriteWarningSeen();
              }
            },
          ),
      ],
    );
  }

  Future<void> _deactivate(BuildContext context) async {
    final l10n = context.l10n;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.driveDeactivateTitle),
        content: Text(l10n.driveDeactivateBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.actionAnnuler),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.actionConfirmer),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await activeSyncService?.releaseIfNeeded();
    } catch (_) {}

    if (widget.storageMode == 'drive') {
      await DriveStorageAdapter().signOut();
    } else {
      await DropboxStorageAdapter.clearTokens();
    }

    final newConfig = AppConfig(
      storageMode: 'local',
      dbPath: configService.config!.dbPath,
    );
    await configService.save(newConfig);

    ref.read(storageModeProvider.notifier).state = 'local';

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.driveModeDeactivated)),
    );
  }

  Future<void> _changeProvider(BuildContext context) async {
    final l10n = context.l10n;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsChangerFournisseur),
        content: Text(l10n.settingsChangerFournisseurBody(_providerLabel)),
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
    );

    if (confirm != true) return;

    try {
      await activeSyncService?.releaseIfNeeded();
    } catch (_) {}

    if (widget.storageMode == 'drive') {
      await DriveStorageAdapter().signOut();
    } else {
      await DropboxStorageAdapter.clearTokens();
    }

    final newConfig = AppConfig(
      storageMode: 'local',
      dbPath: configService.config!.dbPath,
    );
    await configService.save(newConfig);

    ref.read(storageModeProvider.notifier).state = 'local';
  }
}
