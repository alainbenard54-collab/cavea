## Context

Le projet dispose de 2 fichiers de tests couvrant `maturity_service` (complet) et les méthodes de base de `bouteille_dao` (watchStock, watchStockFiltered, insert, déplacer/consommer unitaires, getDistinct pour couleurs et emplacements). Toutes les autres couches logiques sont non couvertes.

Les patterns techniques disponibles sont déjà établis dans le projet :
- `AppDatabase.memory()` pour drift in-memory (utilisé dans `bouteille_dao_test.dart`)
- `flutter_test` disponible dans `pubspec.yaml`
- `flutter_riverpod` disponible pour `ProviderContainer`

## Goals / Non-Goals

**Goals :** Couvrir tous les chemins de décision métier dans les 7 couches cibles. Chaque test doit être indépendant, répétable, sans I/O réseau ou fichier.

**Non-Goals :** Tests widget, tests d'intégration UI, tests SyncService/StorageAdapter (nécessitent HTTP mock ou OAuth réel).

## Decisions

### D1 — drift in-memory pour tous les tests DAO et service

`AppDatabase.memory()` crée une DB SQLite en RAM, propre à chaque `setUp`. Pas d'alternative : les mocks DAO ne valident pas les vraies requêtes SQL (comme le prouve l'incident cité dans les feedback memories).

### D2 — ProviderContainer pour les contrôleurs Riverpod

`ProviderContainer` sans `WidgetRef` permet de tester `StockFilterController` et `BulkAddNotifier` en Dart pur, sans `pumpWidget`. Les providers `autoDispose` nécessitent `container.listen(provider, (_, __) {})` pour rester vivants pendant le test.

### D3 — FakeAppLocalizations pour csv_export_service

`CsvExportService.buildCsv` prend `AppLocalizations l10n` en paramètre. Créer `test/helpers/fake_app_localizations.dart` avec les 20 champs CSV retournant leurs clés (`'id'`, `'domaine'`, etc.) en anglais. Alternative (wrapper widget + `pumpWidget`) rejetée : trop lourd pour tester une fonction pure de formatage.

### D4 — Widget test wrapper pour locale_formatting et locationStatsLabel

`formatDate`, `formatCurrency` et `locationStatsLabel` dépendent de `BuildContext` pour la locale. Pattern : `tester.pumpWidget(Localizations(locale: Locale('fr'), delegates: [...], child: Builder(builder: (ctx) { result = fn(ctx); return const SizedBox(); })))`. Groupe séparé par locale (fr, en).

### D5 — configService.contenanceDefaut dans BulkAddNotifier

`BulkAddNotifier()` lit `configService.contenanceDefaut` (singleton global) dans son constructeur. Sans initialisation de SharedPreferences, la valeur retourne `'75 cl'` par défaut. Pas de mock nécessaire — comportement accepté en test.

### D6 — Organisation des fichiers de tests

```
test/
  data/
    daos/
      bouteille_dao_test.dart          (existant — à compléter)
  features/
    import_csv/
      csv_parser_test.dart             (nouveau)
      import_service_test.dart         (nouveau)
    export_csv/
      csv_export_service_test.dart     (nouveau)
    bulk_add/
      bulk_add_controller_test.dart    (nouveau)
    locations/
      location_node_test.dart          (nouveau)
    stock/
      stock_controller_test.dart       (nouveau)
  core/
    locale_formatting_test.dart        (nouveau)
    maturity/
      maturity_service_test.dart       (existant — complet)
  helpers/
    fake_app_localizations.dart        (nouveau)
```

## Risks / Trade-offs

- [Fragile sur i18n] Les tests `locale_formatting` dépendent du format exact des `intl` patterns pour `fr` et `en` — si `intl` change, les valeurs attendues changent. Mitigation : vérifier le format avec `DateFormat.yMd('fr').format(...)` au lieu de coder des strings en dur.
- [BulkAddNotifier global] Si `configService` est initialisé avec une valeur non-défaut, les tests peuvent être affectés par l'ordre d'exécution. Acceptable pour V1.
- [watchLocationStats SQL custom] La requête est en SQL brut — le test in-memory valide son comportement exact et constitue la protection de régression principale.

## Migration Plan

Ajout de fichiers dans `test/` uniquement. Aucune modification du code de production. Exécution : `flutter test`.

## Open Questions

Aucune.
