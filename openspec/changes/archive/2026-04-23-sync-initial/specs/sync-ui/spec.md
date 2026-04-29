## ADDED Requirements

### Requirement: Indicateur d'état sync permanent
L'application SHALL afficher un indicateur d'état sync visible en permanence dans la NavigationRail (Desktop) et dans la BottomNavigationBar (Mobile) lorsque le Mode 2 est actif. L'indicateur SHALL refléter en temps réel l'état de `SyncService`.

#### Scenario: État idle — aucune sync en cours
- **WHEN** `SyncService` est en état `idle` et que le Mode 2 est actif
- **THEN** l'indicateur affiche une icône "sync" grise (neutre) sans animation

#### Scenario: État syncing — sync en cours
- **WHEN** `SyncService` est en état `syncing`
- **THEN** l'indicateur affiche une icône "sync" animée (rotation) et l'UI principale est recouverte d'un overlay semi-transparent bloquant les interactions

#### Scenario: État locked — cave verrouillée par un autre appareil
- **WHEN** `SyncService` est en état `locked(lockedBy:)`
- **THEN** l'indicateur affiche une icône "lock" orange avec un tooltip indiquant "Cave verrouillée par <device_id>"

#### Scenario: État error — erreur de synchronisation
- **WHEN** `SyncService` est en état `error(message:)`
- **THEN** l'indicateur affiche une icône "sync_problem" rouge

#### Scenario: Mode 1 actif
- **WHEN** la configuration courante est Mode 1
- **THEN** aucun indicateur sync n'est affiché

---

### Requirement: Bouton Synchroniser
L'application SHALL exposer un bouton "Synchroniser" accessible en Mode 2. Ce bouton SHALL déclencher le protocole complet de `SyncService`. Le bouton SHALL être désactivé pendant l'état `syncing`.

#### Scenario: Déclenchement de la synchronisation
- **WHEN** l'utilisateur appuie sur "Synchroniser" et que `SyncService` est en `idle`
- **THEN** `SyncService.sync()` est appelé et l'indicateur passe en `syncing`

#### Scenario: Bouton désactivé pendant sync
- **WHEN** `SyncService` est en état `syncing`
- **THEN** le bouton "Synchroniser" est désactivé (non cliquable) pour éviter les appels concurrents

#### Scenario: Mode 1 actif
- **WHEN** la configuration courante est Mode 1
- **THEN** le bouton "Synchroniser" n'est pas affiché

---

### Requirement: Feedback utilisateur post-sync
L'application SHALL afficher un retour utilisateur à l'issue de chaque tentative de synchronisation.

#### Scenario: Succès
- **WHEN** `SyncService` repasse en `idle` après une sync réussie
- **THEN** un snackbar "Synchronisation réussie" est affiché brièvement

#### Scenario: Échec (erreur)
- **WHEN** `SyncService` passe en état `error(message:)`
- **THEN** un dialogue d'erreur affiche le message et propose "Réessayer" ou "Fermer"

#### Scenario: Cave verrouillée
- **WHEN** `SyncService` passe en état `locked(lockedBy:)`
- **THEN** un snackbar indique "Cave verrouillée par <device_id> — réessayez plus tard"

---

### Requirement: Overlay de blocage pendant sync
L'application SHALL bloquer toutes les interactions utilisateur pendant l'état `syncing` (fermeture et réouverture drift).

#### Scenario: Blocage UI pendant sync
- **WHEN** `SyncService` est en état `syncing`
- **THEN** un overlay semi-transparent avec un spinner est affiché par-dessus l'ensemble de l'application, rendant tous les widgets sous-jacents non interactifs
