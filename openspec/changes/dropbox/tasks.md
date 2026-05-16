## 1. Préparation OAuth Dropbox

- [ ] 1.1 Créer une app Dropbox dans la [Dropbox App Console](https://www.dropbox.com/developers/apps) : type "Scoped access", portée "Full Dropbox" (ou App folder), activer l'option "Allow localhost" dans les redirect URIs, copier App Key et App Secret
- [ ] 1.2 Créer `dropbox_desktop_secrets.json` à côté de l'exécutable Windows avec `{"app_key": "...", "app_secret": "..."}` — ne pas committer ce fichier (déjà dans .gitignore via le pattern `*.json` hors `lib/`)
- [x] 1.3 [N/A — localhost redirect utilisé à la place de App Link pour OAuth, aucune modification AndroidManifest requise]

## 2. DropboxStorageAdapter — Authentification Desktop (PC)

- [x] 2.1 Créer `lib/services/dropbox_storage_adapter.dart` avec la classe `DropboxStorageAdapter implements StorageAdapter` — constantes : `_lockFileName`, `_dbFileName`, `_folderName = 'Cavea'`, `_secureStorage`, `_keyRefreshToken = 'dropbox_refresh_token'`, `_keyDeviceId = 'dropbox_device_id'` [PC]
- [x] 2.2 Implémenter `_authenticateDesktop()` : lire `dropbox_desktop_secrets.json` via `dart:io`, générer PKCE (code_verifier + code_challenge SHA-256), ouvrir browser via `url_launcher`, écouter `HttpServer.bind('localhost', 0)` pour le callback, échanger le code contre access_token + refresh_token via POST `https://api.dropboxapi.com/oauth2/token` [PC]
- [x] 2.3 Implémenter le refresh silencieux : si `dropbox_refresh_token` est présent dans secure storage, appeler `https://api.dropboxapi.com/oauth2/token` avec `grant_type=refresh_token` pour obtenir un access_token valide [PC]
- [ ] 2.4 Tester manuellement l'authentification desktop : lancer l'app en Mode 1, passer en Mode 2 Dropbox via Settings/wizard, vérifier que le browser s'ouvre, que le callback est capturé et que le token est stocké [PC]

## 3. DropboxStorageAdapter — Authentification Android

- [x] 3.1 Implémenter `_authenticateAndroid()` dans `DropboxStorageAdapter` : même flow PKCE localhost que desktop — redirect `http://localhost:PORT/callback`, HttpServer sur l'interface loopback accessible depuis Chrome Android [Android]
- [ ] 3.2 Tester manuellement l'authentification Android : installer l'app, passer en Mode 2 Dropbox, vérifier que le browser Dropbox s'ouvre et que l'app reprend la main après autorisation avec token stocké [Android]

## 4. DropboxStorageAdapter — API fichiers et verrou

- [x] 4.1 Implémenter `remoteDbExists()` : appel `https://api.dropboxapi.com/2/files/get_metadata` sur `/Cavea/cave.db`, retourner `true` si 200, `false` si 409 (path not found) [PC + Android]
- [x] 4.2 Implémenter `downloadDb(localPath)` : appel `https://content.dropboxapi.com/2/files/download` avec header `Dropbox-API-Arg: {"path":"/Cavea/cave.db"}`, écrire le body dans le fichier local [PC + Android]
- [x] 4.3 Implémenter `uploadDb(localDb)` : appel `https://content.dropboxapi.com/2/files/upload` avec `Dropbox-API-Arg: {"path":"/Cavea/cave.db","mode":"overwrite"}`, body = bytes du fichier [PC + Android]
- [x] 4.4 Implémenter `getLockStatus()` : appel `get_metadata` sur `/Cavea/cave.db.lock`, si absent → `LockStatus.free`, si présent → download + parse JSON → comparer `locked_by` avec `deviceId` → `LockStatus.ours` ou `LockStatus.theirs` [PC + Android]
- [x] 4.5 Implémenter `lock()` : générer ou lire `deviceId` depuis secure storage (`dropbox_device_id`), créer le JSON `{locked_by, locked_at}`, uploader vers `/Cavea/cave.db.lock` via `/files/upload` [PC + Android]
- [x] 4.6 Implémenter `unlock()` : appel `https://api.dropboxapi.com/2/files/delete_v2` sur `/Cavea/cave.db.lock` [PC + Android]
- [x] 4.7 Implémenter la méthode `authenticate()` publique qui route vers `_authenticateDesktop()` ou `_authenticateAndroid()` selon `Platform.isAndroid` [PC + Android]

## 5. Intégration SyncService et ConfigService

- [x] 5.1 Étendre `syncServiceProvider` dans `lib/services/sync_service.dart` : ajouter `mode == 'dropbox'` → `SyncService(DropboxStorageAdapter())`, et importer `dropbox_storage_adapter.dart` [PC + Android]
- [x] 5.2 Mettre à jour le commentaire `AppConfig.storageMode` dans `lib/core/config_service.dart` : documenter les valeurs valides `'local'`, `'drive'`, `'dropbox'` [PC + Android]

## 6. UI — Wizard de premier lancement

- [x] 6.1 Dans le wizard Mode 2, ajouter une étape "Choix du fournisseur" avant l'étape d'authentification : deux options "Google Drive" et "Dropbox", state local `_selectedProvider` [PC + Android]
- [x] 6.2 Conditionner l'étape d'authentification du wizard : si `_selectedProvider == 'drive'` → bouton "Se connecter avec Google" (comportement existant) ; si `'dropbox'` → bouton "Se connecter avec Dropbox" qui appelle `DropboxStorageAdapter().authenticate()` [PC + Android]
- [x] 6.3 À la confirmation du wizard Dropbox : persister `storageMode = 'dropbox'` via `configService.save()`, appeler `syncOnStartup()` [PC + Android]

## 7. UI — Settings (sélection / changement de fournisseur)

- [x] 7.1 Dans `lib/features/settings/settings_screen.dart`, section "Mode de synchronisation" : afficher le fournisseur actif (`'drive'` → "Google Drive", `'dropbox'` → "Dropbox") quand Mode 2 est actif [PC + Android]
- [x] 7.2 Ajouter un bouton "Changer de fournisseur" dans la section Mode 2 de Settings : efface les tokens du fournisseur courant (`flutter_secure_storage` : supprimer `dropbox_refresh_token` ou `drive_refresh_token` selon le mode), remet `storageMode = 'local'`, redirige vers le wizard [PC + Android]

## 8. Tests manuels

- [ ] 8.1 Test PC : premier lancement Dropbox — choisir Dropbox dans wizard, s'authentifier, vérifier que `cave.db` et `cave.db.lock` apparaissent dans le dossier `/Cavea/` sur Dropbox
- [ ] 8.2 Test PC : second lancement — token en cache, démarrage silencieux, lock repris, SyncIdle
- [ ] 8.3 Test PC : lock tiers — créer manuellement un `cave.db.lock` avec un autre `deviceId`, vérifier que l'app passe en SyncReadOnly
- [ ] 8.4 Test PC : upload/download — modifier des données, cliquer "Synchroniser", vérifier que `cave.db` sur Dropbox est mis à jour
- [ ] 8.5 Test Android : premier lancement Dropbox — vérifier que le browser s'ouvre, que l'app reprend la main et que la sync fonctionne
- [ ] 8.6 Test changement de fournisseur : Drive → Dropbox depuis Settings, vérifier que les tokens Drive sont effacés et que le wizard Dropbox s'affiche
