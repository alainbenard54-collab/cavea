## Why

Le MVP est livré sans aucun test automatisé. `maturity_service.dart` et `bouteille_dao.dart` contiennent la logique métier centrale (calcul de maturité, filtres stock, CRUD) et peuvent régresser silencieusement lors des développements V1 à venir.

## What Changes

- Création du dossier `test/` avec deux suites de tests indépendantes.
- Tests unitaires purs pour `maturity_service.dart` : pas de dépendance externe, couvre `computeMaturity`, `urgencyScore` et `maturitySortOrder`.
- Tests d'intégration drift in-memory pour `bouteille_dao.dart` : base SQLite en mémoire, couvre watchStock, watchStockFiltered, insertBouteille(s), deplacerBouteille, consommerBouteille, et les requêtes `getDistinct*`.
- Ajout des dépendances de test nécessaires dans `pubspec.yaml` si absentes (`flutter_test` est déjà inclus avec Flutter).

## Capabilities

### New Capabilities

- `maturity-unit-tests` : tests unitaires purs sur les trois fonctions de `maturity_service.dart` — tous les cas limites de `computeMaturity` (sansDonnee, tropJeune, optimal, aBoireUrgent), valeurs d'`urgencyScore` par niveau, ordre de `maturitySortOrder`.
- `dao-integration-tests` : tests d'intégration drift (DB SQLite in-memory) sur `BouteilleDao` — watchStock exclut les consommées, watchStockFiltered avec couleurs/appellation/millésime/texte, deplacerBouteille ne touche pas dateSortie, consommerBouteille avec et sans note/commentaire, insertBouteilles en transaction, getDistinct* retournent les valeurs attendues.

### Modified Capabilities

*(aucune — aucune exigence existante ne change)*

## Impact

- Nouveau dossier : `test/core/maturity/maturity_service_test.dart`
- Nouveau dossier : `test/data/daos/bouteille_dao_test.dart`
- `pubspec.yaml` : vérification que `drift` est disponible dans `dev_dependencies` pour la DB in-memory (`NativeDatabase.memory()`)
- Aucun impact sur le code de production, aucun impact sur les modes 1/2/3
- Pas de CI configuré — les tests sont lancés localement via `flutter test`
