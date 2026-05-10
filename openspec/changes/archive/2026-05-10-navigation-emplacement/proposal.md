## Why

La vue stock liste toutes les bouteilles en vrac : impossible de voir rapidement ce qu'il y a dans un casier précis, ni d'avoir une valeur globale par zone. C'est bloquant pour un inventaire physique (croiser ce que l'app dit avec la réalité) et pour connaître la valeur d'une partie de la cave.

## What Changes

- Nouvel onglet "Emplacements" dans la navigation principale (Windows NavigationRail + Android BottomBar)
- Écran d'arbre hiérarchique des emplacements (Niveau1 → Niveau2 → Niveau3) avec stats agrégées par nœud : `N bouteilles (NN €)`
- Toggle "Inclure les sous-emplacements" (défaut : désactivé) pour agréger les stats des enfants dans le parent
- Navigation en profondeur : tap sur un nœud parent → écran enfants ; tap sur un nœud feuille → liste des bouteilles de ce nœud exact
- Liste de bouteilles à la feuille : même actions que la vue stock (BottomSheet, multi-sélection), filtrée sur l'emplacement sélectionné

## Capabilities

### New Capabilities
- `location-tree-view` : arbre hiérarchique des emplacements avec stats (nombre de bouteilles, valeur totale prix_achat), navigation niveau par niveau, et liste bouteilles au nœud feuille

### Modified Capabilities
- `stock-view` : ajout d'un filtre emplacement dans la vue stock (le tap sur un nœud peut optionnellement filtrer la vue stock — à décider en design)

## Impact

- `lib/features/stock/` : nouveau sous-dossier `location/` avec `LocationTreeScreen`, `LocationNodeScreen`, `location_provider.dart`
- `lib/shared/adaptive_layout.dart` : ajout de l'onglet Emplacements dans NavigationRail (Windows) et BottomBar (Android)
- `lib/router.dart` : nouvelles routes `/locations`, `/locations/:path`
- `lib/data/daos/bouteille_dao.dart` : nouvelle requête agrégée `emplacement + COUNT + SUM(prix_achat)` pour les bouteilles en stock
- Pas de migration de base de données (utilise les données existantes)
- Pas de dépendance nouvelle

## Non-goals

- Modification des emplacements depuis cet écran (ça reste dans le BottomSheet "Déplacer")
- Renommer ou réorganiser les emplacements en masse
- Vue graphique ou plan de cave
- Bouteilles sans emplacement (champ NOT NULL en base — cas impossible)
