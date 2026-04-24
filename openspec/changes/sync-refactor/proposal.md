## Why

Le mécanisme de sync Mode 2 actuel est 100% manuel et utilise le scope `appDataFolder` de Google Drive, rendant les fichiers invisibles dans l'interface Drive. Cela empêche l'utilisateur de supprimer manuellement un verrou bloquant (après un crash) ou de sauvegarder `cave.db` directement depuis Drive. Par ailleurs, l'UX de sync manuelle (lock → download → travailler → upload → unlock) est trop complexe pour un usage quotidien : elle sera remplacée par une gestion automatique du cycle de vie au démarrage et à la fermeture de l'app.

## What Changes

- **Scope Google Drive** : `appDataFolder` → `drive.file` avec dossier `Cavea` visible à la racine du Drive (fichiers accessibles et supprimables depuis l'interface web Google Drive)
- **Sync automatique au démarrage** : l'app vérifie le verrou, pose le lock et télécharge la base automatiquement — l'utilisateur n'a pas à déclencher manuellement lock + download
- **Trois cas de démarrage** : lock libre (chemin nominal), lock à nous (crash recovery avec choix), lock tiers (lecture seule ou abandon)
- **Bouton Sync** : devient "upload manuel" uniquement (lock conservé) — en lecture seule, le bouton est absent
- **Fermeture interceptée** : `didRequestAppExit()` déclenche upload + unlock avant fermeture effective (Alt+F4, bouton ×, taskbar)
- **Indicateur visuel** : deux icônes dans l'AppBar — mode de stockage (PC/nuage) et état de verrou (cadenas ouvert vert / cadenas fermé ambre)
- **Dialogs UX** : crash recovery, lock tiers, fermeture (avec progression)

## Capabilities

### New Capabilities
- `sync-auto-startup`: Gestion automatique du cycle lock/download au démarrage et upload/unlock à la fermeture en Mode 2
- `sync-status-indicator`: Indicateur visuel permanent dans l'AppBar (icône mode + icône verrou)

### Modified Capabilities
- `app-config`: Ajout des propriétés `isReadOnly` et `isWriteMode` exposées par SyncService ; le scope Google Drive change de `appDataFolder` à `drive.file`

## Impact

- `lib/services/drive_storage_adapter.dart` : scope, gestion dossier `Cavea`, toutes les requêtes Drive API
- `lib/services/sync_service.dart` : nouveaux états (`SyncReadOnly`, `SyncStarting`), méthode `syncOnStartup()`, propriétés `isReadOnly`/`isWriteMode`
- `lib/main.dart` / `_AppWrapperState` : appel `syncOnStartup()` au démarrage, `WidgetsBindingObserver.didRequestAppExit()`, dialogs startup
- `lib/shared/adaptive_layout.dart` (ou widget AppBar) : indicateur visuel mode + verrou
- `lib/features/settings/settings_screen.dart` : retrait du déclenchement manuel lock/download (bouton Sync = upload uniquement)
- Dépendances inchangées (aucune nouvelle dépendance pubspec requise)

## Non-goals

- Sync en arrière-plan ou en temps réel (hors MVP)
- Résolution de conflits (dernier upload gagne — toujours)
- Support Dropbox (V1, interface StorageAdapter déjà prévue)
- Mode 3 Android seul (futur)
- Partage multi-utilisateurs concurrent
