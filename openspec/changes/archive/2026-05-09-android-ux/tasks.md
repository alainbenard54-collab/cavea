## 1. adaptive_layout.dart — Barre mobile Android

- [x] 1.1 Forcer `_MobileBar` sur Android quel que soit l'orientation — utiliser `Platform.isAndroid` au lieu de `isDesktop()` dans `AdaptiveLayout` (Android + Windows)
- [x] 1.2 Redesigner `_MobileBar` en barre unique 56px : `Container > SizedBox > Row` avec 3 zones (gauche sync, centre navigation primaire, droite navigation secondaire) (Android)
- [x] 1.3 Implémenter `_AcquireLockIconBtn` : `IconButton` vert `lock_open`, visible quand `SyncReadOnly` sans lock détenu, ouvre `_showAcquireLockDialog` (Android)
- [x] 1.4 Implémenter `_AbandonWriteIconBtn` : `IconButton` orange `lock_reset`, visible quand `SyncIdle` (mode écriture actif), permet d'abandonner la session (Android)
- [x] 1.5 Implémenter `_SaveReleaseIconBtn` : `IconButton` vert `cloud_done`, visible quand `SyncIdle`, déclenche upload + libération lock (Android)
- [x] 1.6 Implémenter `_SyncIconBtn` : `IconButton` `sync`, visible quand sync en cours ou `SyncIdle` (Mode 2 PC), déclenche sync manuelle (Android + Windows)
- [x] 1.7 Ajouter badge cadenas orange 11px sur les icônes Ajouter et Import quand `SyncReadOnly` dans `_MobileBar` (Android)

## 2. adaptive_layout.dart — Desktop Windows

- [x] 2.1 Ajouter bouton `TextButton.icon("Prendre la main")` vert dans `_DesktopRail` quand `isReadOnly` (Windows)
- [x] 2.2 Ajouter badge cadenas orange 11px sur les icônes Ajouter et Import dans `_DesktopRail` quand `SyncReadOnly` (Windows)
- [x] 2.3 Modifier `_NavBtn` pour toujours appeler `onTap` même quand `isDisabled: true` — désactivation visuelle via opacité uniquement, le tap déclenche la snackbar "Indisponible" (Android + Windows)

## 3. adaptive_layout.dart — Gestion échec acquireLock

- [x] 3.1 Appeler `resetToReadOnly()` immédiatement quand `acquireLock()` passe à `SyncError` depuis `SyncStarting` — état `SyncReadOnly` préservé, icône erreur sync absente (Android + Windows)
- [x] 3.2 Ajouter paramètres optionnels `title` et `closeLabel` à `_SyncErrorDialog` pour personnaliser le dialog d'erreur (Android + Windows)
- [x] 3.3 Afficher le dialog "Impossible de prendre la main" avec les options Réessayer et Rester en lecture seule après un échec `acquireLock` (Android + Windows)
- [x] 3.4 Ajouter paramètre `isAndroid` à `_showAcquireLockDialog` pour adapter le message selon la plateforme : Windows mentionne fermeture auto + bouton Synchroniser, Android mentionne "Sauvegarder et libérer" (Android + Windows)

## 4. stock_screen.dart — Overflow paysage

- [x] 4.1 Envelopper le header (SearchBar + filtres) dans `Flexible + SingleChildScrollView` pour éviter le débordement en paysage Android (Android)
- [x] 4.2 Trier les chips couleur : sélectionnées en tête de liste, scroll automatique vers la gauche à la sélection (Android + Windows)
- [x] 4.3 Appliquer `ShaderMask` avec gradient transparent aux bords de la rangée de chips couleur pour indiquer le contenu hors champ (Android + Windows)
- [x] 4.4 Redesigner le toggle filtres paysage : `InkWell` indépendant à gauche (toggle visible/caché), `IconButton` reset à droite sur la même ligne — reset en bas conservé en portrait uniquement (Android)
- [x] 4.5 Ajouter `isExpanded: true` au `_CascadeDropdown` (filtres appellation et millésime) pour éviter le débordement horizontal en portrait filtres avancés (Android)

## 5. bottle_actions_sheet.dart — Overflow paysage

- [x] 5.1 Envelopper le contenu du BottomSheet dans un `SingleChildScrollView` pour éviter le débordement de 68px en paysage Android (Android)

## 6. Tests de vérification

- [x] 6.1 Vérifier sur Android : rotation en paysage → `_MobileBar` affichée, pas de `NavigationRail`, pas de débordement
- [x] 6.2 Vérifier sur Android (Mode 2, SyncReadOnly) : badge cadenas orange sur Ajouter et Import, tap → snackbar "Indisponible"
- [x] 6.3 Vérifier sur Android (Mode 2, SyncReadOnly) : icône `lock_open` verte visible, tap → dialog "Prendre la main" avec message Android
- [x] 6.4 Vérifier sur Windows (Mode 2, SyncReadOnly) : bouton "Prendre la main" vert dans `_DesktopRail`, badge cadenas sur Ajouter/Import
- [x] 6.5 Vérifier sur Windows (Mode 2) : tap "Prendre la main" → dialog message Windows (fermeture auto + Synchroniser)
- [x] 6.6 Vérifier échec `acquireLock` (simuler erreur réseau) → état `SyncReadOnly` préservé, bouton "Prendre la main" toujours visible, dialog "Impossible" avec Réessayer
- [x] 6.7 Vérifier sur Android paysage : header stock sans débordement, filtres accessibles par scroll
- [x] 6.8 Vérifier chips couleur : chip sélectionné repart en tête, gradient overflow visible
- [x] 6.9 Vérifier toggle filtres paysage : toggle et reset sur une même ligne sans chevauchement
- [x] 6.10 Vérifier sur Android paysage : BottomSheet actions sans débordement, contenu scrollable
