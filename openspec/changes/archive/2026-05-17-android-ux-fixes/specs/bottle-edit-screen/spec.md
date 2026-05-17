## Purpose
Améliorer l'UX des champs à autocomplétion de `BottleEditScreen` en orientation paysage Android.

## ADDED Requirements

### Requirement: Suggestions autocomplétion ouvertes vers le haut en paysage Android
En orientation paysage sur Android, les suggestions `RawAutocomplete` de `BottleEditScreen` SHALL s'ouvrir au-dessus du champ pour ne pas être masquées par le clavier.

#### Scenario: Ouverture vers le haut en paysage
- **WHEN** `Platform.isAndroid` ET `MediaQuery.orientation == Orientation.landscape`
- **THEN** `RawAutocomplete` SHALL utiliser `optionsViewOpenDirection: OptionsViewOpenDirection.up` et `alignment: Alignment.bottomLeft`

#### Scenario: Ouverture vers le bas hors paysage Android
- **WHEN** Windows/Linux OU orientation portrait
- **THEN** `RawAutocomplete` SHALL utiliser `OptionsViewOpenDirection.down` (comportement par défaut)
