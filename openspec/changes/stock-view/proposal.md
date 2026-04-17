## Why

La base de données est alimentée mais l'application n'offre aucune vue sur le stock — l'utilisateur ne peut pas consulter ses bouteilles. C'est la fonctionnalité centrale sans laquelle l'app n'est pas utilisable au quotidien.

## What Changes

- Remplacement de l'écran principal placeholder par une vraie vue stock
- Liste réactive des bouteilles en stock (stream `watchStock()` existant)
- Filtres combinables : couleur, appellation, millésime, recherche texte (domaine)
- Layout adaptatif : `NavigationRail` desktop (≥600px) / `BottomNavigationBar` mobile (<600px)
- Ajout de `watchStockFiltered()` dans `BouteilleDao` pour filtrage côté base
- Provider Riverpod pour l'état des filtres actifs
- Modification `bouteilles-db` : ajout de la méthode de requête filtrée

## Capabilities

### New Capabilities

- `stock-view` : affichage de la liste des bouteilles en stock avec filtres interactifs et layout adaptatif

### Modified Capabilities

- `bouteilles-db` : ajout de `watchStockFiltered()` avec paramètres couleur, appellation, millésime, texte

## Impact

- `lib/features/stock/` : nouveau dossier (écran + controller)
- `lib/data/daos/bouteille_dao.dart` : nouvelle méthode de requête
- `lib/app/router.dart` : `/` pointe vers `StockScreen` au lieu du placeholder
- `lib/features/home/home_screen.dart` : remplacé par `StockScreen`
- `lib/shared/adaptive_layout.dart` : étoffé avec le shell de navigation adaptatif
- Aucune nouvelle dépendance

## Non-goals

- Vue "à boire" avec indicateurs de maturité couleur — étape MVP 3
- Filtres sauvegardés — V1
- Tri personnalisable — V1
- Actions sur les bouteilles (consommer, déplacer) — étapes MVP 4 et 6
- Statistiques de stock — V2
