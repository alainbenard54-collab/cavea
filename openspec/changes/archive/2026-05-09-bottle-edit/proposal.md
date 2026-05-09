## Why

Le stub "Modifier la fiche" du BottomSheet affiche un SnackBar "Fonctionnalité à venir" depuis le MVP. C'est la première feature V1 attendue : permettre de corriger les métadonnées d'une bouteille (domaine, appellation, millésime, garde, prix…) après son ajout en lot.

## What Changes

- Création d'un écran d'édition complète `BottleEditScreen` accessible depuis le BottomSheet.
- Ajout d'une route `/bottle-edit/:id` dans le router go_router.
- Remplacement du stub SnackBar par une navigation vers cet écran.
- Le formulaire expose tous les champs non protégés avec les mêmes conventions que `BulkAddScreen` (autocomplétion, validation garde, dropdown couleur).
- `updated_at` est mis à jour automatiquement à la sauvegarde.

## Capabilities

### New Capabilities

- `bottle-edit-screen` : formulaire d'édition complète d'une bouteille — chargement par ID, tous les champs non protégés éditables, validation garde_min ≤ garde_max, autocomplétion sur les champs texte, sauvegarde via `BouteilleDao.updateBouteille()`.

### Modified Capabilities

- `bottle-actions` : l'action "Modifier la fiche" SHALL désormais naviguer vers `BottleEditScreen` au lieu d'afficher le SnackBar stub.

## Impact

- Nouveau fichier : `lib/features/bottle_edit/bottle_edit_screen.dart`
- Modifié : `lib/app/router.dart` — ajout de la route `/bottle-edit/:id`
- Modifié : `lib/features/bottle_actions/bottle_actions_sheet.dart` — `onModifierFiche` remplace le SnackBar par `context.push('/bottle-edit/${bouteille.id}')`
- Modifié : `lib/data/daos/bouteille_dao.dart` — `updateBouteille` déjà implémenté, pas de changement
- Mode lecture seule : le BottomSheet masque déjà les actions en `SyncReadOnly` — aucune modification supplémentaire requise
- Modes 1 et 2 concernés (l'édition fonctionne identiquement dans les deux modes)
