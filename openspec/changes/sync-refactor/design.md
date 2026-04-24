## Context

L'implémentation actuelle de la sync Mode 2 (`drive_storage_adapter.dart` + `sync_service.dart`) présente trois problèmes :

1. **Scope `appDataFolder`** : les fichiers Drive sont stockés dans un espace privé de l'app, invisible dans l'interface web Google Drive. L'utilisateur ne peut pas supprimer manuellement le fichier `cave.db.lock` en cas de crash, ni accéder à `cave.db` pour une sauvegarde manuelle.

2. **Cycle manuel** : l'utilisateur doit déclencher explicitement lock → download → travailler → upload → unlock. C'est trop complexe pour un usage quotidien.

3. **Pas de gestion de l'état applicatif** : aucun indicateur visuel du mode en cours (local / partagé / lecture seule), et aucune interception de la fermeture forcée pour sauvegarder avant de quitter.

Les fichiers concernés : `lib/services/drive_storage_adapter.dart`, `lib/services/sync_service.dart`, `lib/main.dart` (`_AppWrapperState`), `lib/shared/adaptive_layout.dart`, `lib/features/settings/settings_screen.dart`.

## Goals / Non-Goals

**Goals:**
- Fichiers Drive visibles et gérables depuis l'interface web Google Drive
- Cycle lock/download/upload automatique, transparent pour l'utilisateur
- Récupération propre des sessions interrompues (crash recovery)
- Interception des fermetures forcées (Alt+F4, bouton ×) pour upload + unlock automatique
- Indicateur visuel permanent du mode et de l'état de verrou

**Non-Goals:**
- Sync en arrière-plan ou en temps réel
- Résolution de conflits (dernier upload gagne toujours)
- Support Dropbox (V1, interface déjà prévue)
- Mode 3 Android seul

## Decisions

### D1 — Scope `drive.file` + dossier `Cavea`

`drive.file` donne accès aux fichiers créés par l'app et les rend visibles dans Drive UI. Les fichiers sont stockés dans un dossier nommé `Cavea` créé à la racine du Drive.

Alternative écartée : `drive` (full access) — trop large, non nécessaire.
Alternative écartée : garder `appDataFolder` — empêche la suppression manuelle du lock.

L'ID du dossier est résolu au premier appel et mis en cache en mémoire (non persisté — le dossier est stable). Si deux instances créent simultanément le dossier `Cavea`, le premier trouvé est utilisé (tri par nom).

Concernant la migration : les fichiers existants dans `appDataFolder` deviennent inaccessibles avec `drive.file`. L'app traitera Drive comme vide et uploadera la base locale au premier démarrage. C'est le comportement correct — l'utilisateur repart d'une base propre dans le dossier visible.

### D2 — `syncOnStartup()` appelé depuis `_AppWrapperState`

La méthode `syncOnStartup()` est appelée dans `_AppWrapperState.initState()` après chargement de la config, avant d'afficher l'écran principal. Elle bloque l'accès au stock pendant son exécution (état `SyncStarting`).

Les dialogs de démarrage (crash recovery, lock tiers) sont affichés depuis le contexte de `_AppWrapperState` via `WidgetsBinding.instance.addPostFrameCallback`, pas depuis le Navigator (qui n'est pas encore actif).

Alternative écartée : déclencher `syncOnStartup()` depuis un provider Riverpod au premier accès — risque de race condition avec la navigation et d'affichage du stock avant la fin de la sync.

### D3 — Nouveaux états `SyncState`

Ajout de :
- `SyncStarting` : startup en cours, UI bloquée
- `SyncReadOnly` : mode lecture seule (lock tiers actif)

Les propriétés `isReadOnly` et `isWriteMode` sont calculées à partir de l'état courant (getters, pas de champs séparés).

`isWriteMode` = état `SyncIdle` ou `SyncSyncing` (on a le lock).
`isReadOnly` = état `SyncReadOnly`.

### D4 — Interception de fermeture via `didRequestAppExit()`

Sur Windows, `WidgetsBindingObserver.didRequestAppExit()` intercepte toutes les fermetures normales (Alt+F4, bouton ×, taskbar close). L'implémentation retourne `AppExitResponse.cancel`, effectue l'upload + unlock avec un dialog de progression, puis appelle `ServicesBinding.instance.exitApplication(AppExitType.required)`.

Sur Android, la fermeture est gérée via `AppLifecycleState.detach` dans le même observer — best-effort (pas de garantie sur hard kill). Le crash recovery au prochain démarrage couvre le cas de perte.

### D5 — Indicateur visuel dans l'AppBar

Deux `IconButton` avec tooltip, ajoutés dans le widget AppBar de `AdaptiveLayout` :
- Icône mode : `Icons.computer` (Mode 1) / `Icons.cloud` (Mode 2) — affichée toujours
- Icône verrou : `Icons.lock_open` vert / `Icons.lock` ambre — affichée uniquement en Mode 2

Les couleurs utilisent `Colors.green` et `Colors.amber` (Material 3 compatible, pas de tokens custom).

## Risks / Trade-offs

**[Lock stale après coupure secteur]** → Crash recovery dialog au prochain démarrage : l'utilisateur choisit upload local ou download Drive. Le lock > 24h est ignoré (comportement inchangé).

**[Dossier Cavea dupliqué]** → Si deux appareils créent le dossier simultanément, l'app prend le premier trouvé par ordre alphabétique. Les fichiers des deux dossiers peuvent diverger temporairement. Risque très faible (création une seule fois au premier lancement).

**[Upload long à la fermeture]** → Dialog de progression bloque la fermeture le temps de l'upload. Si l'utilisateur force-tue le process pendant ce dialog (gestionnaire de tâches), stale lock → crash recovery au prochain démarrage.

**[Android + didRequestAppExit]** → Sur Android, la méthode n'est pas supportée de la même façon. L'upload à la fermeture est best-effort via `AppLifecycleState.detach`. Pour l'usage MVP (PC principal + Android secondaire), c'est acceptable.

**[Bouton Sync en mode écriture = upload sans unlock]** → L'utilisateur ne libère jamais le lock manuellement (sauf en quittant). Si l'app reste ouverte longtemps avec le lock, l'autre appareil est bloqué. Trade-off assumé : c'est une app mono-appareil-actif par design.
