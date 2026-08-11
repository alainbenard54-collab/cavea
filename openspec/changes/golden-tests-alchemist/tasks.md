## 1. Dépendance et harnais de test

- [x] 1.1 (PC) Ajouter `alchemist` en dev_dependency dans `pubspec.yaml`, exécuter `flutter pub get`
- [x] 1.2 (PC) Créer le dossier `test/golden/` avec un sous-dossier par écran couvert (`stock/`, `emplacements/`, `bottle_detail/`, `bulk_add/`)
- [x] 1.3 (PC) Créer un harnais de test partagé (ex. `test/golden/golden_harness.dart`) : wrapper `MaterialApp` + `ProviderScope`, délégués de localisation réels (`AppLocalizations.localizationsDelegates`/`supportedLocales`), locale fixe `fr`, thème Material 3 de l'app
- [x] 1.4 (PC) Vérifier sur un widget simple que Alchemist charge bien les polices réelles (pas de fallback Ahem) avant de couvrir les 4 écrans

## 2. Golden test — Stock

- [x] 2.1 (PC) Construire un jeu de données Riverpod statique représentatif (bouteilles couvrant les 4 niveaux de maturité — tropJeune/optimal/aBoireUrgent/sansDonnee — et plusieurs couleurs)
- [x] 2.2 (PC) Écrire le golden test pour `StockTable` (`lib/features/stock/stock_table.dart`, vue desktop ≥640px) avec ce jeu de données
- [x] 2.3 (PC) Écrire le golden test pour la vue liste mobile de `stock_screen.dart` (<640px)
- [x] 2.4 (PC) Générer les références initiales (`flutter test --update-goldens`) et les committer sous `test/golden/stock/`

## 3. Golden test — Emplacements

- [ ] 3.1 (PC) Construire un jeu de données d'arbre d'emplacements représentatif (mix nœuds + bouteilles directes, ≥2 niveaux de hiérarchie)
- [ ] 3.2 (PC) Écrire le golden test pour `LocationTreeScreen` (`lib/features/locations/location_tree_screen.dart`, vue table ≥640px et vue liste <640px)
- [ ] 3.3 (PC) Générer les références initiales et les committer sous `test/golden/emplacements/`

## 4. Golden test — Fiche bouteille + BottomSheet actions

- [ ] 4.1 (PC) Construire une bouteille de test fixe en stock, et une variante consommée (pour couvrir la section Consommation de la fiche)
- [ ] 4.2 (PC) Écrire le golden test pour `BottleDetailScreen` (`lib/features/bottle_detail/bottle_detail_screen.dart`) — bouteille en stock, puis consommée
- [ ] 4.3 (PC) Écrire le golden test pour `BottleActionsSheet` (`lib/features/bottle_actions/bottle_actions_sheet.dart`, mode normal)
- [ ] 4.4 (PC) Générer les références initiales et les committer sous `test/golden/bottle_detail/`

## 5. Golden test — Formulaire bulk-add

- [ ] 5.1 (PC) Écrire le golden test pour `BulkAddScreen` (`lib/features/bulk_add/bulk_add_screen.dart`) dans son état initial (avant saisie)
- [ ] 5.2 (PC) Générer la référence initiale et la committer sous `test/golden/bulk_add/`

## 6. Vérification et documentation

- [ ] 6.1 (PC) Exécuter `flutter test` (suite complète) et confirmer que les 4 groupes de golden tests passent, sans régression sur les tests existants
- [ ] 6.2 (PC) Introduire volontairement une régression visuelle (ex. changer une couleur de maturité) sur un écran couvert, confirmer que le golden test correspondant échoue avec un diff exploitable, puis annuler le changement
- [ ] 6.3 (PC) Documenter dans `ARCHITECTURE.md` la commande de régénération (`flutter test --update-goldens` sous Windows) et la structure `test/golden/<écran>/`
- [ ] 6.4 (PC) `flutter analyze` → 0 issue
