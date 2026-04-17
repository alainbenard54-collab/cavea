// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/config_service.dart';
import 'data/database.dart';
import 'data/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configService.load();
  runApp(const AppWrapper());
}

// AppWrapper gère le cycle de vie du ProviderScope :
// - avant setup : aucun override (database non initialisée)
// - après setup  : recreate le ProviderScope avec l'AppDatabase
class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  AppDatabase? _db;

  @override
  void initState() {
    super.initState();
    if (configService.isConfigured) {
      _db = AppDatabase(configService.config!.dbPath);
    }
  }

  void _onSetupComplete() {
    setState(() {
      _db = AppDatabase(configService.config!.dbPath);
    });
  }

  @override
  void dispose() {
    _db?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      // La ValueKey force la recréation du ProviderScope après le wizard
      key: ValueKey(_db != null),
      overrides: [
        if (_db != null) appDatabaseProvider.overrideWithValue(_db!),
      ],
      child: CaveApp(onSetupComplete: _onSetupComplete),
    );
  }
}

class CaveApp extends StatelessWidget {
  final VoidCallback onSetupComplete;

  const CaveApp({super.key, required this.onSetupComplete});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Cavea',
      theme: buildTheme(),
      routerConfig: buildRouter(onSetupComplete),
    );
  }
}
