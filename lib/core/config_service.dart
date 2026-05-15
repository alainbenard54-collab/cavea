// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'dart:io';
import 'dart:ui' show Locale;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  final String storageMode; // 'local' ou 'drive'
  final String dbPath; // chemin absolu vers cave.db

  const AppConfig({required this.storageMode, required this.dbPath});
}

class ConfigService {
  static const _keyMode = 'storage_mode';
  static const _keyDbPath = 'db_path';
  static const _keyCouleurDefaut = 'couleur_defaut';
  static const _keyContenanceDefaut = 'contenance_defaut';
  static const _keyRefCouleurs = 'ref_couleurs';
  static const _keyRefContenances = 'ref_contenances';
  static const _keyRefCrus = 'ref_crus';
  static const _keyAndroidWriteWarningSeen = 'android_write_warning_seen';
  static const _keyLocalePreference = 'locale_preference';

  static const builtinCouleurs = [
    'Blanc',
    'Blanc effervescent',
    'Blanc liquoreux',
    'Blanc moelleux',
    'Rosé',
    'Rosé effervescent',
    'Rouge',
  ];

  static const _couleurLabels = <String, Map<String, String>>{
    'Blanc':              {'fr': 'Blanc',              'en': 'White'},
    'Blanc effervescent': {'fr': 'Blanc effervescent', 'en': 'Sparkling white'},
    'Blanc liquoreux':    {'fr': 'Blanc liquoreux',    'en': 'Sweet white'},
    'Blanc moelleux':     {'fr': 'Blanc moelleux',     'en': 'Semi-sweet white'},
    'Rosé':               {'fr': 'Rosé',               'en': 'Rosé'},
    'Rosé effervescent':  {'fr': 'Rosé effervescent',  'en': 'Sparkling rosé'},
    'Rouge':              {'fr': 'Rouge',               'en': 'Red'},
  };

  static String displayCouleur(String dbKey, Locale locale) {
    final labels = _couleurLabels[dbKey];
    if (labels == null) return dbKey;
    return labels[locale.languageCode] ?? labels['fr'] ?? dbKey;
  }
  static const builtinContenances = ['37,5 cl', '50 cl', '75 cl', '1,5 L (magnum)'];
  static const builtinCrus = [
    '1ER CRU',
    'CRU BOURGEOIS',
    'CRU CLASSE',
    'GRAND CRU',
    'GRAND CRU CLASSE',
    'SECOND VIN',
  ];

  AppConfig? _config;
  String? _couleurDefaut;
  String? _contenanceDefaut;
  List<String>? _refCouleurs;
  List<String>? _refContenances;
  List<String>? _refCrus;

  AppConfig? get config => _config;
  bool get isConfigured => _config != null;
  String get couleurDefaut => _couleurDefaut ?? 'Rouge';
  String get contenanceDefaut => _contenanceDefaut ?? '75 cl';
  List<String> get refCouleurs => _refCouleurs ?? builtinCouleurs;
  List<String> get refContenances => _refContenances ?? builtinContenances;
  List<String> get refCrus => _refCrus ?? builtinCrus;

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

    _couleurDefaut = prefs.getString(_keyCouleurDefaut);
    _contenanceDefaut = prefs.getString(_keyContenanceDefaut);
    _refCouleurs = prefs.getStringList(_keyRefCouleurs);
    _refContenances = prefs.getStringList(_keyRefContenances);
    _refCrus = prefs.getStringList(_keyRefCrus);
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

  Future<void> saveBulkAddDefaults({String? couleur, String? contenance}) async {
    final prefs = await SharedPreferences.getInstance();
    if (couleur != null) {
      await prefs.setString(_keyCouleurDefaut, couleur);
      _couleurDefaut = couleur;
    }
    if (contenance != null) {
      await prefs.setString(_keyContenanceDefaut, contenance);
      _contenanceDefaut = contenance;
    }
  }

  Future<void> saveRefCouleurs(List<String> values) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyRefCouleurs, values);
    _refCouleurs = values;
  }

  Future<void> saveRefContenances(List<String> values) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyRefContenances, values);
    _refContenances = values;
  }

  Future<void> saveRefCrus(List<String> values) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyRefCrus, values);
    _refCrus = values;
  }

  Future<bool> getAndroidWriteWarningSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyAndroidWriteWarningSeen) ?? false;
  }

  Future<void> setAndroidWriteWarningSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAndroidWriteWarningSeen, true);
  }

  Future<void> resetAndroidWriteWarningSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAndroidWriteWarningSeen);
  }

  Future<String?> getLocalePreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLocalePreference);
  }

  Future<void> saveLocalePreference(String? code) async {
    final prefs = await SharedPreferences.getInstance();
    if (code != null) {
      await prefs.setString(_keyLocalePreference, code);
    } else {
      await prefs.remove(_keyLocalePreference);
    }
  }
}

// Instance globale — initialisée dans main() avant runApp
final configService = ConfigService();
