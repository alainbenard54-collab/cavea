## Context

L'application est actuellement 100 % en français : strings hardcodés dans les fichiers `.dart`, aucune infrastructure de traduction. Deux langues cibles : français (fr) et anglais (en). L'`intl` package n'est pas encore déclaré dans `pubspec.yaml`.

Structure actuelle pertinente :
- `lib/core/config_service.dart` — SharedPreferences, listes de référence builtin, defaults bulk-add
- `lib/features/settings/settings_screen.dart` — écran Paramètres, sections couleur/contenance/sync
- `lib/features/export_csv/csv_export_service.dart` — construction du CSV, headers hardcodés en français
- `lib/main.dart` — `MaterialApp`, thème, router

## Goals / Non-Goals

**Goals:**
- Infrastructure ARB complète avec génération de code Flutter (`flutter gen-l10n`)
- Tous les strings statiques UI extractés et traduits fr + en
- Sélecteur de langue dans Paramètres, préférence persistée dans `ConfigService`
- `MaterialApp.locale` piloté dynamiquement (Riverpod provider)
- Formats date/nombre adaptés à la locale (`intl`)
- En-têtes CSV traduits selon locale active
- Mapping libellés couleurs builtin (fr↔en) dans `ConfigService`
- Pluriels corrects via règles ARB

**Non-Goals:**
- Traduction des données utilisateur (domaine, appellation, commentaires)
- Traduction des appellations CRU
- Messages d'erreur bruts Google OAuth (non interceptés)
- Troisième langue
- RTL layout

## Decisions

### D1 — flutter gen-l10n (code generation) plutôt que lookup manuel

`flutter gen-l10n` génère `AppLocalizations` (classe typesafe) depuis les ARB. Accès via `AppLocalizations.of(context)` ou une extension `BuildContext.l10n` (barrel `lib/l10n/l10n.dart`).

Alternative écartée : table de lookup `Map<String, Map<String, String>>` — fragile, non typesafe, pas de support pluriels.

Configuration dans `pubspec.yaml` :
```yaml
flutter:
  generate: true
  # lib/l10n/l10n.yaml lu automatiquement
```
Fichier `lib/l10n/l10n.yaml` :
```yaml
arb-dir: lib/l10n
template-arb-file: app_fr.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
preferred-supported-locales: [fr]
nullable-getter: false
```

Le fichier template est `app_fr.arb` (référence). `app_en.arb` contient uniquement les clés qui diffèrent ou toutes les clés (même valeur acceptée si identique).

### D2 — Locale provider Riverpod

Un `localeProvider` (StateProvider ou NotifierProvider) lit la préférence depuis `ConfigService` au démarrage et expose une `Locale?` (null = délégation OS). `MaterialApp` dans `main.dart` est un `ConsumerWidget` qui watch ce provider.

```dart
// lib/core/locale_provider.dart
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>(...);
```

`LocaleNotifier` persiste via `ConfigService.saveLocalePreference(String? code)` (null = Automatique, 'fr', 'en').

Fallback : si la locale OS n'est pas dans `supportedLocales`, Flutter revient automatiquement au premier élément déclaré — on déclare `[Locale('fr'), Locale('en')]`, donc fallback = français.

### D3 — Mapping couleurs builtin dans ConfigService

Les clés stockées en DB (ex. `"Rouge"`) sont invariantes. `ConfigService` expose :
```dart
static const Map<String, Map<String, String>> _couleurLabels = {
  'Rouge':              {'fr': 'Rouge',              'en': 'Red'},
  'Blanc':              {'fr': 'Blanc',              'en': 'White'},
  'Blanc effervescent': {'fr': 'Blanc effervescent', 'en': 'Sparkling white'},
  'Blanc liquoreux':    {'fr': 'Blanc liquoreux',    'en': 'Sweet white'},
  'Blanc moelleux':     {'fr': 'Blanc moelleux',     'en': 'Semi-sweet white'},
  'Rosé':               {'fr': 'Rosé',               'en': 'Rosé'},
  'Rosé effervescent':  {'fr': 'Rosé effervescent',  'en': 'Sparkling rosé'},
};

static String displayCouleur(String dbKey, Locale locale) =>
    _couleurLabels[dbKey]?[locale.languageCode] ?? dbKey;
```

Les valeurs user-custom (non présentes dans la map) sont retournées telles quelles.

### D4 — Formats date et nombre via intl

`DateFormat` et `NumberFormat` du package `intl`. Helpers dans `lib/core/locale_formatting.dart` :
```dart
String formatDate(DateTime d, Locale locale)   → DateFormat.yMd(locale.toString()).format(d)
String formatNumber(double n, Locale locale)   → NumberFormat.decimalPattern(locale.toString()).format(n)
String formatCurrency(double n, Locale locale) → NumberFormat.currency(locale: locale.toString(), symbol: '€').format(n)
```

Ces helpers remplacent les appels `DateFormat`/`toStringAsFixed` actuellement hardcodés dans les widgets stock, historique, fiche bouteille.

### D5 — En-têtes CSV localisés

`CsvExportService.buildCsv(List<Bouteille>, {required String separator, required AppLocalizations l10n})` reçoit `l10n` en paramètre. Les headers sont des clés ARB (`l10n.csvHeaderDomaine`, etc.). L'appelant (`ExportCsvScreen`) passe `context.l10n`.

Pas d'impact sur les données exportées (valeurs DB brutes inchangées).

### D6 — Politique de confidentialité

Deux fichiers Markdown dans le repo : `docs/privacy/fr.md` et `docs/privacy/en.md`. L'URL dans `AboutDialog` est construite dynamiquement :
```dart
final lang = Localizations.localeOf(context).languageCode;
final privacyUrl = 'https://github.com/<org>/<repo>/blob/main/docs/privacy/$lang.md';
```
Fallback : si `lang` n'est ni `fr` ni `en`, pointer sur `fr.md`.

### D7 — Extension BuildContext.l10n

Barrel `lib/l10n/l10n.dart` :
```dart
import 'package:flutter/widgets.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
```

Usage dans les widgets : `context.l10n.stockTitle` (pas d'import répété de `AppLocalizations`).

## Risks / Trade-offs

**[Volume d'extraction]** Des centaines de strings sont hardcodés dans ~30 fichiers Dart → risque d'oubli ou de régression visuelle.
→ Mitigation : extraction systématique fichier par fichier dans les tasks, revue manuelle de l'UI après extraction.

**[Strings dynamiques]** Certains messages combinent des variables (`"$n bouteille(s) sélectionnée(s)"`). Les règles ARB plurielles sont plus verbeuses.
→ Mitigation : identifier tous les patterns `count` dès la phase d'extraction et les écrire en ARB plural dès le départ.

**[Traduction manuelle]** Les traductions anglaises sont écrites à la main — risque de fautes ou de maladresses.
→ Mitigation : l'anglais est simple et fonctionnel (pas de marketing) ; une passe de relecture suffit avant release.

**[Rechargement dynamique de la locale]** Changer la langue en cours de session requiert que tous les widgets rebuildent. Riverpod watch sur `localeProvider` garantit le rebuild du sous-arbre `MaterialApp`, mais certains strings interpolés hors widget tree (ex. snackbar déclenchée depuis un service) nécessitent de passer `l10n` en paramètre.
→ Mitigation : services qui affichent des messages (SyncService, CsvExportService) reçoivent `AppLocalizations` en paramètre d'appel, jamais en champ d'instance.

**[Strings Drive/OAuth non contrôlés]** Les messages d'erreur bruts de `googleapis` sont en anglais — accepté par décision produit.
→ Pas de mitigation nécessaire.

## Migration Plan

1. Ajouter `intl` dans `pubspec.yaml` + configurer `flutter gen-l10n` (`l10n.yaml`).
2. Créer `app_fr.arb` avec toutes les clés (extraction complète).
3. Créer `app_en.arb` (traduction de toutes les clés).
4. Générer `AppLocalizations` (`flutter pub get` suffit avec `generate: true`).
5. Remplacer les strings hardcodés fichier par fichier.
6. Ajouter `localeProvider` + modifier `MaterialApp` dans `main.dart`.
7. Ajouter le sélecteur langue dans `settings_screen.dart`.
8. Ajouter `locale_formatting.dart`, remplacer les formats date/nombre.
9. Ajouter `displayCouleur` dans `ConfigService`, l'appeler partout où une couleur DB est affichée.
10. Passer `l10n` à `CsvExportService.buildCsv()`, traduire les headers.
11. Créer `docs/privacy/fr.md` + `docs/privacy/en.md`, mettre à jour l'URL dans `AboutDialog`.
12. Tests manuels : basculer fr↔en dans Paramètres, vérifier tous les écrans + export CSV.

Rollback : les strings sont remplacés symboliquement — en cas de régression, `git revert` sur les fichiers impactés sans impact DB.

## Open Questions

_Aucune — toutes les décisions ont été arrêtées avant la rédaction de ce document._
