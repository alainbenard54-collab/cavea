## ADDED Requirements

### Requirement: Android utilise toujours _MobileBar
Sur Android, l'application SHALL toujours afficher `_MobileBar` (barre de navigation en bas), quel que soit l'orientation (portrait ou paysage). `_DesktopRail` (NavigationRail) SHALL être strictement réservé à Windows.

#### Scenario: Paysage Android
- **WHEN** l'utilisateur fait pivoter l'appareil Android en paysage
- **THEN** `_MobileBar` reste affichée en bas, `_DesktopRail` n'apparaît pas

#### Scenario: Portrait Android
- **WHEN** l'application démarre sur Android en portrait
- **THEN** `_MobileBar` est affichée en bas de l'écran

#### Scenario: Desktop Windows
- **WHEN** l'application est ouverte sur Windows
- **THEN** `_DesktopRail` est affiché, quel que soit la largeur de la fenêtre

---

### Requirement: _MobileBar en 3 zones
`_MobileBar` SHALL être organisée en une barre unique de 56px de hauteur avec trois zones : gauche (sync), centre (navigation primaire), droite (navigation secondaire).

#### Scenario: Zone sync gauche
- **WHEN** l'application est en Mode 2 sur Android
- **THEN** la zone gauche affiche les icônes sync contextuelles selon l'état (lecture seule, écriture, sync en cours)

#### Scenario: Zone navigation centre
- **WHEN** `_MobileBar` est affichée
- **THEN** les boutons Stock et Ajouter sont visibles au centre

#### Scenario: Zone navigation droite
- **WHEN** `_MobileBar` est affichée
- **THEN** les boutons Import et Paramètres sont visibles à droite

---

### Requirement: Icônes sync compactes contextuelles sur Android
En Mode 2, la zone sync de `_MobileBar` SHALL afficher exactement l'icône correspondant à l'état courant. Les icônes SHALL être : `lock_open` vert (écriture disponible → acquérir le lock), `lock_reset` orange (écriture active → abandonner), `cloud_done` vert (écriture active → sauvegarder et libérer), `sync` (synchronisation en cours).

#### Scenario: État SyncReadOnly — aucun lock détenu
- **WHEN** l'état sync est `SyncReadOnly` sur Android
- **THEN** l'icône `lock_open` verte est affichée permettant d'ouvrir le dialog "Prendre la main"

#### Scenario: État SyncIdle — lock détenu
- **WHEN** l'état sync est `SyncIdle` (mode écriture) sur Android
- **THEN** les icônes `lock_reset` (orange) et `cloud_done` (vert) sont affichées côte à côte

#### Scenario: Mode 1 — pas de zone sync
- **WHEN** l'application est en Mode 1 (sans sync)
- **THEN** la zone sync gauche est vide ou absente

---

### Requirement: Badge cadenas sur boutons désactivés en lecture seule
Quand l'état sync est `SyncReadOnly`, les boutons Ajouter et Import SHALL afficher un badge cadenas orange de 11px pour indiquer visuellement pourquoi ils sont désactivés. Ce badge SHALL être visible sur Android (_MobileBar) ET sur Windows (_DesktopRail).

#### Scenario: Badge cadenas en lecture seule Android
- **WHEN** l'état sync est `SyncReadOnly` sur Android
- **THEN** les boutons Ajouter et Import affichent un badge cadenas orange 11px

#### Scenario: Badge cadenas en lecture seule Windows
- **WHEN** l'état sync est `SyncReadOnly` sur Windows
- **THEN** les icônes Ajouter et Import dans `_DesktopRail` affichent un badge cadenas orange 11px

#### Scenario: Badge absent en mode écriture
- **WHEN** l'état sync est `SyncIdle` ou en Mode 1
- **THEN** aucun badge cadenas n'est affiché sur les boutons de navigation

---

### Requirement: Tap sur bouton désactivé déclenche une snackbar
Un tap sur un bouton de navigation désactivé (Ajouter ou Import en `SyncReadOnly`) SHALL toujours déclencher une snackbar "Indisponible en mode lecture seule", même si le bouton est visuellement grisé.

#### Scenario: Tap Ajouter en lecture seule
- **WHEN** l'utilisateur tape le bouton Ajouter en état `SyncReadOnly`
- **THEN** une snackbar "Indisponible en mode lecture seule" s'affiche, la navigation n'a pas lieu

#### Scenario: Tap Import en lecture seule
- **WHEN** l'utilisateur tape le bouton Import en état `SyncReadOnly`
- **THEN** une snackbar "Indisponible en mode lecture seule" s'affiche, la navigation n'a pas lieu
