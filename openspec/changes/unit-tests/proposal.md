## Why

La V1 approche de sa fin et la couverture de tests est insuffisante : seules deux classes sont testées (`maturity_service` et les méthodes de base de `bouteille_dao`). Les couches logiques critiques — parsing CSV, import/export, contrôleurs Riverpod, arbre d'emplacements — ne sont couvertes par aucun test automatisé, exposant les regressions lors des futurs changements.

## What Changes

- Ajout de tests d'intégration drift in-memory pour les méthodes `bouteille_dao` non couvertes
- Ajout de tests unitaires purs pour `csv_parser`, `location_node`, `BulkAddState`/`BulkAddNotifier`, `StockFilterController`
- Ajout de tests d'intégration in-memory pour `import_service`
- Ajout de tests unitaires pour `csv_export_service` via un stub `AppLocalizations`
- Ajout de widget-tests pour `locale_formatting` (nécessite un BuildContext localisé) et `locationStatsLabel`

## Capabilities

### New Capabilities
- `unit-tests`: Couverture complète des couches logiques non-UI — DAO (méthodes batch, streams, requêtes distinct), parsing/import/export CSV, contrôleurs Riverpod (BulkAdd, StockFilter), arbre d'emplacements, formatage localisé.

### Modified Capabilities
<!-- Aucune exigence fonctionnelle ne change — ajout de tests uniquement -->

## Impact

- Nouveaux fichiers uniquement dans `test/` — aucune modification du code de production
- Dépendances de test déjà présentes : `flutter_test`, `drift` (AppDatabase.memory()), `flutter_riverpod` (ProviderContainer)
- `csv_export_service` nécessite un stub `FakeAppLocalizations` dans les tests (AppLocalizations n'est pas mockable directement)
- `locale_formatting` et `locationStatsLabel` nécessitent un widget de test avec locale injectée

## Non-goals

- Tests widget UI (écrans, formulaires, navigation) — hors périmètre de cette PR
- Tests de `SyncService`, `DriveStorageAdapter`, `DropboxStorageAdapter` — dépendent de HTTP/OAuth, reportés
- Tests `config_service` — dépend de `SharedPreferences`, hors périmètre V1
- Couverture 100% — objectif : couvrir tous les chemins de décision métier critiques
