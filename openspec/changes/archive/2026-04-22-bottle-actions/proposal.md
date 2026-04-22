## Why

La vue stock permet de consulter les bouteilles mais pas d'agir sur elles. Les deux actions les plus fréquentes — déplacer une bouteille et la consommer — n'ont pas encore d'interface. Un BottomSheet d'actions rapides accessible par clic sur une ligne est la solution la plus ergonomique : l'utilisateur reste dans le stock, voit le contexte, et agit sans navigation supplémentaire.

## What Changes

- Clic sur une ligne du stock → BottomSheet modal "Actions sur cette bouteille"
- Action **Déplacer** : saisie de l'emplacement avec autocomplétion sur les emplacements existants → `UPDATE emplacement`
- Action **Consommer** : date (défaut = aujourd'hui, modifiable), note /10 optionnelle, commentaire optionnel → `UPDATE date_sortie + note_degus + commentaire_degus`
- Action **Modifier la fiche** : stub MVP → SnackBar "Fonctionnalité à venir" (interface en place pour V1)
- Action **Annuler** : ferme le BottomSheet

## Capabilities

### New Capabilities

- `bottle-actions`: BottomSheet d'actions rapides (Déplacer, Consommer, Modifier fiche stub, Annuler)

### Modified Capabilities

- `stock-view`: Les lignes de la liste/tableau deviennent cliquables et ouvrent le BottomSheet.
- `bouteilles-db`: Ajout DAO — mise à jour emplacement seul, mise à jour consommation (date_sortie + note + commentaire), liste des emplacements distincts pour autocomplétion.

## Impact

- `lib/features/bottle_actions/` : nouveau module (BottomSheet + sous-formulaires)
- `lib/features/stock/stock_screen.dart` : `onTap` sur les lignes
- `lib/features/stock/stock_table.dart` : `onTap` sur les lignes desktop
- `lib/features/stock/bouteille_list_tile.dart` : `onTap` sur les lignes mobile
- `lib/data/daos/bouteille_dao.dart` : deux nouvelles méthodes
- Mode 1 uniquement (MVP)

## Non-goals

- Implémentation de l'écran d'édition complète (V1 — interface stub seulement)
- Suppression physique d'une bouteille de la base
- Consommation en lot
- Historique des mouvements
