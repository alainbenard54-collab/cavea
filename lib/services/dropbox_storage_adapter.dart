// SPDX-License-Identifier: Apache-2.0
// Copyright 2026 Alain Benard

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import 'storage_adapter.dart';

const _lockFileName = 'cave.db.lock';
const _dbFileName = 'cave.db';
const _remotePath = '/Cavea';

const _secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  wOptions: WindowsOptions(),
);

const _keyRefreshToken = 'dropbox_refresh_token';
const _keyDeviceId = 'dropbox_device_id';
const _keyAppKey = 'dropbox_app_key';

const _authUrl = 'https://www.dropbox.com/oauth2/authorize';
const _tokenUrl = 'https://api.dropboxapi.com/oauth2/token';
const _apiBase = 'https://api.dropboxapi.com/2';
const _contentBase = 'https://content.dropboxapi.com/2';

/// Implémentation Dropbox de [StorageAdapter].
/// Utilise un dossier "Cavea" visible dans l'interface Dropbox.
/// OAuth 2.0 PKCE S256, redirect localhost (desktop et Android).
class DropboxStorageAdapter implements StorageAdapter {
  String? _accessToken;

  // ── Authentification ────────────────────────────────────────────────────────

  /// Desktop : lit les credentials depuis [desktopSecretsPath].
  /// Android : lit le app_key depuis [_keyAppKey] dans secure storage.
  Future<void> authenticate() async {
    if (Platform.isAndroid) {
      await _authenticateAndroid();
    } else {
      final creds = await loadDesktopCredentials(desktopSecretsPath);
      await _authenticateDesktop(appKey: creds.appKey, appSecret: creds.appSecret);
    }
  }

  Future<void> _authenticateDesktop({
    required String appKey,
    required String? appSecret,
  }) async {
    final saved = await _secureStorage.read(key: _keyRefreshToken);
    if (saved != null) {
      await _refreshToken(appKey: appKey, appSecret: appSecret, refreshToken: saved);
      return;
    }
    await _runPkceFlow(appKey: appKey, appSecret: appSecret);
  }

  Future<void> _authenticateAndroid() async {
    final appKey = await _secureStorage.read(key: _keyAppKey);
    if (appKey == null) {
      throw Exception(
        'Dropbox App Key non configuré. Reconfigurez le Mode 2 dans les paramètres.',
      );
    }
    final saved = await _secureStorage.read(key: _keyRefreshToken);
    if (saved != null) {
      await _refreshToken(appKey: appKey, refreshToken: saved);
      return;
    }
    await _runPkceFlow(appKey: appKey);
  }

  /// PKCE S256 avec redirect localhost. Fonctionne sur desktop et Android.
  Future<void> _runPkceFlow({required String appKey, String? appSecret}) async {
    final codeVerifier = _generateCodeVerifier();
    final codeChallenge = _computeCodeChallenge(codeVerifier);

    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final port = server.port;
    final redirectUri = 'http://localhost:$port/callback';

    final authUri = Uri.parse(_authUrl).replace(queryParameters: {
      'client_id': appKey,
      'response_type': 'code',
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
      'token_access_type': 'offline',
      'redirect_uri': redirectUri,
    });

    await launchUrl(authUri, mode: LaunchMode.externalApplication);

    late HttpRequest request;
    try {
      request = await server.first.timeout(const Duration(minutes: 5));
    } on TimeoutException {
      await server.close();
      throw Exception('Délai d\'authentification Dropbox dépassé.');
    }

    final code = request.uri.queryParameters['code'];
    final error = request.uri.queryParameters['error'];

    final html = (error != null || code == null)
        ? '<html><body><p>Erreur : ${error ?? "code absent"}. Retournez dans Cavea.</p></body></html>'
        : '<html><body><p>Autorisation accordée ! Retournez dans Cavea.</p>'
          '<script>window.close();</script></body></html>';
    request.response
      ..headers.contentType = ContentType.html
      ..write(html);
    await request.response.close();
    await server.close();

    if (error != null) throw Exception('Dropbox auth error : $error');
    if (code == null) throw Exception('Code Dropbox absent du callback.');

    final body = <String, String>{
      'code': code,
      'grant_type': 'authorization_code',
      'client_id': appKey,
      'code_verifier': codeVerifier,
      'redirect_uri': redirectUri,
    };
    if (appSecret != null) body['client_secret'] = appSecret;

    final resp = await http.post(Uri.parse(_tokenUrl), body: body);
    if (resp.statusCode != 200) {
      throw Exception('Échange de token Dropbox échoué (${resp.statusCode}) : ${resp.body}');
    }
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    _accessToken = json['access_token'] as String;
    final rt = json['refresh_token'] as String?;
    if (rt != null) await _secureStorage.write(key: _keyRefreshToken, value: rt);
  }

  Future<void> _refreshToken({
    required String appKey,
    String? appSecret,
    required String refreshToken,
  }) async {
    final body = <String, String>{
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
      'client_id': appKey,
    };
    if (appSecret != null) body['client_secret'] = appSecret;

    final resp = await http.post(Uri.parse(_tokenUrl), body: body);
    if (resp.statusCode != 200) {
      await _secureStorage.delete(key: _keyRefreshToken);
      throw Exception('Token Dropbox expiré. Reconnectez-vous depuis les paramètres.');
    }
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    _accessToken = json['access_token'] as String;
  }

  Future<void> _ensureAuthenticated() async {
    if (_accessToken != null) return;
    await authenticate();
  }

  Future<void> signOut() async {
    await _secureStorage.delete(key: _keyRefreshToken);
    _accessToken = null;
  }

  // ── Device ID ────────────────────────────────────────────────────────────────

  Future<String> _getDeviceId() async {
    var id = await _secureStorage.read(key: _keyDeviceId);
    if (id == null) {
      id = const Uuid().v4();
      await _secureStorage.write(key: _keyDeviceId, value: id);
    }
    return id;
  }

  // ── HTTP helpers ─────────────────────────────────────────────────────────────

  /// Appel RPC Dropbox (JSON → JSON). Retourne null si le chemin n'existe pas (409).
  Future<Map<String, dynamic>?> _rpc(String endpoint, [Object? body]) async {
    await _ensureAuthenticated();
    final resp = await http.post(
      Uri.parse('$_apiBase/$endpoint'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/json',
      },
      body: body != null ? jsonEncode(body) : null,
    );
    if (resp.statusCode == 409) return null;
    if (resp.statusCode != 200) {
      throw Exception('Dropbox $endpoint erreur ${resp.statusCode}: ${resp.body}');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  Future<List<int>> _downloadBytes(String path) async {
    await _ensureAuthenticated();
    final resp = await http.post(
      Uri.parse('$_contentBase/files/download'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Dropbox-API-Arg': jsonEncode({'path': path}),
      },
    );
    if (resp.statusCode == 409) throw Exception('Fichier $path introuvable sur Dropbox.');
    if (resp.statusCode != 200) {
      throw Exception('Dropbox download erreur ${resp.statusCode}: ${resp.body}');
    }
    return resp.bodyBytes;
  }

  Future<void> _uploadBytes(String path, List<int> bytes) async {
    await _ensureAuthenticated();
    final resp = await http.post(
      Uri.parse('$_contentBase/files/upload'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
        'Content-Type': 'application/octet-stream',
        'Dropbox-API-Arg': jsonEncode({
          'path': path,
          'mode': 'overwrite',
          'autorename': false,
          'mute': true,
        }),
      },
      body: bytes,
    );
    if (resp.statusCode != 200) {
      throw Exception('Dropbox upload erreur ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<bool> _fileExists(String path) async {
    final result = await _rpc('files/get_metadata', {'path': path});
    return result != null;
  }

  // ── StorageAdapter ───────────────────────────────────────────────────────────

  @override
  Future<LockStatus> getLockStatus() async {
    try {
      final exists = await _fileExists('$_remotePath/$_lockFileName');
      if (!exists) return const LockStatus.notLocked();

      final bytes = await _downloadBytes('$_remotePath/$_lockFileName');
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
    await _uploadBytes('$_remotePath/$_lockFileName', utf8.encode(payload));
  }

  @override
  Future<void> unlock() async {
    try {
      await _rpc('files/delete_v2', {'path': '$_remotePath/$_lockFileName'});
    } catch (_) {}
  }

  @override
  Future<void> downloadDb(String localPath) async {
    final bytes = await _downloadBytes('$_remotePath/$_dbFileName');
    await File(localPath).writeAsBytes(bytes, flush: true);
  }

  @override
  Future<void> uploadDb(File localDb) async {
    await _uploadBytes('$_remotePath/$_dbFileName', await localDb.readAsBytes());
  }

  @override
  Future<bool> remoteDbExists() async => _fileExists('$_remotePath/$_dbFileName');

  /// Supprime cave.db du Dropbox (wizard : écraser une cave existante).
  Future<void> deleteDb() async {
    await _rpc('files/delete_v2', {'path': '$_remotePath/$_dbFileName'});
  }

  // ── PKCE S256 ────────────────────────────────────────────────────────────────

  static String _generateCodeVerifier() {
    final random = Random.secure();
    final bytes = List<int>.generate(96, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  static String _computeCodeChallenge(String verifier) {
    final digest = sha256.convert(utf8.encode(verifier));
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  // ── Credentials ──────────────────────────────────────────────────────────────

  static Future<({String appKey, String? appSecret})> loadDesktopCredentials(
    String secretsFilePath,
  ) async {
    final file = File(secretsFilePath);
    if (!file.existsSync()) {
      throw Exception(
        'Fichier Dropbox introuvable : $secretsFilePath\n'
        'Créez-le avec {"app_key": "...", "app_secret": "..."}',
      );
    }
    final root = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    return (
      appKey: root['app_key'] as String,
      appSecret: root['app_secret'] as String?,
    );
  }

  /// Cherche dropbox_desktop_secrets.json dans deux emplacements :
  /// 1. À côté de l'exécutable — pour les builds packagés
  /// 2. À la racine du projet — survit à flutter clean
  static String get desktopSecretsPath {
    if (kIsWeb || !Platform.isWindows) return '';
    const fileName = 'dropbox_desktop_secrets.json';
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final nextToExe = p.join(exeDir, fileName);
    if (File(nextToExe).existsSync()) return nextToExe;
    return p.join(Directory.current.path, fileName);
  }

  /// Stocke le App Key Dropbox dans secure storage (Android uniquement).
  static Future<void> saveAndroidAppKey(String appKey) async {
    await _secureStorage.write(key: _keyAppKey, value: appKey);
  }

  /// Efface tous les tokens Dropbox (déconnexion / changement de fournisseur).
  static Future<void> clearTokens() async {
    await _secureStorage.delete(key: _keyRefreshToken);
    await _secureStorage.delete(key: _keyAppKey);
  }
}
