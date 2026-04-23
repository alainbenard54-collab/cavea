## Context

Les étapes 1–5 du MVP sont complètes en Mode 1 : `cave.db` est ouvert directement via `dart:io`, aucune couche d'abstraction de stockage n'existe. Les Settings affichent un placeholder "Non disponible" pour le Mode 2.

Cette étape introduit le Mode 2 : partage de `cave.db` entre PC Windows et Android via Google Drive. La contrainte fondamentale est qu'Android ne peut pas accéder à un fichier local monté — le fichier doit transiter par l'API cloud dans les deux sens.

Structure existante impactée :
- `lib/services/` : vide aujourd'hui (pas de SyncService, pas de StorageAdapter)
- `lib/screens/settings_screen.dart` : écran Settings avec placeholder Mode 2
- `lib/main.dart` / shell de navigation : NavigationRail/BottomBar existant

## Goals / Non-Goals

**Goals:**
- Définir `StorageAdapter` (interface) en Dart avec les opérations : `lock`, `unlock`, `isLocked`, `downloadDb`, `uploadDb`
- Implémenter `DriveStorageAdapter` via `googleapis` Dart (pas de client Drive desktop)
- `SyncService` Riverpod orchestrant le protocole complet : vérifier lock → lock → download → relancer drift → work → upload → unlock
- Indicateur d'état sync visible en permanence dans la NavigationRail/BottomBar
- Bouton "Synchroniser" accessible + feedback utilisateur (spinner, snackbar succès/erreur)
- Activation Mode 2 dans Settings : flux OAuth Google Drive + migration one-shot du `cave.db` local
- Interface `StorageAdapter` extensible sans modification de `SyncService` (préparation Dropbox V1)

**Non-Goals:**
- Sync automatique (pas de background worker)
- Résolution de conflits champ par champ (stratégie : last-write-wins sur le fichier entier)
- Dropbox (interface prête, implémentation = V1)
- Mode 3 (mobile seul)

## Decisions

### D1 — StorageAdapter : interface Dart abstraite

`StorageAdapter` est une classe abstraite Dart (pas un package séparé).

```dart
abstract class StorageAdapter {
  Future<bool> isLocked();
  Future<void> lock();
  Future<void> unlock();
  Future<File> downloadDb(String localPath);
  Future<void> uploadDb(File localDb);
}
```

**Pourquoi abstraite et non une interface fonctionnelle ?** Drift et Riverpod demandent des classes concrètes ; l'abstraction Dart native est suffisante et évite toute dépendance supplémentaire. `SyncService` prend `StorageAdapter` en paramètre — le provider Riverpod injecte `DriveStorageAdapter` en Mode 2.

### D2 — DriveStorageAdapter : googleapis Dart, pas de client desktop Drive

L'accès à Google Drive se fait via le package Dart `googleapis` + `googleapis_auth`. Le fichier `cave.db` est stocké dans le dossier `appDataFolder` (espace privé de l'application Drive, non visible dans l'UI Drive de l'utilisateur).

**Pourquoi `appDataFolder` ?** Évite la pollution de "Mon Drive" et les conflits avec des fichiers éponymes. L'utilisateur n'a pas à gérer l'emplacement.

**Lock** : implémenté par un fichier sentinelle `cave.db.lock` dans `appDataFolder` contenant `{"locked_by": "<device_id>", "locked_at": "<iso8601>"}`. `isLocked()` vérifie l'existence et la propriété du fichier.

**OAuth** : flux Authorization Code avec `url_launcher` (ouverture navigateur) + serveur HTTP local sur `localhost:8080` pour récupérer le code de retour (Desktop). Sur Android : `google_sign_in`.

**Pourquoi deux flux OAuth ?** Flutter Desktop n'a pas de WebView native pour OAuth ; le flux localhost est la pratique standard. `google_sign_in` est optimisé Android et gère les comptes système.

### D3 — SyncService : Riverpod StateNotifier

`SyncService` est un `StateNotifier<SyncState>` exposé via `syncServiceProvider`. Les états possibles :

```
SyncState: idle | syncing | locked(by: String) | error(message: String)
```

Protocole d'une synchro :
1. `isLocked()` → si lock étranger → état `locked(by:)`, arrêt
2. `lock()`
3. `downloadDb()` → écrire le fichier localement, fermer drift, réouvrir drift sur le nouveau fichier
4. Retour état `idle` (l'utilisateur travaille normalement)
5. Au prochain "Synchroniser" (ou déclenchement sortie) : `uploadDb()` → `unlock()`

**Pourquoi close/reopen drift ?** Drift maintient un handle exclusif sur `cave.db`. Pour remplacer le fichier (download), il faut fermer la base, remplacer le fichier, puis réouvrir. C'est la seule séquence correcte.

**Pourquoi sync manuelle ?** L'utilisateur est le seul rédacteur actif (lock garantit l'exclusivité). Une sync auto en arrière-plan créerait une fenêtre de concurrence et complexifierait la gestion du lock.

### D4 — Migration Mode 1 → Mode 2

Séquence lors de l'activation Mode 2 dans Settings :
1. OAuth Google Drive → token persisté dans `flutter_secure_storage`
2. Dialogue "Voulez-vous envoyer votre cave.db actuel vers Google Drive ?" (avec avertissement : le fichier Drive existant sera écrasé si présent)
3. Upload → `cave.db` local reste en place comme cache de travail
4. `SharedPreferences` : `storage_mode = 2`
5. Prochain démarrage : SyncService actif, `dart:io` direct désactivé pour les opérations de sync

**Rollback** : en Settings, l'utilisateur peut repasser en Mode 1. Le `cave.db` local est la source de vérité (pas de suppression du fichier Drive).

### D5 — Réouverture drift après download

Drift (drift_sqflite / moor) permet de fermer et réouvrir la base. La séquence :
1. `ref.read(driftDatabaseProvider).close()`
2. Copie du fichier téléchargé vers le chemin configuré
3. `ref.invalidate(driftDatabaseProvider)` → Riverpod reconstruit le provider, drift réouvre la base
4. Les écrans qui écoutent les streams drift reconstruisent automatiquement

Cette approche évite de maintenir deux providers séparés Mode 1 / Mode 2.

## Risks / Trade-offs

**[Fermeture drift pendant sync]** → L'UI doit être bloquée (overlay spinner) pendant le close/reopen pour éviter les lectures sur une base fermée. Mitigation : `SyncService` passe en état `syncing` qui déclenche l'overlay au niveau du shell.

**[Stale lock]** → Si l'app crash pendant une sync, le fichier sentinelle reste. Mitigation : `lock()` écrit un timestamp ; `isLocked()` ignore les locks > 24h (configurable).

**[OAuth token expiry]** → Les tokens Google Drive expirent. `googleapis_auth` gère le refresh automatique si le `refresh_token` est persisté. Mitigation : stocker `refresh_token` dans `flutter_secure_storage`.

**[appDataFolder non accessible depuis Android si créé par Desktop]** → `appDataFolder` est par application (`client_id`). Si le `client_id` OAuth est le même pour Desktop et Android (recommandé), les deux apps voient le même dossier. Mitigation : utiliser un seul projet GCP avec deux `client_id` du même projet (Desktop + Android), `appDataFolder` partagé car lié au projet.

**[Taille cave.db]** → À long terme, un fichier SQLite de quelques Mo se télécharge en moins d'1 seconde sur une connexion normale. Pas de pagination, pas de delta-sync nécessaire en MVP.

## Migration Plan

1. Ajouter `googleapis`, `googleapis_auth`, `google_sign_in`, `flutter_secure_storage` dans `pubspec.yaml`
2. Implémenter `StorageAdapter` + `DriveStorageAdapter` (sans modifier l'existant)
3. Implémenter `SyncService` + providers Riverpod
4. Modifier `SettingsScreen` pour activer le flux Mode 2
5. Ajouter `SyncStatusIndicator` dans le shell de navigation
6. Tests manuels : sync PC→Android→PC, stale lock, OAuth refresh

Rollback : les fichiers nouveaux (`storage_adapter.dart`, `drive_storage_adapter.dart`, `sync_service.dart`) sont additifs. `SettingsScreen` conserve le Mode 1 fonctionnel. En cas de bug bloquant, le Mode 2 peut être redésactivé via `SharedPreferences` ou en Settings.

## Open Questions

- **Client ID OAuth** : utiliser un seul projet GCP avec un client_id Desktop + un client_id Android du même projet, ou deux projets séparés ? → Recommandé : même projet GCP, deux client_id (un par plateforme).
- **Fréquence du "Synchroniser"** : l'utilisateur déclenche manuellement, mais faut-il proposer un rappel après N modifications locales ? → Hors MVP, noter pour V1.
