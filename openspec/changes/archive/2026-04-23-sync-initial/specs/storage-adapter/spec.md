## ADDED Requirements

### Requirement: Interface StorageAdapter
L'application SHALL définir une interface abstraite `StorageAdapter` (`lib/services/storage_adapter.dart`) exposant exactement cinq opérations : `isLocked()`, `lock()`, `unlock()`, `downloadDb(String localPath)`, `uploadDb(File localDb)`. `SyncService` SHALL dépendre uniquement de cette interface — jamais d'une implémentation concrète.

#### Scenario: Injection de l'implémentation
- **WHEN** l'application est en Mode 2
- **THEN** le provider Riverpod `storageAdapterProvider` retourne une instance de `DriveStorageAdapter`

#### Scenario: Extension future (Dropbox V1)
- **WHEN** un développeur implémente `DropboxStorageAdapter extends StorageAdapter`
- **THEN** `SyncService` fonctionne sans modification

---

### Requirement: DriveStorageAdapter — authentification OAuth
`DriveStorageAdapter` SHALL authentifier l'utilisateur via Google OAuth avant toute opération Drive. Le `refresh_token` SHALL être persisté dans `flutter_secure_storage`. La connexion SHALL être transparente pour `SyncService` (le token est rafraîchi automatiquement si expiré).

#### Scenario: Premier lancement Mode 2 sur Desktop
- **WHEN** l'utilisateur active le Mode 2 et qu'aucun token n'est persisté (Desktop)
- **THEN** `DriveStorageAdapter` ouvre le navigateur système via `url_launcher` avec l'URL d'autorisation Google, démarre un serveur HTTP local sur `localhost:8080` pour recevoir le code OAuth, puis échange le code contre un `access_token` + `refresh_token` persisté dans `flutter_secure_storage`

#### Scenario: Premier lancement Mode 2 sur Android
- **WHEN** l'utilisateur active le Mode 2 et qu'aucun token n'est persisté (Android)
- **THEN** `DriveStorageAdapter` utilise `google_sign_in` pour le flux OAuth natif, puis persiste le token dans `flutter_secure_storage`

#### Scenario: Token expiré
- **WHEN** `DriveStorageAdapter` doit effectuer une opération et que l'`access_token` est expiré
- **THEN** `DriveStorageAdapter` rafraîchit le token via `googleapis_auth` sans intervention utilisateur et retente l'opération

---

### Requirement: DriveStorageAdapter — stockage dans appDataFolder
`DriveStorageAdapter` SHALL stocker `cave.db` et le fichier sentinelle de lock dans le dossier `appDataFolder` de l'application Google Drive (espace privé, non visible dans l'UI Drive de l'utilisateur). Les deux apps Desktop et Android SHALL partager le même `appDataFolder` via le même projet GCP (même `client_id` de projet, deux `client_id` de plateforme).

#### Scenario: Upload initial
- **WHEN** l'utilisateur active le Mode 2 pour la première fois et confirme la migration
- **THEN** `DriveStorageAdapter.uploadDb()` crée ou remplace `cave.db` dans `appDataFolder` avec le fichier local existant

#### Scenario: Download
- **WHEN** `SyncService` appelle `downloadDb(localPath)`
- **THEN** `DriveStorageAdapter` télécharge `cave.db` depuis `appDataFolder` et l'écrit à `localPath`, en remplaçant le fichier local si présent

---

### Requirement: DriveStorageAdapter — mécanisme de lock
`DriveStorageAdapter` SHALL implémenter le lock via un fichier sentinelle `cave.db.lock` dans `appDataFolder`. Ce fichier JSON SHALL contenir `{"locked_by": "<device_id>", "locked_at": "<iso8601>"}`. Un lock de plus de 24 heures SHALL être considéré comme périmé et ignoré.

#### Scenario: Acquisition du lock
- **WHEN** `DriveStorageAdapter.lock()` est appelé et qu'aucun lock valide n'existe
- **THEN** `DriveStorageAdapter` crée `cave.db.lock` dans `appDataFolder` avec l'identifiant de l'appareil courant et l'horodatage actuel

#### Scenario: Lock déjà détenu par un autre appareil
- **WHEN** `DriveStorageAdapter.isLocked()` est appelé et qu'un fichier `cave.db.lock` valide (< 24h) appartenant à un autre appareil existe
- **THEN** `isLocked()` retourne `true` et `SyncService` passe en état `locked(by: <device_id>)`

#### Scenario: Lock périmé
- **WHEN** `DriveStorageAdapter.isLocked()` est appelé et que `cave.db.lock` existe mais a plus de 24 heures
- **THEN** `isLocked()` retourne `false` (le lock périmé est ignoré)

#### Scenario: Libération du lock
- **WHEN** `DriveStorageAdapter.unlock()` est appelé
- **THEN** le fichier `cave.db.lock` est supprimé de `appDataFolder`
