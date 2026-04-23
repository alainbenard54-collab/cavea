## Why

Les étapes 1–5 du MVP (import, stock, maturité, actions bouteille, ajout en lot) sont complètes en Mode 1 (PC seul, `dart:io` direct). L'étape 7 MVP introduit le **Mode 2** : partage de `cave.db` entre le PC Windows et un Android via Google Drive, avec sync manuelle, pour que l'utilisateur puisse gérer sa cave depuis les deux appareils.

## What Changes

- Définition de l'interface `StorageAdapter` (contrat entre SyncService et tout backend cloud)
- Implémentation `DriveStorageAdapter` : OAuth Google Drive + upload/download `cave.db` + verrouillage via fichier sentinelle
- `SyncService` : protocole lock → download → merge/work → upload → unlock, exposé comme service Riverpod
- UI sync : indicateur d'état dans la NavigationRail/BottomNavigationBar + bouton "Synchroniser" + dialogue de conflit éventuel
- Activation du Mode 2 dans les Settings (remplace le placeholder "Non disponible") : sélection Google Drive, déclenchement OAuth, migration one-shot du `cave.db` local vers Drive
- Transition Mode 1 → Mode 2 : upload initial du `cave.db` existant, puis toutes les opérations passent par SyncService

**Non-goals (hors périmètre de ce changement) :**
- Dropbox (StorageAdapter prévu mais implémentation Dropbox = V1)
- Sync automatique en arrière-plan
- Résolution de conflits intelligente (stratégie : "last-write-wins" sur le fichier entier — un seul rédacteur actif à la fois grâce au lock)
- Mode 3 (mobile seul)
- iOS

## Capabilities

### New Capabilities

- `storage-adapter`: Interface abstraite `StorageAdapter` (lock, unlock, download, upload, isLocked) et implémentation `DriveStorageAdapter` avec OAuth Google Drive via `googleapis` Dart
- `sync-service`: `SyncService` orchestrant le protocole lock/download/work/upload/unlock ; exposé via Riverpod ; gère les états (idle, syncing, locked, error)
- `sync-ui`: Indicateur d'état sync visible en permanence (NavigationRail/BottomBar) + bouton "Synchroniser" déclenchant le cycle complet + retour utilisateur (snackbar, spinner, dialogue erreur)

### Modified Capabilities

- `app-config`: Activation du Mode 2 dans les Settings (le sélecteur de service cloud passe de placeholder à fonctionnel) ; ajout du flux OAuth + migration one-shot au moment de la bascule Mode 1 → Mode 2

## Impact

- Nouvelles dépendances Dart : `googleapis`, `googleapis_auth`, `google_sign_in` (ou flux OAuth natif via `url_launcher` + serveur local de callback)
- Nouveaux fichiers : `lib/services/storage_adapter.dart`, `lib/services/drive_storage_adapter.dart`, `lib/services/sync_service.dart`, `lib/widgets/sync_status_indicator.dart`
- Fichiers modifiés : `lib/screens/settings_screen.dart` (activation Mode 2), `lib/main.dart` ou `AppShell` (intégration indicateur sync)
- Aucun changement de schéma drift / SQLite — seule la couche d'accès au fichier change
- Périmètre : Mode 2 MVP = Google Drive uniquement ; l'interface StorageAdapter permet d'ajouter Dropbox en V1 sans modifier SyncService
