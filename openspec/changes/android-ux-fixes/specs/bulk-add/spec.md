## ADDED Requirements

### Requirement: Suggestions autocomplétion ouvertes vers le haut en paysage Android
En orientation paysage sur Android, tous les champs à autocomplétion de `BulkAddScreen` et `RepartitionRow` SHALL ouvrir leurs suggestions au-dessus du champ via un overlay flottant, pour ne pas être masquées par le clavier ou l'AppBar.

#### Scenario: Overlay vers le haut en paysage
- **WHEN** `Platform.isAndroid` ET `MediaQuery.orientation == Orientation.landscape`
- **THEN** `_AutocompleteField` (domaine, appellation, fournisseur) et `RepartitionRow` (emplacement) SHALL utiliser `RawAutocomplete` avec `optionsViewOpenDirection: OptionsViewOpenDirection.up` et `alignment: Alignment.bottomLeft`
- **NOTE** L'overlay `RawAutocomplete` est flottant (pas dans le scroll du formulaire) : les suggestions apparaissent devant l'AppBar, non tronquées

#### Scenario: Overlay vers le bas hors paysage Android
- **WHEN** Windows/Linux OU orientation portrait
- **THEN** `optionsViewOpenDirection: OptionsViewOpenDirection.down` (comportement par défaut)

### Requirement: `_AutocompleteField` basé sur RawAutocomplete (overlay)
`_AutocompleteField` dans `bulk_add_screen.dart` et le champ emplacement de `RepartitionRow` SHALL utiliser `RawAutocomplete` avec overlay flottant (et non un `Column` avec liste inline).

#### Scenario: Suggestions devant l'AppBar
- **WHEN** des suggestions sont disponibles
- **THEN** elles SHALL apparaître dans un overlay Material flottant par-dessus tous les widgets, y compris l'AppBar
