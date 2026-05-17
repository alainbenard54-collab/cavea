## ADDED Requirements

### Requirement: Suggestions autocomplete ouvertes vers le haut en paysage Android
En orientation paysage sur Android, tous les champs `_AutocompleteField` de `BulkAddScreen` (domaine, appellation, cru, contenance, fournisseur, emplacement) SHALL ouvrir leurs suggestions au-dessus du champ pour ne pas être masquées par le clavier virtuel.

#### Scenario: Ouverture vers le haut en paysage
- **WHEN** `Platform.isAndroid` est vrai ET `MediaQuery.orientation == Orientation.landscape`
- **THEN** chaque `_AutocompleteField` SHALL recevoir `openDirection: OptionsViewOpenDirection.up` et l'appliquer à son `RawAutocomplete` interne

#### Scenario: Ouverture vers le bas hors paysage Android
- **WHEN** la plateforme est Windows/Linux OU l'orientation est portrait
- **THEN** chaque `_AutocompleteField` SHALL utiliser `OptionsViewOpenDirection.down` (comportement par défaut inchangé)
