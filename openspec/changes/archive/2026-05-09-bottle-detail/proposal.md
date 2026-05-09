## Why

L'application dispose d'une fiche d'édition (`BottleEditScreen`) mais aucune vue lecture seule n'est disponible. Un utilisateur souhaitant simplement consulter le détail d'une bouteille — notamment en mode lecture seule (`SyncReadOnly`) où l'édition est interdite — n'a actuellement aucun accès à ces informations depuis le BottomSheet. Cette feature V1 comble ce manque.

## What Changes

- **Nouvelle route `/bottle/:id`** : navigue vers `BottleDetailScreen`, écran lecture seule affichant tous les champs d'une bouteille
- **Nouvelle action "Consulter la fiche"** dans le BottomSheet des actions bouteille, accessible en mode normal et en mode `SyncReadOnly`
- **Réordonnancement des actions** du BottomSheet : Consommer → Consulter la fiche → Déplacer → Modifier la fiche → Annuler
- **Comportement `SyncReadOnly` mis à jour** : affiche désormais "Consulter la fiche" + "Fermer" au lieu du simple message lecture seule
- **Affichage conditionnel** : `note_degus` et `commentaire_degus` masqués si la bouteille est encore en stock (`date_sortie` vide) — ces champs n'ont de sens qu'après consommation

## Capabilities

### New Capabilities

- `bottle-detail`: Écran lecture seule affichant tous les champs non-techniques d'une bouteille, avec affichage conditionnel selon l'état de consommation

### Modified Capabilities

- `bottle-actions`: Ajout de l'action "Consulter la fiche", réordonnancement des actions, nouveau comportement du mode `SyncReadOnly`

## Non-goals

- Aucune logique d'édition dans `BottleDetailScreen` — la fiche reste strictement en lecture
- Pas de refactorisation complète de `BottleEditScreen` (réutilisation de composants seulement si naturelle)
- Pas d'accès à `BottleDetailScreen` depuis d'autres écrans que le BottomSheet (futur : historique des consommations)

## Impact

- **Nouveau fichier** : `lib/ui/screens/bottle_detail_screen.dart`
- **Modifié** : `lib/ui/screens/bottle_actions_bottom_sheet.dart` — ordre actions + SyncReadOnly
- **Modifié** : `lib/router.dart` — nouvelle route `/bottle/:id`
- **Modifié** : `CLAUDE.md` — section `bottle-actions` mise à jour
- Modes concernés : Mode 1 et Mode 2 (Windows + Android)
- Aucune dépendance nouvelle, aucune migration base de données
