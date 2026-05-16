// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'dart:async' show unawaited;
import 'dart:io' show Platform;

import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/config_service.dart';
import 'core/locale_provider.dart';
import 'data/database.dart';
import 'data/providers.dart';
import 'l10n/l10n.dart';
import 'services/sync_service.dart';

final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configService.load();
  runApp(const AppWrapper());
}

// AppWrapper gère le cycle de vie du ProviderScope :
// - avant setup : aucun override (database non initialisée)
// - après setup  : recreate le ProviderScope avec l'AppDatabase
// - pendant sync : close DB → download → setState → nouvelle instance AppDatabase
class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> with WidgetsBindingObserver {
  AppDatabase? _db;
  String? _pendingSnackbarMessage;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (configService.isConfigured) {
      _db = AppDatabase(configService.config!.dbPath);
      _registerSyncCallbacks();
      final mode = configService.config?.storageMode ?? 'local';
      if (mode != 'local') {
        WidgetsBinding.instance.addPostFrameCallback((_) => _runStartupSync());
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _db?.close();
    super.dispose();
  }

  // ── WidgetsBindingObserver ────────────────────────────────────────────────

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    final syncSvc = activeSyncService;
    if (syncSvc == null || !syncSvc.isWriteMode) {
      return AppExitResponse.exit;
    }
    // Déclenche SyncExiting → overlay dans AppShell + upload + unlock + quit
    unawaited(syncSvc.releaseAndExit());
    return AppExitResponse.cancel;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!Platform.isAndroid && state == AppLifecycleState.detached) {
      // Desktop : didRequestAppExit gère la fermeture propre ;
      // detached est un filet de sécurité si l'app est tuée autrement.
      activeSyncService?.releaseIfNeeded();
    }
    // Android : le verrou n'est jamais libéré sur paused/resumed car l'app peut
    // passer en background pour une sous-activité (FilePicker, partage…).
    // Le bouton "Quitter" est le seul chemin de sortie propre sur Android.
    // Si l'OS tue le process, le crash recovery au prochain démarrage gère le lock.
  }

  // ── Callbacks drift close/reopen ─────────────────────────────────────────

  void _registerSyncCallbacks() {
    registerSyncDbCallbacks(
      onClose: () async {
        await _db?.close();
      },
      onReopen: ({String? message}) async {
        _pendingSnackbarMessage = message;
        setState(() {
          _db = AppDatabase(configService.config!.dbPath);
        });
        // Attendre la reconstruction effective du ProviderScope avant de
        // rendre la main à SyncService. Sans ce await, _isDisposed reste
        // false et _startWithLock est remis à false par l'ancien SyncService
        // avant que le nouveau puisse le lire → _lockHeldByUs = false.
        await WidgetsBinding.instance.endOfFrame;
      },
    );
  }

  // ── Startup sync Mode 2 ───────────────────────────────────────────────────

  Future<void> _runStartupSync() async {
    await activeSyncService?.syncOnStartup();
  }

  // ── Wizard complete ───────────────────────────────────────────────────────

  void _onSetupComplete() {
    setState(() {
      _db = AppDatabase(configService.config!.dbPath);
    });
    _registerSyncCallbacks();
    final mode = configService.config?.storageMode ?? 'local';
    if (mode != 'local') {
      WidgetsBinding.instance.addPostFrameCallback((_) => _runStartupSync());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_pendingSnackbarMessage != null) {
      final msgKey = _pendingSnackbarMessage!;
      _pendingSnackbarMessage = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final messengerCtx = _scaffoldMessengerKey.currentContext;
        if (messengerCtx == null) return;
        final l10n = AppLocalizations.of(messengerCtx);
        final text = switch (msgKey) {
          'syncVerrouPose' => l10n.syncVerrouPose,
          'syncModificationsAbandonnees' => l10n.syncModificationsAbandonnees,
          _ => msgKey,
        };
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(text)),
        );
      });
    }
    return ProviderScope(
      // ValueKey force la recréation du ProviderScope après le wizard ou sync
      key: ValueKey(_db),
      overrides: [
        if (_db != null) appDatabaseProvider.overrideWithValue(_db!),
      ],
      child: CaveApp(onSetupComplete: _onSetupComplete),
    );
  }
}

// ConsumerStatefulWidget pour que le GoRouter soit créé une seule fois dans
// initState() — évite qu'un changement de locale (rebuild) recréé le router,
// ce qui dépilerait les dialogs ouverts (ex : onboarding mode écriture Android).
class CaveApp extends ConsumerStatefulWidget {
  final VoidCallback onSetupComplete;

  const CaveApp({super.key, required this.onSetupComplete});

  @override
  ConsumerState<CaveApp> createState() => _CaveAppState();
}

class _CaveAppState extends ConsumerState<CaveApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = buildRouter(widget.onSetupComplete);
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      title: 'Cavea',
      theme: buildTheme(),
      routerConfig: _router,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
