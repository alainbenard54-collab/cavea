## ADDED Requirements

### Requirement: Authentification Dropbox — Desktop (Windows)
`DropboxStorageAdapter` SHALL authentifier l'utilisateur sur Windows via OAuth 2.0 PKCE. L'app SHALL ouvrir le browser avec l'URL d'autorisation Dropbox (App Key + code_challenge), écouter sur un `HttpServer` localhost pour capturer le code, l'échanger contre un access_token + refresh_token, et stocker le refresh_token dans `flutter_secure_storage` sous la clé `dropbox_refresh_token`. Les credentials desktop (App Key, App Secret) SHALL être lus depuis `dropbox_desktop_secrets.json` à côté de l'exécutable.

#### Scenario: Premier lancement desktop — pas de token stocké
- **WHEN** `authenticate()` est appelé sur Windows et qu'aucun refresh_token n'est stocké
- **THEN** l'app ouvre le browser sur l'URL d'autorisation Dropbox, attend le callback localhost, échange le code contre des tokens, stocke le refresh_token, et résout le Future

#### Scenario: Relance desktop — token existant
- **WHEN** `authenticate()` est appelé sur Windows et qu'un refresh_token est présent dans secure storage
- **THEN** l'app utilise le refresh_token pour obtenir un access_token sans ouvrir le browser

#### Scenario: Fichier secrets absent — Desktop
- **WHEN** `authenticate()` est appelé sur Windows et que `dropbox_desktop_secrets.json` est absent
- **THEN** une exception descriptive est levée

---

### Requirement: Authentification Dropbox — Android
`DropboxStorageAdapter` SHALL authentifier l'utilisateur sur Android via OAuth 2.0 PKCE avec redirect App Link (`cavea://oauth/callback`). L'App Key Dropbox SHALL être hardcodée (pas d'App Secret requis pour PKCE). Le refresh_token SHALL être stocké dans `flutter_secure_storage` sous `dropbox_refresh_token`.

#### Scenario: Premier lancement Android — pas de token stocké
- **WHEN** `authenticate()` est appelé sur Android et qu'aucun refresh_token n'est stocké
- **THEN** l'app ouvre le browser via `url_launcher` sur l'URL d'autorisation Dropbox, l'app intercepte le callback via l'App Link `cavea://oauth/callback`, échange le code contre des tokens, stocke le refresh_token

#### Scenario: Relance Android — token existant
- **WHEN** `authenticate()` est appelé sur Android et qu'un refresh_token est présent
- **THEN** l'app rafraîchit le token silencieusement sans ouvrir le browser

---

### Requirement: Vérification d'existence de la base distante
`DropboxStorageAdapter.remoteDbExists()` SHALL retourner `true` si `/Cavea/cave.db` existe sur Dropbox, `false` sinon.

#### Scenario: cave.db présent sur Dropbox
- **WHEN** `remoteDbExists()` est appelé et que `/Cavea/cave.db` existe sur Dropbox
- **THEN** la méthode retourne `true`

#### Scenario: cave.db absent de Dropbox
- **WHEN** `remoteDbExists()` est appelé et que `/Cavea/cave.db` n'existe pas sur Dropbox
- **THEN** la méthode retourne `false`

---

### Requirement: Téléchargement de la base depuis Dropbox
`DropboxStorageAdapter.downloadDb(localPath)` SHALL télécharger `/Cavea/cave.db` depuis Dropbox et l'écrire sur le chemin local fourni.

#### Scenario: Téléchargement réussi
- **WHEN** `downloadDb(localPath)` est appelé et que `/Cavea/cave.db` existe sur Dropbox
- **THEN** le fichier est écrit à `localPath` et le Future résout sans erreur

#### Scenario: Fichier distant absent
- **WHEN** `downloadDb(localPath)` est appelé et que `/Cavea/cave.db` n'existe pas
- **THEN** une exception est levée

---

### Requirement: Upload de la base vers Dropbox
`DropboxStorageAdapter.uploadDb(localDb)` SHALL uploader le fichier local vers `/Cavea/cave.db` sur Dropbox (écrasement si présent).

#### Scenario: Upload réussi
- **WHEN** `uploadDb(localDb)` est appelé avec un fichier local valide
- **THEN** `/Cavea/cave.db` sur Dropbox est créé ou remplacé par le contenu du fichier local

---

### Requirement: Gestion du verrou Dropbox
`DropboxStorageAdapter` SHALL implémenter `getLockStatus()`, `lock()`, et `unlock()` via un fichier JSON `/Cavea/cave.db.lock` sur Dropbox. Le format du fichier est `{"locked_by": "<deviceId>", "locked_at": "<ISO8601>"}`. Le `deviceId` SHALL être généré à la première utilisation (UUID v4) et stocké dans `flutter_secure_storage` sous `dropbox_device_id`.

#### Scenario: getLockStatus — pas de lock
- **WHEN** `getLockStatus()` est appelé et que `/Cavea/cave.db.lock` n'existe pas sur Dropbox
- **THEN** retourne `LockStatus.free`

#### Scenario: getLockStatus — lock à nous
- **WHEN** `getLockStatus()` est appelé et que le fichier lock existe avec notre `deviceId`
- **THEN** retourne `LockStatus.ours`

#### Scenario: getLockStatus — lock tiers
- **WHEN** `getLockStatus()` est appelé et que le fichier lock existe avec un `deviceId` différent
- **THEN** retourne `LockStatus.theirs`

#### Scenario: Pose du verrou
- **WHEN** `lock()` est appelé
- **THEN** le fichier `/Cavea/cave.db.lock` est créé sur Dropbox avec notre `deviceId` et l'horodatage courant

#### Scenario: Libération du verrou
- **WHEN** `unlock()` est appelé
- **THEN** le fichier `/Cavea/cave.db.lock` est supprimé de Dropbox
