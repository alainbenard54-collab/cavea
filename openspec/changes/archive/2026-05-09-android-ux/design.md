## Context

L'application Flutter cible Windows desktop (fenêtre redimensionnable) et Android (portrait et paysage). La détection du layout repose sur la largeur disponible : `_DesktopRail` (NavigationRail) si ≥600px, `_MobileBar` (BottomNavigationBar) si <600px. En paysage sur Android, la largeur dépasse souvent 600px, ce qui enclenchait `_DesktopRail` — avec `NavigationRail` qui déborde visuellement et n'est pas adapté aux interactions tactiles mobiles. Plusieurs écrans présentaient aussi des débordements verticaux en paysage (filtres stock, BottomSheet).

Côté sync, l'échec de `acquireLock` (SyncStarting→SyncError) ne préservait pas l'état `SyncReadOnly` : l'icône d'erreur sync apparaissait, le bouton "Prendre la main" disparaissait, et l'utilisateur se retrouvait bloqué.

## Goals / Non-Goals

**Goals:**
- Android utilise toujours `_MobileBar` quel que soit l'orientation
- `_MobileBar` redessinée pour exposer les actions sync de façon compacte
- Tous les écrans sans débordement en paysage Android
- Échec d'acquisition du lock → état `SyncReadOnly` préservé, UX de récupération disponible
- Badge cadenas orange explicite sur les actions désactivées en lecture seule

**Non-Goals:**
- Résolution de l'autocomplete derrière le clavier en paysage (reporté V1.1)
- Densification de la table stock en paysage (reporté V1.1)
- Modification du comportement de sync (upload/download/lock)

## Decisions

### 1. Détection plateforme plutôt que détection largeur pour Android

**Décision** : `adaptive_layout.dart` utilise `Platform.isAndroid` pour forcer `_MobileBar`, indépendamment de la largeur.

**Pourquoi** : En paysage Android, `MediaQuery.of(context).size.width ≥ 600` → `isDesktop()` retourne `true` → `_DesktopRail` s'affiche. Mais `NavigationRail` déborde visuellement même avec `labelType: NavigationRailLabelType.none` et `minWidth: 40`. La largeur n'est pas un discriminant suffisant : un téléphone en paysage n'est pas un desktop.

**Alternative écartée** : Réduire encore `NavigationRail` (padding, miniWidth) — trop fragile, casse sur certains écrans.

### 2. Icônes compactes sync dans _MobileBar au lieu de boutons texte

**Décision** : Les actions sync (Prendre la main, Abandonner, Sauvegarder/Libérer, Synchroniser) deviennent des `IconButton` compacts dans la zone gauche de `_MobileBar`.

**Pourquoi** : Les libellés texte ("Sauvegarder et libérer") ne tiennent pas dans une barre 56px avec 5 éléments de navigation. Les icônes (`lock_open`, `lock_reset`, `cloud_done`, `sync`) sont reconnaissables et suffisamment distinctes.

### 3. _NavBtn toujours onTap même si disabled

**Décision** : `_NavBtn` appelle toujours `onTap` (qui affiche la snackbar "Indisponible") même quand `isDisabled: true`. La désactivation visuelle est assurée via `opacity` et le badge, pas via `onTap: null`.

**Pourquoi** : `InkWell(onTap: null)` absorbe le tap sans le transmettre. L'utilisateur tape un bouton grisé et rien ne se passe — pas d'explication. Avec le badge cadenas orange + snackbar, il comprend immédiatement pourquoi l'action est bloquée.

### 4. resetToReadOnly() immédiat sur échec acquireLock

**Décision** : Si `acquireLock()` échoue (état `SyncStarting→SyncError`), l'app appelle immédiatement `resetToReadOnly()` pour revenir à `SyncReadOnly`.

**Pourquoi** : L'état `SyncError` masque le bouton "Prendre la main" et affiche une icône d'erreur. L'utilisateur est bloqué sans voie de récupération. En revenant à `SyncReadOnly` immédiatement, l'app reste utilisable en lecture, et le bouton "Prendre la main" reste accessible pour réessayer.

**Trade-off** : L'erreur réseau est "absorbée" visuellement (pas d'icône d'erreur persistante). Compensé par un dialog "Impossible de prendre la main" avec les options Réessayer / Rester en lecture seule.

### 5. Bouton "Prendre la main" aussi sur Windows

**Décision** : `_DesktopRail` affiche un `TextButton.icon("Prendre la main")` quand `isReadOnly`, en plus de l'indicateur sync existant.

**Pourquoi** : Sur Windows, l'indicateur cadenas ambre existait déjà mais sans action directe. Ajouter le bouton harmonise le comportement avec Android et rend l'action plus découvrable.

## Risks / Trade-offs

- [Risque] `Platform.isAndroid` dans `adaptive_layout.dart` rend la logique non-testable sans device — Mitigation : les tests de layout Widget utilisent `defaultTargetPlatform` mockable.
- [Risque] Icônes sync sans libellé — ambiguïté pour un nouvel utilisateur — Mitigation : tooltip sur chaque icône, comportement explicité dans le dialog "Prendre la main".
- [Trade-off] `resetToReadOnly()` sur échec masque l'erreur réseau — acceptable : l'utilisateur voit le dialog d'échec, peut réessayer, et reste fonctionnel en lecture.
