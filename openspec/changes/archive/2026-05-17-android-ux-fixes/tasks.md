## 1. Table stock — densité paysage Android

- [x] 1.1 Dans `stock_table.dart`, calculer `isLandscapeMobile` via `MediaQuery.of(context).orientation` + `Platform.isAndroid` (Android uniquement)
- [x] 1.2 Remplacer le padding vertical fixe (`vertical: 10`) par une valeur conditionnelle : `vertical: isLandscapeMobile ? 4 : 10` sur toutes les cellules concernées (Android uniquement)
- [x] 1.3 Vérifier visuellement en paysage Android : davantage de lignes visibles, contenu lisible, tap cible suffisant

## 2. Autocomplétion — direction d'ouverture en paysage Android

- [x] 2.1 Dans `bottle_edit_screen.dart`, calculer `isLandscapeMobile` au niveau du `build()` de l'écran (même pattern que `stock_screen.dart`) (Android uniquement)
- [x] 2.2 Passer `optionsViewOpenDirection: isLandscapeMobile ? OptionsViewOpenDirection.up : OptionsViewOpenDirection.down` au `RawAutocomplete` existant (Android uniquement)
- [x] 2.3 Dans `bulk_add_screen.dart`, calculer `isLandscapeMobile` au niveau du `build()` de l'écran (Android uniquement)
- [x] 2.4 Convertir `_AutocompleteField` (`bulk_add_screen.dart`) et `RepartitionRow` (`repartition_row.dart`) en `RawAutocomplete` avec overlay flottant + `optionsViewOpenDirection` (Android uniquement)
- [x] 2.5 Passer `openUp: isLandscapeMobile` à chaque appel `_AutocompleteField` dans `BulkAddScreen` (domaine, appellation, fournisseur) et `RepartitionRow` (emplacement) (Android uniquement)

## 3. Validation

- [x] 3.1 Tester table stock en paysage Android : densité correcte, scroll fluide, tap sur ligne fonctionnel
- [x] 3.2 Tester autocomplétion `BottleEditScreen` en paysage Android : suggestions visibles au-dessus du clavier
- [x] 3.3 Tester autocomplétion `BulkAddScreen` en paysage Android : suggestions visibles sur tous les champs (domaine, appellation, cru, contenance, fournisseur, emplacement)
- [x] 3.4 Vérifier que le comportement portrait et Windows/Linux est inchangé
