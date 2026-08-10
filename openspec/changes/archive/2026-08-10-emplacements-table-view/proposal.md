## Why

L'écran Emplacements affiche la liste de bouteilles d'un nœud sélectionné en tuiles (`BouteilleListTile`) quelle que soit la largeur disponible, alors que l'écran Stock bascule vers un tableau triable (`StockTable`) dès que la largeur du contenu atteint 640px. Résultat : sur un écran large (desktop Windows/Linux, ou téléphone Android en paysage), l'écran Emplacements sous-exploite l'espace disponible et affiche moins d'information par bouteille que l'écran Stock dans les mêmes conditions.

## What Changes

- La liste de bouteilles d'un nœud (`_BottleListBody` dans `location_tree_screen.dart`) SHALL basculer vers un affichage tableau triable quand la largeur disponible est ≥ 640px, selon le même mécanisme que Stock (`LayoutBuilder`, seuil identique, indépendant de la plateforme/orientation).
- Le tableau réutilise `StockTable`, étendu d'un paramètre pour masquer la colonne Emplacement (déjà visible dans le fil d'ariane de l'écran, donc redondante ici).
- Le tri des colonnes (domaine, appellation, millésime, garde, prix) est géré par un état de tri local à l'écran Emplacements (indépendant du `stockFilterProvider`, qui porte aussi les filtres couleur/appellation/millésime/texte propres à Stock), en réutilisant la logique de tri existante de `stock_controller.dart`.
- En dessous de 640px, le comportement actuel (liste `BouteilleListTile`) est inchangé.
- La multi-sélection (appui long, `BulkActionBar`, cases à cocher) et le clic ouvrant le `BottomSheet` d'actions restent identiques en table comme en liste.

## Capabilities

### New Capabilities
*(aucune)*

### Modified Capabilities
- `location-tree-view` : la requirement "Liste de bouteilles avec badge maturité" est complétée par un seuil d'affichage tableau/liste identique à celui de `stock-view`, avec tri par colonne et masquage de la colonne Emplacement.

## Impact

- `lib/features/locations/location_tree_screen.dart` : `_BottleListBody` passe de `ListView.separated` fixe à une bascule `LayoutBuilder` (table `StockTable` ≥640px / liste sinon), avec état de tri local (colonne + sens).
- `lib/features/stock/stock_table.dart` : ajout d'un paramètre pour masquer optionnellement la colonne Emplacement (layout de colonnes ajusté en conséquence).
- `lib/features/stock/stock_controller.dart` : la fonction de tri `_sorted()` devient réutilisable depuis l'écran Emplacements (pas de changement de logique, juste de portée d'usage).
- Aucun changement de schéma de données, aucun impact sur Mode 1/2/3.

## Non-goals

- Pas de filtres (couleur, appellation, millésime, texte) sur l'écran Emplacements — hors périmètre de cette tâche, l'écran reste scopé à un emplacement précis.
- Pas de changement du comportement `StockTable` existant sur l'écran Stock lui-même (le paramètre de masquage de colonne est optionnel, comportement par défaut inchangé).
- Pas de persistance du tri choisi sur l'écran Emplacements entre sessions (état local, réinitialisé à chaque navigation, comme le reste de la navigation par emplacement).
