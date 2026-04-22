## 1. Extension du DAO

- [x] 1.1 Ajouter `watchStockFiltered({String? couleur, String? appellation, int? millesime, String? texte})` dans `lib/data/daos/bouteille_dao.dart` — requête drift dynamique, filtres null ignorés, même tri que `watchStock()` — PC + Android
- [x] 1.2 Ajouter `getDistinctCouleurs()`, `getDistinctAppellations()`, `getDistinctMillesimes()` dans `BouteilleDao` — valeurs uniques du stock en cours, triées — PC + Android

## 2. State management des filtres

- [x] 2.1 Créer `lib/features/stock/stock_controller.dart` : `StockFilterState` (couleur, appellation, millesime, texte), `StockFilterController extends StateNotifier`, `stockFilterProvider` (autoDispose) — PC + Android
- [x] 2.2 Créer `stockProvider` (StreamProvider, combine `stockFilterProvider` + `bouteillesDaoProvider`) dans le même fichier — PC + Android
- [x] 2.3 Créer `couleursProvider`, `appellationsProvider`, `millesimesProvider` (FutureProvider, appellent `getDistinct*()`) dans le même fichier — PC + Android

## 3. Widget ligne de bouteille

- [x] 3.1 Créer `lib/features/stock/bouteille_list_tile.dart` : `BouteilleListTile` avec badge couleur (leading), domaine en titre, appellation·millésime en sous-titre, emplacement en trailing — PC + Android

## 4. Écran stock

- [x] 4.1 Créer `lib/features/stock/stock_screen.dart` : `StockScreen` avec `ListView.builder` alimenté par `stockProvider`, barre de recherche texte, compteur "X bouteilles (sur Y)" — PC + Android
- [x] 4.2 Ajouter les sélecteurs de filtres (couleur, appellation, millésime) sous la barre de recherche — dropdowns ou chips — PC + Android
- [x] 4.3 Ajouter bouton "Réinitialiser les filtres" visible uniquement quand au moins un filtre est actif — PC + Android
- [x] 4.4 Afficher message "Aucune bouteille en stock" + bouton import CSV quand le stock est vide — PC + Android

## 5. Layout adaptatif

- [x] 5.1 Remplacer le stub `lib/shared/adaptive_layout.dart` par `AppShell` : `NavigationRail` (≥600px) ou `BottomNavigationBar` (<600px), destinations : Stock + Import CSV — PC + Android
- [x] 5.2 Mettre à jour `lib/app/router.dart` : la route `/` utilise `AppShell` wrappant `StockScreen`, supprimer l'import de `HomeScreen` — PC + Android
- [x] 5.3 Supprimer `lib/features/home/home_screen.dart` (remplacé par `StockScreen` dans `AppShell`) — PC + Android

## 6. Invalidation cache après import

- [x] 6.1 Dans `lib/features/import_csv/import_csv_screen.dart`, appeler `ref.invalidate(couleursProvider)`, `ref.invalidate(appellationsProvider)`, `ref.invalidate(millesimesProvider)` après un import réussi — PC + Android

## 7. Validation

- [x] 7.1 Lancer `flutter run -d windows`, vérifier l'affichage de la liste, les filtres combinés et le layout desktop — PC uniquement
