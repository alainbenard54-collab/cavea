## Context

`maturity_service.dart` est un ensemble de fonctions pures (aucune dépendance externe) — il est testable directement sans infrastructure. `bouteille_dao.dart` encapsule toutes les requêtes drift ; il nécessite une instance `AppDatabase` pour s'exécuter.

Aucun test n'existe aujourd'hui. La V1 va modifier et enrichir ces deux modules (édition bouteille, filtres avancés, historique). Sans filet de test, toute régression sur la maturité ou le filtrage est silencieuse.

## Goals / Non-Goals

**Goals:**
- Couvrir les règles métier critiques de `computeMaturity`, `urgencyScore` et `maturitySortOrder`
- Couvrir les opérations CRUD et de filtrage de `BouteilleDao` via une DB in-memory
- Établir la structure `test/` qui servira de base pour les tests V1 futurs

**Non-Goals:**
- Tester les widgets Flutter (pas de `testWidgets`)
- Tester `SyncService` ou `DriveStorageAdapter` (dépendances réseau, hors scope)
- Tester les providers Riverpod
- Atteindre 100% de couverture — seule la logique métier non triviale est couverte
- Configurer la CI (pas de pipeline CI sur ce projet)

## Decisions

**1. Tests unitaires purs pour `maturity_service.dart`**
Les trois fonctions (`computeMaturity`, `urgencyScore`, `maturitySortOrder`) sont pures : même entrée → même sortie, aucun effet de bord. On appelle directement les fonctions avec `expect()`. Pas de mock, pas de fixture.
*Alternative écartée* : mocker `DateTime.now()` via injection — inutile car les fonctions acceptent déjà un paramètre `annee` optionnel qui sert précisément à fixer l'année dans les tests.

**2. DB drift in-memory pour `BouteilleDao`**
`NativeDatabase.memory()` crée une instance SQLite en RAM, isolée par test. On instancie un vrai `AppDatabase` + un vrai `BouteilleDao` — pas de mock du DAO. Chaque test dispose d'une base propre créée dans `setUp()` et fermée dans `tearDown()`.
*Alternative écartée* : mocker `AppDatabase` — cela testerait les mocks, pas le code réel. Drift dispose d'une DB in-memory précisément pour ce cas d'usage.

**3. Streams drift testés via `.first` / `StreamQueue`**
`watchStock` et `watchStockFiltered` retournent des `Stream`. On utilise `await stream.first` pour les assertions simples. Si plusieurs émissions sont nécessaires, `StreamQueue` (package `async` déjà transitif) est utilisé.

**4. Pas de dépendance supplémentaire**
`flutter_test` (déjà présent) et `drift` (déjà en `dependencies`) suffisent. `NativeDatabase.memory()` est dans le package `drift` core. Aucun ajout à `pubspec.yaml` n'est nécessaire.

## Risks / Trade-offs

- **Streams et timing** → `await stream.first` peut bloquer si la DB n'émet rien. Mitigation : s'assurer que chaque test insère des données avant d'appeler `watch*`.
- **Isolation entre tests** → si `tearDown` ne ferme pas la DB, des ressources peuvent fuir. Mitigation : `await db.close()` systématique dans `tearDown`.
- **Dépendance à l'année courante dans `maturitySortOrder`** → N/A car on passe `annee` explicitement dans tous les tests de maturité.
