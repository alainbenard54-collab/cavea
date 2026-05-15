## ADDED Requirements

### Requirement: Sélecteur de langue dans l'écran Paramètres
L'écran Paramètres SHALL afficher une section "Langue" avec un `DropdownButton` ou `SegmentedButton` proposant trois options : **Automatique** (détection locale OS), **Français**, **English**. La valeur par défaut SHALL être "Automatique". La préférence SHALL être persistée dans `ConfigService` (clé SharedPreferences `locale_preference`, valeur : `null` = Automatique, `"fr"`, `"en"`). Le changement SHALL prendre effet immédiatement, sans redémarrage.

#### Scenario: Sélection "Français" depuis une app en anglais
- **WHEN** l'utilisateur choisit "Français" dans le sélecteur de langue
- **THEN** tous les écrans rebuildent et affichent les strings français sans redémarrage

#### Scenario: Sélection "English" depuis une app en français
- **WHEN** l'utilisateur choisit "English" dans le sélecteur
- **THEN** tous les écrans rebuildent et affichent les strings anglais sans redémarrage

#### Scenario: Sélection "Automatique"
- **WHEN** l'utilisateur choisit "Automatique"
- **THEN** la préférence `null` est persistée et la locale active est déléguée à l'OS

#### Scenario: Persistance après redémarrage
- **WHEN** l'utilisateur a choisi "English" et redémarre l'app
- **THEN** l'app s'ouvre en anglais sans afficher le sélecteur de langue

---

### Requirement: LocaleProvider Riverpod pilotant MaterialApp
Un `localeProvider` (StateNotifierProvider exposant `Locale?`) SHALL lire la préférence depuis `ConfigService` au démarrage et permettre la mise à jour en cours de session. `MaterialApp` dans `lib/main.dart` SHALL être un `ConsumerWidget` watchant `localeProvider` et passant la valeur à son paramètre `locale`. Une valeur `null` délègue la résolution à Flutter (locale OS parmi les `supportedLocales`).

#### Scenario: Locale null → délégation OS
- **WHEN** `localeProvider` expose `null`
- **THEN** `MaterialApp.locale = null` et Flutter résout depuis la locale OS

#### Scenario: Locale explicite → override OS
- **WHEN** `localeProvider` expose `Locale('en')`
- **THEN** `MaterialApp.locale = Locale('en')` quel que soit l'OS

---

### Requirement: Formats date adaptés à la locale
Partout où une date est affichée dans l'UI (date_entree, date_sortie, date de consommation dans l'historique, DatePicker labels), le format SHALL être adapté à la locale active : `dd/MM/yyyy` pour `fr`, `MM/dd/yyyy` pour `en`. Un helper `formatDate(DateTime, Locale)` dans `lib/core/locale_formatting.dart` SHALL centraliser ce comportement via `intl.DateFormat`.

#### Scenario: Date affichée en français
- **WHEN** la locale est `fr` et une date est le 5 janvier 2025
- **THEN** l'UI affiche "05/01/2025"

#### Scenario: Date affichée en anglais
- **WHEN** la locale est `en` et une date est le 5 janvier 2025
- **THEN** l'UI affiche "01/05/2025"

---

### Requirement: Formats nombre adaptés à la locale
Les valeurs numériques décimales affichées (prix, note de dégustation) SHALL utiliser le séparateur décimal de la locale : virgule pour `fr`, point pour `en`. Un helper `formatNumber(double, Locale)` et `formatCurrency(double, Locale)` dans `lib/core/locale_formatting.dart` SHALL centraliser ce comportement via `intl.NumberFormat`.

#### Scenario: Prix affiché en français
- **WHEN** la locale est `fr` et le prix est 12.5 €
- **THEN** l'UI affiche "12,50 €"

#### Scenario: Prix affiché en anglais
- **WHEN** la locale est `en` et le prix est 12.5 €
- **THEN** l'UI affiche "12.50 €"
