## Why

Google Drive est le seul backend cloud disponible en Mode 2 (partage de cave.db entre appareils). Dropbox est une alternative populaire qui couvre les mêmes cas d'usage avec un modèle d'API similaire. Ajouter Dropbox permet aux utilisateurs qui ne possèdent pas de projet GCP ou qui préfèrent Dropbox de bénéficier du Mode 2 sans changer d'outil de stockage.

## What Changes

- Nouvel adaptateur `DropboxStorageAdapter` implémentant `StorageAdapter` via l'API HTTP v2 de Dropbox (pas de SDK supplémentaire — `http` est déjà une dépendance)
- Authentification OAuth 2.0 avec PKCE : flow desktop (redirect localhost) et flow Android (browser externe + deep-link)
- Stockage identique à Drive : `cave.db` + `cave.db.lock` dans le dossier `/Cavea/` sur Dropbox
- Format de verrou identique à Drive : fichier JSON `{locked_by, locked_at}`
- `storageMode` enrichi d'une valeur `'dropbox'` (aux côtés de `'local'` et `'drive'`)
- `syncServiceProvider` étendu pour instancier `DropboxStorageAdapter` quand `storageMode == 'dropbox'`
- UI de sélection du fournisseur dans l'assistant de configuration (Setup Wizard) et dans l'écran Paramètres
- Les tokens OAuth Dropbox sont stockés dans `flutter_secure_storage` (déjà utilisé pour Drive)

## Capabilities

### New Capabilities

- `dropbox-storage-adapter` : implémentation de `StorageAdapter` pour Dropbox — OAuth PKCE desktop + Android, API v2 Dropbox (upload, download, metadata), gestion du verrou JSON identique à Drive
- `storage-provider-selection` : UI de sélection du fournisseur cloud (Google Drive vs Dropbox) dans le Setup Wizard et dans Settings — un seul fournisseur actif à la fois, possibilité de changer de fournisseur en passant par Settings (reset token + re-auth)

### Modified Capabilities

- `app-config` : ajout de la valeur `'dropbox'` à `storageMode`, persistence du choix de fournisseur (SharedPreferences), logique de factory dans `syncServiceProvider`

## Impact

- Nouveaux fichiers : `lib/services/dropbox_storage_adapter.dart`
- Modifiés : `lib/services/sync_service.dart` (provider factory), `lib/core/config_service.dart` (storageMode), `lib/features/settings/settings_screen.dart` (provider selection), Setup Wizard
- Dépendances ajoutées : aucune — `http`, `flutter_secure_storage`, `url_launcher`, `shared_preferences` sont déjà présents

## Non-goals

- Support simultané de plusieurs fournisseurs cloud (un seul actif à la fois)
- Migration automatique des données d'un fournisseur à l'autre
- SDK officiel Dropbox Flutter (l'API HTTP v2 suffit, évite une dépendance lourde)
- Partage du même dossier Dropbox entre Drive et Dropbox (ils sont indépendants)
