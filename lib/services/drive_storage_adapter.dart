// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import 'storage_adapter.dart';

const _driveScope = drive.DriveApi.driveFileScope;
const _lockFileName = 'cave.db.lock';
const _dbFileName = 'cave.db';
const _folderName = 'Cavea';

const _secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  wOptions: WindowsOptions(),
);

const _keyRefreshToken = 'drive_refresh_token';
const _keyDeviceId = 'drive_device_id';

/// Implémentation Google Drive de [StorageAdapter].
/// Utilise un dossier "Cavea" visible dans l'interface Google Drive.
class DriveStorageAdapter implements StorageAdapter {
  drive.DriveApi? _driveApi;
  http.Client? _authClient;
  String? _folderId;

  // ── Authentification ────────────────────────────────────────────────────────

  Future<void> authenticate({String? desktopClientId, String? desktopClientSecret}) async {
    if (Platform.isAndroid) {
      await _authenticateAndroid();
    } else {
      await _authenticateDesktop(
        clientId: desktopClientId!,
        clientSecret: desktopClientSecret!,
      );
    }
  }

  Future<void> _authenticateDesktop({
    required String clientId,
    required String clientSecret,
  }) async {
    final savedToken = await _secureStorage.read(key: _keyRefreshToken);

    AutoRefreshingAuthClient authClient;

    if (savedToken != null) {
      final credentials = AccessCredentials(
        AccessToken('Bearer', '', DateTime.now().toUtc().subtract(const Duration(seconds: 1))),
        savedToken,
        [_driveScope],
      );
      authClient = autoRefreshingClient(
        ClientId(clientId, clientSecret),
        credentials,
        http.Client(),
      );
    } else {
      authClient = await clientViaUserConsent(
        ClientId(clientId, clientSecret),
        [_driveScope],
        (url) async {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        },
      );
      if (authClient.credentials.refreshToken != null) {
        await _secureStorage.write(
          key: _keyRefreshToken,
          value: authClient.credentials.refreshToken!,
        );
      }
    }

    _authClient = authClient;
    _driveApi = drive.DriveApi(authClient);
  }

  Future<void> _authenticateAndroid() async {
    final googleSignIn = GoogleSignIn(scopes: [_driveScope]);

    var account = await googleSignIn.signInSilently();
    account ??= await googleSignIn.signIn();

    if (account == null) throw Exception('Authentification Google annulée.');

    final auth = await account.authentication;
    final credentials = AccessCredentials(
      AccessToken(
        'Bearer',
        auth.accessToken!,
        DateTime.now().toUtc().add(const Duration(hours: 1)),
      ),
      null,
      [_driveScope],
    );
    _authClient = authenticatedClient(http.Client(), credentials);
    _driveApi = drive.DriveApi(_authClient!);
  }

  Future<void> _ensureAuthenticated() async {
    if (_driveApi != null) return;
    if (!Platform.isAndroid) {
      final savedToken = await _secureStorage.read(key: _keyRefreshToken);
      if (savedToken == null) {
        throw Exception('Non authentifié. Configurez le Mode 2 dans les paramètres.');
      }
      final creds = await loadDesktopCredentials(desktopSecretsPath);
      await _authenticateDesktop(clientId: creds.clientId, clientSecret: creds.clientSecret);
      return;
    }
    await _authenticateAndroid();
  }

  Future<void> signOut() async {
    await _secureStorage.delete(key: _keyRefreshToken);
    if (Platform.isAndroid) {
      await GoogleSignIn(scopes: [_driveScope]).signOut();
    }
    _authClient?.close();
    _authClient = null;
    _driveApi = null;
    _folderId = null;
  }

  // ── Device ID ───────────────────────────────────────────────────────────────

  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_keyDeviceId);
    if (id == null) {
      id = const Uuid().v4();
      await prefs.setString(_keyDeviceId, id);
    }
    return id;
  }

  // ── Dossier Cavea ────────────────────────────────────────────────────────────

  /// Trouve ou crée le dossier "Cavea" à la racine du Drive.
  /// Met en cache l'ID pour éviter des appels répétés.
  Future<String> _ensureFolder() async {
    if (_folderId != null) return _folderId!;
    await _ensureAuthenticated();

    final result = await _driveApi!.files.list(
      spaces: 'drive',
      q: "name='$_folderName' and mimeType='application/vnd.google-apps.folder' and trashed=false",
      $fields: 'files(id)',
    );

    if (result.files?.isNotEmpty == true) {
      _folderId = result.files!.first.id!;
      return _folderId!;
    }

    final folder = drive.File()
      ..name = _folderName
      ..mimeType = 'application/vnd.google-apps.folder';
    final created = await _driveApi!.files.create(folder, $fields: 'id');
    _folderId = created.id!;
    return _folderId!;
  }

  // ── Helpers Drive ───────────────────────────────────────────────────────────

  Future<String?> _findFileId(String name) async {
    await _ensureAuthenticated();
    final folderId = await _ensureFolder();
    final result = await _driveApi!.files.list(
      spaces: 'drive',
      q: "name='$name' and '$folderId' in parents and trashed=false",
      $fields: 'files(id)',
    );
    return result.files?.firstOrNull?.id;
  }

  Future<void> _uploadBytes(String name, List<int> bytes) async {
    await _ensureAuthenticated();
    final folderId = await _ensureFolder();
    final media = drive.Media(Stream.value(bytes), bytes.length);
    final existingId = await _findFileId(name);

    if (existingId != null) {
      await _driveApi!.files.update(drive.File(), existingId, uploadMedia: media);
    } else {
      final file = drive.File()
        ..name = name
        ..parents = [folderId];
      await _driveApi!.files.create(file, uploadMedia: media);
    }
  }

  Future<List<int>> _downloadBytes(String name) async {
    await _ensureAuthenticated();
    final fileId = await _findFileId(name);
    if (fileId == null) throw Exception('Fichier $name introuvable dans Drive.');

    final response = await _driveApi!.files.get(
      fileId,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final chunks = <int>[];
    await for (final chunk in response.stream) {
      chunks.addAll(chunk);
    }
    return chunks;
  }

  Future<void> _deleteFile(String name) async {
    await _ensureAuthenticated();
    final fileId = await _findFileId(name);
    if (fileId != null) {
      await _driveApi!.files.delete(fileId);
    }
  }

  // ── StorageAdapter ──────────────────────────────────────────────────────────

  @override
  Future<LockStatus> getLockStatus() async {
    try {
      final bytes = await _downloadBytes(_lockFileName);
      final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      final lockedAt = DateTime.tryParse(json['locked_at'] as String? ?? '');
      if (lockedAt == null) return const LockStatus.notLocked();

      if (DateTime.now().toUtc().difference(lockedAt.toUtc()).inHours >= 24) {
        return const LockStatus.notLocked();
      }

      final lockedBy = json['locked_by'] as String?;
      final myId = await _getDeviceId();
      if (lockedBy == myId) return const LockStatus.lockedByUs();
      return LockStatus.lockedByOther(lockedBy ?? 'inconnu');
    } catch (_) {
      return const LockStatus.notLocked();
    }
  }

  @override
  Future<void> lock() async {
    final deviceId = await _getDeviceId();
    final payload = jsonEncode({
      'locked_by': deviceId,
      'locked_at': DateTime.now().toUtc().toIso8601String(),
    });
    await _uploadBytes(_lockFileName, utf8.encode(payload));
  }

  @override
  Future<void> unlock() async {
    await _deleteFile(_lockFileName);
  }

  @override
  Future<void> downloadDb(String localPath) async {
    final bytes = await _downloadBytes(_dbFileName);
    await File(localPath).writeAsBytes(bytes, flush: true);
  }

  @override
  Future<void> uploadDb(File localDb) async {
    final bytes = await localDb.readAsBytes();
    await _uploadBytes(_dbFileName, bytes);
  }

  @override
  Future<bool> remoteDbExists() async {
    final fileId = await _findFileId(_dbFileName);
    return fileId != null;
  }

  /// Supprime cave.db du Drive (utilisé par le wizard pour écraser une cave existante).
  Future<void> deleteDb() async {
    await _deleteFile(_dbFileName);
  }

  // ── Chargement des credentials Desktop ──────────────────────────────────────

  static Future<({String clientId, String clientSecret})> loadDesktopCredentials(
    String secretsFilePath,
  ) async {
    final file = File(secretsFilePath);
    if (!file.existsSync()) {
      throw Exception(
        'Fichier de credentials introuvable : $secretsFilePath\n'
        'Créez-le depuis le template google_desktop_secrets.json.template',
      );
    }
    final root = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final json = (root['installed'] ?? root) as Map<String, dynamic>;
    return (
      clientId: json['client_id'] as String,
      clientSecret: json['client_secret'] as String,
    );
  }

  /// Cherche google_desktop_secrets.json dans deux emplacements, par ordre de priorité :
  /// 1. À côté de l'exécutable (build/windows/.../Debug|Release/) — pour les builds packagés
  /// 2. À la racine du projet (répertoire de travail) — survit à flutter clean
  static String get desktopSecretsPath {
    if (kIsWeb || !Platform.isWindows) return '';
    const fileName = 'google_desktop_secrets.json';
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final nextToExe = p.join(exeDir, fileName);
    if (File(nextToExe).existsSync()) return nextToExe;
    // Fallback : répertoire de travail courant (racine projet en dev)
    final cwd = p.join(Directory.current.path, fileName);
    return cwd;
  }
}
