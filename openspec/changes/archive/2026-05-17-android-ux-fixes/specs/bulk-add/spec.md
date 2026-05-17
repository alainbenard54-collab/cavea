## Purpose
Améliorer l'UX des champs à autocomplétion de `BulkAddScreen` et `RepartitionRow` en orientation paysage Android.

## ADDED Requirements

### Requirement: Suggestions autocomplétion via overlay flottant (RawAutocomplete)
`_AutocompleteField` et le champ emplacement de `RepartitionRow` SHALL utiliser `RawAutocomplete` avec overlay flottant, non un `Column` avec liste inline.

#### Scenario: Suggestions devant l'AppBar
- **WHEN** des suggestions sont disponibles
- **THEN** elles SHALL apparaître dans un overlay Material flottant par-dessus tous les widgets, y compris l'AppBar

### Requirement: Ouverture vers le haut en paysage Android
En orientation paysage sur Android, les suggestions SHALL s'ouvrir au-dessus du champ.

#### Scenario: Overlay vers le haut en paysage
- **WHEN** `Platform.isAndroid` ET `MediaQuery.orientation == Orientation.landscape`
- **THEN** `RawAutocomplete` SHALL utiliser `optionsViewOpenDirection: OptionsViewOpenDirection.up` et `alignment: Alignment.bottomLeft`

#### Scenario: Overlay vers le bas hors paysage Android
- **WHEN** Windows/Linux OU orientation portrait
- **THEN** `optionsViewOpenDirection: OptionsViewOpenDirection.down` (comportement par défaut)
