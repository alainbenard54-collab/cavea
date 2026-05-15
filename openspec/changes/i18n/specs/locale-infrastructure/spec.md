## ADDED Requirements

### Requirement: Infrastructure ARB avec génération de code
L'application SHALL utiliser `flutter_localizations` et `intl` pour l'internationalisation. Un fichier `lib/l10n/l10n.yaml` SHALL configurer la génération de code avec `app_fr.arb` comme template, classe générée `AppLocalizations`, `nullable-getter: false`. Un barrel `lib/l10n/l10n.dart` SHALL exporter `AppLocalizations` et exposer une extension `BuildContext.l10n` pour un accès court (`context.l10n.clé`).

#### Scenario: Génération de code réussie
- **WHEN** le développeur exécute `flutter pub get` avec `generate: true` dans `pubspec.yaml`
- **THEN** le fichier `lib/l10n/app_localizations.dart` (et ses parties) est généré dans `.dart_tool/flutter_gen/gen_l10n/`

#### Scenario: Extension BuildContext.l10n disponible
- **WHEN** un widget importe `lib/l10n/l10n.dart`
- **THEN** il peut appeler `context.l10n.nomDeLaCle` sans importer `AppLocalizations` directement

---

### Requirement: Fichiers ARB fr et en complets
Deux fichiers ARB SHALL couvrir l'intégralité des strings statiques affichés dans l'UI : `lib/l10n/app_fr.arb` (template — clés + traductions françaises) et `lib/l10n/app_en.arb` (traductions anglaises). Chaque clé présente dans `app_fr.arb` SHALL avoir une entrée correspondante dans `app_en.arb`. Les clés SHALL utiliser le camelCase (`stockTitle`, `addBottleLabel`, `syncErrorMessage`…).

#### Scenario: Clé manquante détectée à la compilation
- **WHEN** une clé est présente dans `app_fr.arb` mais absente de `app_en.arb`
- **THEN** `flutter pub get` / `flutter build` émet une erreur ou un avertissement (comportement flutter gen-l10n)

#### Scenario: Chaîne avec paramètre
- **WHEN** un string contient une variable (ex. `"$count bouteille(s) sélectionnée(s)"`)
- **THEN** la clé ARB utilise un placeholder : `"{count} bouteilles sélectionnées"` avec `{count}` déclaré dans les métadonnées

---

### Requirement: Pluriels corrects via règles ARB
Les strings contenant un compteur de bouteilles, d'éléments sélectionnés ou d'emplacements SHALL utiliser la syntaxe ARB plural (`{count, plural, one{} other{}}`) pour produire des formes correctes en français et en anglais.

#### Scenario: Singulier français
- **WHEN** `count = 1` et la locale est `fr`
- **THEN** l'UI affiche "1 bouteille sélectionnée" (sans "s")

#### Scenario: Pluriel anglais
- **WHEN** `count = 2` et la locale est `en`
- **THEN** l'UI affiche "2 bottles selected"

---

### Requirement: MaterialApp configuré avec les delegates de localisation
`MaterialApp` dans `lib/main.dart` SHALL déclarer `localizationsDelegates` (incluant `AppLocalizations.delegate`, `GlobalMaterialLocalizations.delegate`, `GlobalWidgetsLocalizations.delegate`, `GlobalCupertinoLocalizations.delegate`) et `supportedLocales` (`[Locale('fr'), Locale('en')]`). La locale effective SHALL être pilotée par `localeProvider` (voir spec `locale-settings`).

#### Scenario: App en français au démarrage avec locale OS française
- **WHEN** la locale OS est `fr-FR` et la préférence est "Automatique"
- **THEN** tous les strings affichés sont en français

#### Scenario: App en anglais au démarrage avec locale OS anglaise
- **WHEN** la locale OS est `en-US` et la préférence est "Automatique"
- **THEN** tous les strings affichés sont en anglais

#### Scenario: Fallback si locale OS non supportée
- **WHEN** la locale OS est `de-DE` et la préférence est "Automatique"
- **THEN** l'app se replie sur le français (premier élément de `supportedLocales`)

---

### Requirement: Aucun string statique hardcodé dans les fichiers Dart
Après extraction, aucun fichier `.dart` dans `lib/` SHALL contenir de string destiné à l'affichage utilisateur en dehors des clés ARB. Sont exemptés : les chaînes techniques (noms de routes, clés SharedPreferences, noms de fichiers, identifiants OAuth), les strings passés à des logs, et les valeurs DB (qui restent en français invariant).

#### Scenario: Libellé d'onglet traduit
- **WHEN** la locale est `en`
- **THEN** l'onglet Stock affiche "Stock", l'onglet Paramètres affiche "Settings", l'onglet Données affiche "Data"

#### Scenario: Message snackbar traduit
- **WHEN** une action déclenche un message snackbar (ex. "Mode lecture seule — modifications indisponibles")
- **THEN** le message est affiché dans la langue active de l'app
