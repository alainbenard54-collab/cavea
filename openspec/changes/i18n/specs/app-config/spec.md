## ADDED Requirements

### Requirement: Persistance de la préférence de langue
`ConfigService` SHALL stocker la préférence de langue de l'utilisateur dans SharedPreferences sous la clé `locale_preference`. Les valeurs valides sont : `null` (absent = Automatique), `"fr"`, `"en"`. Une méthode `saveLocalePreference(String? code)` SHALL persister la valeur. Une méthode `getLocalePreference()` SHALL retourner la valeur stockée (`null` si absente).

#### Scenario: Sauvegarde de la préférence français
- **WHEN** `saveLocalePreference("fr")` est appelé
- **THEN** SharedPreferences contient `locale_preference = "fr"`

#### Scenario: Réinitialisation en automatique
- **WHEN** `saveLocalePreference(null)` est appelé
- **THEN** la clé `locale_preference` est supprimée de SharedPreferences (ou stockée comme chaîne vide interprétée comme null)

#### Scenario: Lecture de la préférence au démarrage
- **WHEN** l'app démarre et que `locale_preference = "en"` est dans SharedPreferences
- **THEN** `getLocalePreference()` retourne `"en"` et le `localeProvider` expose `Locale('en')`

#### Scenario: Aucune préférence stockée
- **WHEN** l'app démarre sans clé `locale_preference` dans SharedPreferences
- **THEN** `getLocalePreference()` retourne `null` et la locale est déléguée à l'OS
