## 1. StockTable — colonne Emplacement optionnelle (PC + Android)

- [x] 1.1 Dans `lib/features/stock/stock_table.dart`, ajouter `final bool showEmplacementColumn` à `StockTable` (défaut `true`)
- [x] 1.2 Adapter `_layout()` pour omettre la cellule Emplacement (header et données) quand `showEmplacementColumn == false`, sans changer les largeurs/flex des autres colonnes
- [x] 1.3 Adapter `_headerCell` pour l'en-tête Emplacement : ne pas l'ajouter à la liste des cells passées à `_layout()` quand `showEmplacementColumn == false`
- [x] 1.4 Adapter `_dataRow` de la même façon pour la cellule de données Emplacement
- [x] 1.5 Vérifier que l'écran Stock (usage existant, `showEmplacementColumn` par défaut `true`) est inchangé visuellement

## 2. Tri réutilisable depuis l'écran Emplacements (PC + Android)

- [x] 2.1 Dans `lib/features/stock/stock_controller.dart`, rendre la fonction `_sorted()` accessible depuis `location_tree_screen.dart` (retrait du préfixe privé ou export ciblé, sans changer sa logique)

## 3. Bascule tableau/liste dans `_BottleListBody` (PC + Android)

- [x] 3.1 Dans `lib/features/locations/location_tree_screen.dart`, convertir `_BottleListBody` pour porter un état local `sortColumn` (défaut `'domaine'`) et `sortAscending` (défaut `true`)
- [x] 3.2 Appliquer la fonction de tri réutilisée (tâche 2.1) sur la liste reçue de `locationBottleListProvider` avant affichage
- [x] 3.3 Envelopper le corps de la liste dans un `LayoutBuilder` : si `constraints.maxWidth >= 640`, afficher `StockTable(showEmplacementColumn: false, ...)` ; sinon conserver `ListView.separated` + `BouteilleListTile` actuel
- [x] 3.4 Câbler `sortColumn`/`sortAscending`/`onSort` du `StockTable` sur l'état local de la tâche 3.1
- [x] 3.5 Câbler `isSelectMode`/`selectedIds`/`onToggleSelect`/`onLongPressRow` du `StockTable` sur `selectionProvider`, identique au branchement déjà utilisé pour `ListView.separated`

## 4. Validation

- [x] 4.1 `flutter analyze` — 0 issue (0 issue, 76.4s)
- [x] 4.2 `flutter test` — 0 régression (149/149 tests passent)
- [x] 4.3 Test PC (fenêtre ≥ 640px) : ouvrir un emplacement contenant des bouteilles, vérifier que le tableau s'affiche avec les colonnes icône/domaine/appellation/millésime/garde/prix, sans colonne emplacement
- [x] 4.4 Test PC : cliquer sur un en-tête de colonne triable, vérifier que la liste se trie ; cliquer à nouveau, vérifier l'inversion du sens
- [x] 4.5 Test PC : rétrécir la fenêtre sous 640px, vérifier le retour à l'affichage en tuiles (`BouteilleListTile`)
- [x] 4.6 Test PC : appui long sur une ligne du tableau, vérifier l'entrée en mode sélection (case à cocher, `BulkActionBar`) puis Déplacer/Consommer en lot
- [x] 4.7 Test Android paysage (largeur ≥ 640px) : mêmes vérifications que 4.3-4.6
- [x] 4.8 Test Android portrait (largeur < 640px) : vérifier que l'affichage reste en tuiles, comportement inchangé
- [x] 4.9 Test mode lecture seule (SyncReadOnly, PC ou Android) : validé par relecture de code (`onLongPressRow: isReadOnly ? null : ...` identique au câblage déjà en production sur `StockTable`/stock_screen.dart, `showBottleActionsSheet` lit `syncServiceProvider` lui-même) **et** confirmé manuellement par l'utilisateur en conditions réelles
