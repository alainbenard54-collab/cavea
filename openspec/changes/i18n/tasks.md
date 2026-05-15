## 1. Infrastructure ARB et génération de code (PC + Android)

- [x] 1.1 Ajouter `intl` dans `pubspec.yaml` (dépendance) et `flutter: generate: true`
- [x] 1.2 Créer `lib/l10n/l10n.yaml` avec `arb-dir`, `template-arb-file: app_fr.arb`, `output-class: AppLocalizations`, `nullable-getter: false`
- [x] 1.3 Créer `lib/l10n/l10n.dart` : export `app_localizations.dart` + extension `BuildContext.l10n`
- [x] 1.4 Créer `lib/l10n/app_fr.arb` avec toutes les clés (strings extraits, voir tâches 3 à 9)
- [x] 1.5 Créer `lib/l10n/app_en.arb` avec la traduction anglaise de chaque clé
- [x] 1.6 Vérifier que `flutter pub get` génère `app_localizations.dart` sans erreur

## 2. Configuration MaterialApp et LocaleProvider (PC + Android)

- [x] 2.1 Créer `lib/core/locale_provider.dart` : `LocaleNotifier` (StateNotifier<Locale?>) lisant `ConfigService.getLocalePreference()` + méthode `setLocale(String? code)`
- [x] 2.2 Ajouter `saveLocalePreference(String? code)` et `getLocalePreference()` dans `lib/core/config_service.dart` (clé SharedPreferences `locale_preference`)
- [x] 2.3 Modifier `lib/main.dart` : `MaterialApp` devient `ConsumerWidget`, ajoute `localizationsDelegates`, `supportedLocales`, `locale: ref.watch(localeProvider)`
- [x] 2.4 Tester : basculer fr↔en dans Paramètres → l'app rebuidle immédiatement dans la bonne langue

## 3. Sélecteur de langue dans Paramètres (PC + Android)

- [x] 3.1 Ajouter une section "Langue" dans `lib/features/settings/settings_screen.dart` avec un `SegmentedButton` (Automatique / Français / English)
- [x] 3.2 Brancher le `SegmentedButton` sur `localeProvider` : sélection → `ref.read(localeProvider.notifier).setLocale(code)` → persistance via `ConfigService`
- [x] 3.3 Tester la persistance après redémarrage de l'app

## 4. Helpers de formatage date et nombre (PC + Android)

- [x] 4.1 Créer `lib/core/locale_formatting.dart` : `formatDate(DateTime, BuildContext)`, `formatDateFromString(String?, BuildContext)`, `formatNumber(double, BuildContext)`, `formatCurrency(double?, BuildContext)` via `intl`
- [x] 4.2 Remplacer les formats date hardcodés dans `lib/features/stock/` par `formatDate()`
- [x] 4.3 Remplacer les formats date hardcodés dans `lib/features/history/` par `formatDate()`
- [x] 4.4 Remplacer les formats date hardcodés dans `lib/features/bottle_detail/` et `bottle_edit/` par `formatDate()`
- [x] 4.5 Remplacer les formats nombre/prix hardcodés (toStringAsFixed, etc.) par `formatNumber()` / `formatCurrency()` dans tous les écrans
- [ ] 4.6 Tester : basculer fr↔en → dates et prix s'affichent avec le bon séparateur décimal

## 5. Mapping couleurs builtin (PC + Android)

- [x] 5.1 Ajouter `_couleurLabels` (map statique fr/en) et `displayCouleur(String dbKey, Locale locale)` dans `lib/core/config_service.dart`
- [x] 5.2 Remplacer l'affichage brut de `bouteille.couleur` dans `lib/features/stock/` par `ConfigService.displayCouleur()`
- [x] 5.3 Remplacer l'affichage brut de `couleur` dans `lib/features/bottle_detail/`, `bottle_edit/`, `history/`, `locations/`
- [x] 5.4 Remplacer les libellés du dropdown couleur dans `bulk_add/` et `bottle_edit/` par `displayCouleur()` (valeur soumise = clé DB française)
- [x] 5.5 Remplacer les chips de filtre couleur dans `lib/features/stock/` par `displayCouleur()`
- [ ] 5.6 Tester : locale en → les couleurs affichent "Red", "White", etc. ; les valeurs en base restent en français

## 6. Extraction des strings — écran Stock et filtres (PC + Android)

- [x] 6.1 Extraire tous les strings hardcodés de `lib/features/stock/stock_screen.dart` vers ARB (`stockTitle`, filtres, labels tri, messages vide…)
- [x] 6.2 Extraire les strings de `lib/features/stock/widgets/` (BulkActionBar, DeplacerBatchSheet, ConsommerBatchSheet, etc.)
- [x] 6.3 Ajouter les clés pluriel pour les compteurs de bouteilles sélectionnées (`{count, plural, one{1 bouteille sélectionnée} other{{count} bouteilles sélectionnées}}`)

## 7. Extraction des strings — formulaires ajout et édition (PC + Android)

- [x] 7.1 Extraire tous les strings de `lib/features/bulk_add/bulk_add_screen.dart` vers ARB
- [x] 7.2 Extraire tous les strings de `lib/features/bottle_edit/bottle_edit_screen.dart` vers ARB
- [x] 7.3 Extraire tous les strings de `lib/features/bottle_detail/bottle_detail_screen.dart` vers ARB
- [x] 7.4 Extraire les strings des BottomSheets `lib/features/bottle_actions/` vers ARB

## 8. Extraction des strings — Emplacements, Historique, Import/Export (PC + Android)

- [x] 8.1 Extraire tous les strings de `lib/features/locations/` vers ARB
- [x] 8.2 Extraire tous les strings de `lib/features/history/` vers ARB
- [x] 8.3 Extraire tous les strings de `lib/features/export_csv/` vers ARB
- [x] 8.4 Extraire tous les strings de `lib/features/import_csv/` vers ARB

## 9. Extraction des strings — Paramètres, Setup, Navigation, AboutDialog (PC + Android)

- [x] 9.1 Extraire tous les strings de `lib/features/settings/settings_screen.dart` vers ARB
- [x] 9.2 Extraire tous les strings de `lib/features/setup/` (wizard premier lancement) vers ARB
- [x] 9.3 Extraire les libellés de navigation (`lib/shared/adaptive_layout.dart`) : onglets Stock, Ajouter, Emplacements, Historique, Données, Paramètres
- [x] 9.4 Extraire et traduire le contenu de l'`AboutDialog` (titre, version, description, lien licences)

## 10. En-têtes CSV traduits (PC + Android)

- [x] 10.1 Ajouter 20 clés ARB `csvHeader*` dans `app_fr.arb` + `app_en.arb` (une par colonne exportée)
- [x] 10.2 Modifier la signature de `CsvExportService.buildCsv()` pour accepter `AppLocalizations l10n`
- [x] 10.3 Remplacer les headers hardcodés français dans `buildCsv()` par les clés `l10n.csvHeader*`
- [x] 10.4 Passer `context.l10n` depuis `ExportCsvScreen` à `buildCsv()`
- [ ] 10.5 Tester : exporter en fr → headers en français ; basculer en anglais et exporter → headers en anglais

## 11. Politique de confidentialité bilingue (PC + Android)

- [ ] 11.1 Créer `docs/privacy/fr.md` (politique de confidentialité en français)
- [ ] 11.2 Créer `docs/privacy/en.md` (politique de confidentialité en anglais)
- [ ] 11.3 Modifier le lien dans `AboutDialog` : URL dynamique `docs/privacy/{locale.languageCode}.md` sur GitHub, fallback `fr` si langue non couverte

## 12. Tests manuels de bout en bout (PC + Android)

- [ ] 12.1 Tester tous les écrans en français : aucun string manquant, formats date/nombre corrects
- [ ] 12.2 Tester tous les écrans en anglais : aucun string manquant, formats date/nombre corrects
- [ ] 12.3 Tester le basculement fr↔en en cours de session : rebuild immédiat, pas de crash
- [ ] 12.4 Tester la persistance de la langue après redémarrage (fr, en, automatique)
- [ ] 12.5 Tester l'export CSV en fr et en anglais : vérifier les en-têtes de colonnes
- [ ] 12.6 Tester sur Android : mêmes vérifications qu'en 12.1 à 12.5
