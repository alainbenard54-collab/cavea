## ADDED Requirements

### Requirement: Suggestions autocomplete ouvertes vers le haut en paysage Android
En orientation paysage sur Android, les suggestions du champ `RawAutocomplete` de `BottleEditScreen` SHALL s'ouvrir au-dessus du champ de saisie pour ne pas être masquées par le clavier virtuel.

#### Scenario: Ouverture vers le haut en paysage
- **WHEN** `Platform.isAndroid` est vrai ET `MediaQuery.orientation == Orientation.landscape`
- **THEN** `RawAutocomplete` SHALL utiliser `optionsViewOpenDirection: OptionsViewOpenDirection.up`

#### Scenario: Ouverture vers le bas hors paysage Android
- **WHEN** la plateforme est Windows/Linux OU l'orientation est portrait
- **THEN** `RawAutocomplete` SHALL utiliser `OptionsViewOpenDirection.down` (comportement par défaut inchangé)
