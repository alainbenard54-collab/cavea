## ADDED Requirements

### Requirement: SyncService — états
`SyncService` (`lib/services/sync_service.dart`) SHALL être un `StateNotifier<SyncState>` Riverpod exposé via `syncServiceProvider`. Les états SHALL être : `idle`, `syncing`, `locked(String lockedBy)`, `error(String message)`. L'état initial SHALL être `idle`.

#### Scenario: État initial
- **WHEN** l'application démarre en Mode 2
- **THEN** `SyncService` est en état `idle`

#### Scenario: Transition pendant la synchronisation
- **WHEN** l'utilisateur déclenche "Synchroniser"
- **THEN** `SyncService` passe immédiatement en état `syncing` puis retourne en `idle` à la fin (succès) ou en `error` (échec)

---

### Requirement: SyncService — protocole de synchronisation
`SyncService` SHALL orchestrer le protocole complet : (1) vérifier le lock, (2) acquérir le lock, (3) télécharger `cave.db`, (4) fermer drift, (5) remplacer le fichier local, (6) rouvrir drift, (7) retourner en `idle` pour permettre le travail, (8) lors du prochain "Synchroniser" : uploader, (9) libérer le lock.

#### Scenario: Synchronisation réussie sans conflit
- **WHEN** l'utilisateur déclenche "Synchroniser" et qu'aucun lock étranger valide n'existe
- **THEN** `SyncService` : (1) passe en `syncing`, (2) acquiert le lock, (3) télécharge `cave.db`, (4) ferme drift, (5) remplace le fichier local, (6) invalide le provider drift pour le rouvrir, (7) passe en `idle`

#### Scenario: Upload et unlock lors d'une deuxième synchronisation
- **WHEN** l'utilisateur déclenche "Synchroniser" alors que `SyncService` détient déjà le lock (travail local effectué depuis la dernière sync)
- **THEN** `SyncService` : (1) passe en `syncing`, (2) uploade le fichier local, (3) libère le lock, (4) puis effectue le cycle download/reopen comme ci-dessus, (5) passe en `idle`

#### Scenario: Lock détenu par un autre appareil
- **WHEN** l'utilisateur déclenche "Synchroniser" et qu'un lock étranger valide existe
- **THEN** `SyncService` passe en état `locked(lockedBy: <device_id>)` et n'effectue aucune opération Drive

#### Scenario: Erreur réseau ou API Drive
- **WHEN** une opération `StorageAdapter` lève une exception pendant la synchronisation
- **THEN** `SyncService` passe en état `error(message: <description>)`, libère le lock si détenu, et laisse le fichier local intact

---

### Requirement: SyncService — réouverture drift
`SyncService` SHALL fermer l'instance drift existante avant de remplacer `cave.db` et invalider le provider Riverpod drift après remplacement pour forcer la réouverture. Les écrans qui écoutent les streams drift SHALL reconstruire automatiquement via Riverpod.

#### Scenario: Réouverture après download
- **WHEN** `SyncService` a remplacé le fichier `cave.db` local
- **THEN** `ref.invalidate(driftDatabaseProvider)` est appelé et tous les streams drift actifs se rétablissent sur la nouvelle base

---

### Requirement: SyncService — Mode 1 inactif
En Mode 1, `SyncService` SHALL être inactif : `syncServiceProvider` retourne un état `idle` permanent et toute tentative de sync est un no-op. Aucune instance de `StorageAdapter` n'est créée en Mode 1.

#### Scenario: Mode 1 actif
- **WHEN** la configuration courante est Mode 1
- **THEN** `syncServiceProvider` expose un `SyncState.idle` statique et le bouton "Synchroniser" n'est pas affiché dans l'UI
