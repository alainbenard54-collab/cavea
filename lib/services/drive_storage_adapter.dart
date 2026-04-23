// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import 'storage_adapter.dart';

const _driveScope = drive.DriveApi.driveAppdataScope;
const _lockFileName = 'cave.db.lock';
const _dbFileName = 'cave.db';

const _secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  wOptions: WindowsOptions(),
);

const _keyRefreshToken = 'drive_refresh_token';
const _keyDeviceId = 'drive_device_id';

/// Implémentation Google Drive de [StorageAdapter].
/// Utilise appDataFolder (espace privé de l'app, invisible dans Drive UI).
class DriveStorageAdapter implements StorageAdapter {
  drive.DriveApi? _driveApi;
  http.Client? _authClient;

  // ── Authentification ────────────────────────────────────────────────────────

  /// Authentifie via le flux approprié à la plateforme.
  /// Persiste le refresh_token (Desktop) ou délègue à google_sign_in (Android).
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
      // Restaurer depuis le refresh token persisté
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
      // Flux OAuth complet : ouvre le navigateur, serveur localhost géré par googleapis_auth
      authClient = await clientViaUserConsent(
        ClientId(clientId, clientSecret),
        [_driveScope],
        (url) async {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        },
      );
      // Persister le refresh token
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

    // Essayer sign-in silencieux d'abord
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
      null, // Google Sign-In gère le refresh via signInSilently
      [_driveScope],
    );
    _authClient = authenticatedClient(http.Client(), credentials);
    _driveApi = drive.DriveApi(_authClient!);
  }

  Future<void> _ensureAuthenticated() async {
    if (_driveApi != null) return;
    // Tenter de restaurer depuis token persisté (Desktop)
    if (!Platform.isAndroid) {
      final savedToken = await _secureStorage.read(key: _keyRefreshToken);
      if (savedToken == null) throw Exception('Non authentifié. Configurez le Mode 2 dans les paramètres.');
      // Les credentials seront chargés à la prochaine authenticate() ; ici on échoue proprement
      throw Exception('Session expirée. Veuillez vous reconnecter dans les paramètres.');
    }
    // Android : tenter sign-in silencieux
    await _authenticateAndroid();
  }

  /// Révoque les tokens et efface les données persistées.
  Future<void> signOut() async {
    await _secureStorage.delete(key: _keyRefreshToken);
    if (Platform.isAndroid) {
      await GoogleSignIn(scopes: [_driveScope]).signOut();
    }
    _authClient?.close();
    _authClient = null;
    _driveApi = null;
  }

  // ── Device ID ───────────────────────────────────────────────────────────────

  Future<String> _getDeviceId() async {
    var id = await _secureStorage.read(key: _keyDeviceId);
    if (id == null) {
      id = const Uuid().v4();
      await _secureStorage.write(key: _keyDeviceId, value: id);
    }
    return id;
  }

  // ── Helpers Drive ───────────────────────────────────────────────────────────

  Future<String?> _findFileId(String name) async {
    await _ensureAuthenticated();
    final result = await _driveApi!.files.list(
      spaces: 'appDataFolder',
      q: "name='$name' and trashed=false",
      $fields: 'files(id)',
    );
    return result.files?.firstOrNull?.id;
  }

  Future<void> _uploadBytes(String name, List<int> bytes) async {
    await _ensureAuthenticated();
    final media = drive.Media(Stream.value(bytes), bytes.length);
    final existingId = await _findFileId(name);

    if (existingId != null) {
      await _driveApi!.files.update(drive.File(), existingId, uploadMedia: media);
    } else {
      final file = drive.File()
        ..name = name
        ..parents = ['appDataFolder'];
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

      // Ignorer les locks > 24h (stale lock)
      if (DateTime.now().toUtc().difference(lockedAt.toUtc()).inHours >= 24) {
        return const LockStatus.notLocked();
      }

      final lockedBy = json['locked_by'] as String?;
      final myId = await _getDeviceId();
      if (lockedBy == myId) return const LockStatus.lockedByUs();
      return LockStatus.lockedByOther(lockedBy ?? 'inconnu');
    } catch (_) {
      // Fichier absent ou illisible → pas verrouillé
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

  // ── Chargement des credentials Desktop ──────────────────────────────────────

  /// Lit client_id et client_secret depuis [secretsFilePath].
  /// Accepte les deux formats :
  ///   - Téléchargé depuis GCP : {"installed": {"client_id": "...", "client_secret": "..."}}
  ///   - Format simplifié :       {"client_id": "...", "client_secret": "..."}
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
    // Le fichier téléchargé depuis GCP a une clé "installed" (application de bureau)
    final json = (root['installed'] ?? root) as Map<String, dynamic>;
    return (
      clientId: json['client_id'] as String,
      clientSecret: json['client_secret'] as String,
    );
  }

  /// Chemin attendu du fichier de credentials Desktop (à côté de l'exe).
  static String get desktopSecretsPath {
    if (kIsWeb || !Platform.isWindows) return '';
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    return p.join(exeDir, 'google_desktop_secrets.json');
  }
}
