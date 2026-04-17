// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  final String storageMode; // 'local'
  final String dbPath; // chemin absolu vers cave.db

  const AppConfig({required this.storageMode, required this.dbPath});
}

class ConfigService {
  static const _keyMode = 'storage_mode';
  static const _keyDbPath = 'db_path';

  AppConfig? _config;

  AppConfig? get config => _config;
  bool get isConfigured => _config != null;

  Future<void> load() async {
    // 1. .env à côté de l'exe (Windows desktop uniquement)
    if (!kIsWeb && Platform.isWindows) {
      await _tryLoadFromEnv();
      if (_config != null) return;
    }

    // 2. SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_keyMode);
    final dbPath = prefs.getString(_keyDbPath);
    if (mode != null && dbPath != null && dbPath.isNotEmpty) {
      _config = AppConfig(storageMode: mode, dbPath: dbPath);
    }
  }

  // Lecture directe du fichier .env depuis le dossier de l'exécutable.
  // flutter_dotenv n'est pas utilisé car il charge depuis les assets Flutter
  // (bundlés dans l'app) — pas depuis le système de fichiers.
  Future<void> _tryLoadFromEnv() async {
    try {
      final exeDir = File(Platform.resolvedExecutable).parent.path;
      final envFile = File(p.join(exeDir, '.env'));
      if (!envFile.existsSync()) return;

      final env = _parseEnvFile(await envFile.readAsLines());
      final mode = env['STORAGE_MODE'];
      final dir = env['LOCAL_DB_PATH'];
      if (mode != null && dir != null && dir.isNotEmpty) {
        _config = AppConfig(storageMode: mode, dbPath: p.join(dir, 'cave.db'));
        await save(_config!);
      }
    } catch (_) {
      // .env absent ou invalide : silencieux, on continue
    }
  }

  Map<String, String> _parseEnvFile(List<String> lines) {
    final env = <String, String>{};
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final idx = trimmed.indexOf('=');
      if (idx < 0) continue;
      env[trimmed.substring(0, idx).trim()] =
          trimmed.substring(idx + 1).trim();
    }
    return env;
  }

  Future<void> save(AppConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMode, config.storageMode);
    await prefs.setString(_keyDbPath, config.dbPath);
    _config = config;
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyMode);
    await prefs.remove(_keyDbPath);
    _config = null;
  }
}

// Instance globale — initialisée dans main() avant runApp
final configService = ConfigService();
