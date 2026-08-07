## 1. Validateur partagé

- [x] 1.1 Créer `lib/shared/emplacement_validator.dart` : classe `EmplacementValidator`, méthode statique `isValid(String value) → bool`, regex par-segment `^[a-zA-ZÀ-ÿ0-9][a-zA-ZÀ-ÿ0-9 _-]*$` (PC + Android, code partagé)
- [x] 1.2 Ajouter les tests unitaires du validateur (cas valides avec `_`/`-`, cas invalides : début non-alphanumérique, séparateur mal formé, niveau vide, chaîne vide) — fichier `test/shared/emplacement_validator_test.dart`

## 2. Migration des 5 points d'appel UI existants

- [x] 2.1 `lib/features/bottle_actions/widgets/deplacer_form.dart` : remplacer la regex locale (ligne 79) et `_validate` par un appel à `EmplacementValidator.isValid`, conserver `l10n.deplacerFormatError` (PC + Android)
- [x] 2.2 `lib/features/stock/widgets/deplacer_batch_sheet.dart` : idem (ligne 87), conserver `l10n.deplacerFormatError` (PC + Android)
- [x] 2.3 `lib/features/bottle_edit/bottle_edit_screen.dart` : idem (`_validateEmplacement`, lignes 167-178), conserver `l10n.deplacerFormatError` (PC + Android)
- [x] 2.4 `lib/features/bulk_add/bulk_add_controller.dart` : remplacer `_levelRe`/`_emplacementValide` (lignes 71-79) par `EmplacementValidator.isValid` (PC + Android)
- [x] 2.5 `lib/features/bulk_add/widgets/repartition_row.dart` : remplacer la regex locale (lignes 39-41) par `EmplacementValidator.isValid`, conserver `l10n.repartitionFormatError` (PC + Android)

## 3. Import CSV

- [x] 3.1 `lib/features/import_csv/csv_parser.dart::_rowToCompanion` : ajouter le check `EmplacementValidator.isValid` (uniquement si `emplacement` non vide), retour `(null, 'emplacement invalide : "$emplacement"')` sur échec — suit la convention existante (ligne rejetée seule, import non interrompu, `ParseError` avec raison explicite nommant le champ)
- [x] 3.2 Ajouter un test couvrant l'import d'une ligne CSV avec emplacement invalide (ligne ignorée, erreur nommant `emplacement`) et une ligne avec `_`/`-` maintenant acceptée — fichier `test/features/import_csv/csv_parser_test.dart` (chemin corrigé : le dossier `test/import_csv/` indiqué dans la tâche n'existe pas, la convention du projet est `test/features/<feature>/`)

## 4. Messages et documentation

- [x] 4.1 Mettre à jour `deplacerFormatError` et `repartitionFormatError` dans `lib/l10n/app_fr.arb` et `app_en.arb` pour mentionner underscore/tiret dans la liste des caractères acceptés (fichiers générés `app_localizations_*.dart` régénérés automatiquement via `generate: true`, pas édités à la main)
- [x] 4.2 Mettre à jour CLAUDE.md (section Data model, règle `emplacement`) pour lister `_` et `-` dans les caractères acceptés

## 5. Vérification

- [x] 5.1 `flutter analyze` → 0 issue
- [x] 5.2 `flutter test` → 0 échec (inclut les nouveaux tests 1.2 et 3.2) — 142 tests passés
- [x] 5.3 Vérifier manuellement (Windows) : déplacer une bouteille vers `Liebherr Vinothek > sortie_réfrigérateur ou habitat` réussit désormais sans erreur de format — confirmé OK

## 6. Correctifs post-review (avant archivage)

- [x] 6.1 `lib/shared/emplacement_validator.dart::isValid` : supprimer le `level.trim()` par segment (ligne 12), ne garder que le trim global de la valeur entière (ligne 9). Chaque segment issu du split doit matcher `_levelPattern` sans trim individuel (PC + Android)
- [x] 6.2 Ajouter des cas de test dans `test/shared/emplacement_validator_test.dart` : séparateur avec double espace (`"Cave >  Rack"`), tab, espace manquant d'un côté (`"Cave> Rack"`, `"Cave >Rack"`) — tous invalides
- [x] 6.3 `lib/shared/emplacement_validator.dart::_levelPattern` : exclure `×` (U+00D7) et `÷` (U+00F7) de la plage `À-ÿ` — implémenté via 3 sous-plages `À-ÖØ-öø-ÿ` (contourne les deux points de code non-lettres) plutôt qu'une négation, comportement identique
- [x] 6.4 Ajouter un cas de test : un niveau contenant `×` ou `÷` est invalide
- [x] 6.5 `lib/shared/emplacement_validator.dart` : exposer une constante `separator` (`' > '`)
- [x] 6.6 `lib/features/locations/location_node.dart` : remplacer les 5 occurrences du littéral `' > '` (lignes 70, 72, 83, 85, 94) par `EmplacementValidator.separator`
- [x] 6.7 Vérifier que les tests existants de `location_node` passent toujours sans modification (le comportement de split/join est inchangé, seule la source du littéral change)
- [x] 6.8 `flutter analyze` → 0 issue
- [x] 6.9 `flutter test` → 0 échec (inclut les nouveaux cas 6.2 et 6.4)
- [x] 6.10 Vérifier manuellement (Windows) : un emplacement avec double espace autour de `>` (ex. `"Cave >  Rack"`) est désormais rejeté avec le message de format habituel — confirmé OK

## 7. Correctifs post-review round 2 (import données exemple + test)

- [x] 7.1 `lib/features/import_csv/sample_data_service.dart::importSampleData` : construire `parseErrorDetails` depuis `parseResult.errors` (même format que `import_csv_screen.dart` : `'Ligne ${e.lineNumber} — ${e.reason} : ${e.rawLine}'`) et le passer à `importService.run` — les lignes rejetées (dont désormais celles à cause d'un emplacement invalide) remontent dans `ImportResult.errorDetails` au lieu de disparaître silencieusement
- [x] 7.2 `lib/l10n/app_fr.arb` + `app_en.arb` : ajouter `sampleDataImportedWithErrors` ({count}, {errors}) et `sampleDataErrorDetailsTitle`
- [x] 7.3 `lib/features/stock/stock_screen.dart::_importSampleData` : si `result.errors > 0`, afficher un SnackBar avec `sampleDataImportedWithErrors` + action "Voir le détail des erreurs" ouvrant une `AlertDialog` listant `result.errorDetails` (sinon, comportement inchangé : snackbar `sampleDataImported` simple)
- [x] 7.4 `test/features/import_csv/csv_parser_test.dart` : séparer le test « avec underscore et tiret → accepté » (qui ne testait que l'underscore) en deux tests distincts, le second avec un vrai tiret dans la valeur (`Cave-à-vin > Rangée-A`)
- [x] 7.5 `flutter analyze` → 0 issue
- [x] 7.6 `flutter test` → 0 échec — 149 tests passés
- [x] 7.7 Vérification (Windows) : rendu visuel non testé manuellement — vérifié par relecture de code uniquement. Détection (test automatisé existant) et transmission de l'erreur (pattern identique à `import_csv_screen.dart`, déjà fonctionnel) jugées suffisamment couvertes ; seul le rendu du nouveau snackbar/dialogue reste non exercé, jugé acceptable (`flutter analyze`/`test` verts, code linéaire simple)
- [x] 7.8 Vérifier que les CSV exemple actuels (`docs/sample/cavea_sample_fr.csv` et `cavea_sample_en.csv`, 70 lignes chacun) restent 100% conformes aux nouvelles règles de validation — vérifié par script, 0 ligne invalide dans les deux fichiers
- [x] 7.9 Extraire la liste défilante d'erreurs (monospace, `SelectionArea` + `ListView.builder`) dupliquée entre `_ResultCard` (`import_csv_screen.dart`) et le dialogue de `stock_screen.dart` dans un widget partagé `ImportErrorList` (`lib/features/import_csv/import_error_list.dart`) ; les deux écrans gardent leur propre conteneur (Card persistante avec zone rouge repliable vs Dialog transitoire) mais partagent le rendu de la liste elle-même
- [x] 7.10 `flutter analyze` → 0 issue
- [x] 7.11 `flutter test` → 0 échec
- [x] 7.12 Vérifier manuellement (Windows) : l'écran Import (`/data`) avec une ligne d'emplacement invalide affiche toujours correctement la liste d'erreurs repliable (non-régression du widget extrait) — confirmé OK

## 8. Correctifs post-review round 3 (cleanup ImportErrorList)

- [x] 8.1 `lib/features/import_csv/csv_parser.dart::ParseError` : ajouter le getter `displayMessage` (`'Ligne $lineNumber — $reason : $rawLine'`) pour éviter la duplication du formatage
- [x] 8.2 `lib/features/import_csv/sample_data_service.dart` et `lib/features/import_csv/import_csv_screen.dart` : utiliser `e.displayMessage` au lieu de reconstruire la chaîne localement
- [x] 8.3 `lib/features/stock/stock_screen.dart::_showSampleDataErrors` : borner `ImportErrorList` à `maxHeight: 300` (cohérent avec `_ResultCard`) via `ConstrainedBox`
- [x] 8.4 `flutter analyze` → 0 issue
- [x] 8.5 `flutter test` → 0 échec
