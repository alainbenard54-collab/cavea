## Why

Les premiers tests sur Android ont révélé plusieurs problèmes d'ergonomie et de robustesse spécifiques au mobile : barre de navigation inadaptée au paysage, débordements de contenu dans plusieurs écrans, et comportements incorrects lors d'une prise de main échouée. Ces corrections consolident l'expérience Android avant de passer aux fonctionnalités V1 suivantes.

## What Changes

- **Barre de navigation Android** : toujours `_MobileBar` (portrait et paysage) — `_DesktopRail` strictement réservé à Windows. `_MobileBar` redessinée en barre unique 56px : zone sync compacte à gauche, navigation primaire (Stock + Ajouter) au centre, navigation secondaire (Import + Paramètres) à droite.
- **Icônes sync Android** : icônes contextuelles compactes remplacent les boutons texte dans la barre mobile (`_AcquireLockIconBtn`, `_AbandonWriteIconBtn`, `_SaveReleaseIconBtn`, `_SyncIconBtn`).
- **Badge cadenas** : badge orange 11px sur les icônes Ajouter/Import désactivés — Android ET Windows (`_DesktopRail`).
- **Bouton "Prendre la main" Windows** : visible dans `_DesktopRail` quand `isReadOnly`, message dialog adapté par plateforme.
- **Échec d'acquisition du lock** : `resetToReadOnly()` immédiat → état `SyncReadOnly` préservé → icône erreur sync absente → bouton "Prendre la main" reste visible → dialog avec options Réessayer / Rester en lecture seule.
- **`_NavBtn` disabled** : appelle toujours `onTap` même désactivé → snackbar "Indisponible en mode lecture seule" se déclenche correctement.
- **Stock — débordements paysage** : header dans `Flexible + SingleChildScrollView`, chips couleur avec `ShaderMask` gradient, toggle filtres redessiné (reset inline), `_CascadeDropdown` avec `isExpanded: true`.
- **BottomSheet actions — débordement paysage** : contenu dans `SingleChildScrollView`.

## Capabilities

### New Capabilities
- `android-mobile-bar` : barre de navigation mobile Android redessinée — disposition en 3 zones, icônes sync compactes contextuelles, badge cadenas sur boutons désactivés, détection plateforme pour réservation `_DesktopRail` à Windows.

### Modified Capabilities
- `android-sync-ux` : gestion de l'échec d'acquisition du lock (état `SyncReadOnly` préservé, dialog Réessayer/Rester), bouton "Prendre la main" aussi sur Windows avec message adapté par plateforme.
- `stock-view` : corrections overflow paysage (header scrollable, chips couleur avec gradient overflow, toggle filtres compact, `_CascadeDropdown` étendu).
- `bottle-actions` : correction overflow 68px en paysage (contenu dans `SingleChildScrollView`).

## Non-goals

- Ne couvre pas les problèmes non résolus reportés en V1.1 : suggestions autocomplete derrière le clavier en paysage, table stock trop compacte en paysage.
- Ne modifie pas le comportement de synchronisation (upload/download/lock) — uniquement l'UX de navigation et les états d'erreur visibles.
- Ne s'applique pas à iOS (hors périmètre absolu).

## Impact

- `lib/shared/adaptive_layout.dart` — refactoring complet de `_MobileBar`, ajout des 4 widgets icônes sync, `_NavBtn`, badge, bouton "Prendre la main" dans `_DesktopRail`
- `lib/features/stock/stock_screen.dart` — header paysage, chips couleur, toggle filtres, `_CascadeDropdown`
- `lib/features/bottle_actions/bottle_actions_sheet.dart` — wrapper `SingleChildScrollView`
- Modes concernés : Mode 2 principalement (sync), Mode 1 partiellement (badge, overflow)
