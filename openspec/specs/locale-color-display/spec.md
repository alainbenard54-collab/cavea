## ADDED Requirements

### Requirement: Mapping statique des libellés couleurs builtin
`ConfigService` SHALL exposer une méthode statique `displayCouleur(String dbKey, Locale locale)` retournant le libellé traduit d'une couleur builtin. Le mapping SHALL couvrir les 7 couleurs builtin :

| Clé DB (fr, invariante) | fr | en |
|---|---|---|
| Rouge | Rouge | Red |
| Blanc | Blanc | White |
| Blanc effervescent | Blanc effervescent | Sparkling white |
| Blanc liquoreux | Blanc liquoreux | Sweet white |
| Blanc moelleux | Blanc moelleux | Semi-sweet white |
| Rosé | Rosé | Rosé |
| Rosé effervescent | Rosé effervescent | Sparkling rosé |

Les valeurs user-custom absentes du mapping SHALL être retournées telles quelles (la méthode ne lève pas d'exception).

#### Scenario: Couleur builtin en français
- **WHEN** `displayCouleur("Rouge", Locale('fr'))` est appelé
- **THEN** retourne `"Rouge"`

#### Scenario: Couleur builtin en anglais
- **WHEN** `displayCouleur("Rouge", Locale('en'))` est appelé
- **THEN** retourne `"Red"`

#### Scenario: Valeur user-custom non mappée
- **WHEN** `displayCouleur("Pétillant maison", Locale('en'))` est appelé
- **THEN** retourne `"Pétillant maison"` (passthrough)

---

### Requirement: Affichage des couleurs traduit dans toute l'UI
Partout où une valeur de couleur provenant de la DB est affichée dans l'UI (liste de stock, fiche bouteille, formulaire d'ajout, listes de référence dans Paramètres, filtres couleur), l'app SHALL appeler `ConfigService.displayCouleur(dbKey, locale)` plutôt que d'afficher la clé DB brute. Les valeurs stockées en base ne SHALL jamais être modifiées.

#### Scenario: Couleur affichée dans la liste de stock en anglais
- **WHEN** la locale est `en` et une bouteille a `couleur = "Rouge"` en base
- **THEN** la colonne couleur de la liste affiche "Red"

#### Scenario: Filtre couleur affiché en anglais
- **WHEN** la locale est `en` et l'utilisateur ouvre le filtre couleur dans l'écran Stock
- **THEN** les chips de filtre affichent "White", "Red", "Rosé", etc.

#### Scenario: Valeur en base inchangée après basculement de langue
- **WHEN** l'utilisateur bascule de `fr` à `en` puis revient à `fr`
- **THEN** la valeur `couleur` stockée en base pour chaque bouteille reste `"Rouge"` (inchangée)

---

### Requirement: Dropdown couleur dans les formulaires affiche les libellés traduits
Le `DropdownButton` couleur dans les formulaires bulk-add et bottle-edit SHALL afficher les libellés via `displayCouleur()`. La valeur soumise en base SHALL rester la clé française invariante (ex. `"Rouge"`).

#### Scenario: Sélection couleur en anglais dans bulk-add
- **WHEN** la locale est `en` et l'utilisateur ouvre le dropdown couleur dans le formulaire d'ajout
- **THEN** les options affichent "White", "Red", "Rosé", etc.

#### Scenario: Valeur persistée en français
- **WHEN** l'utilisateur sélectionne "Red" (en) et valide le formulaire
- **THEN** la ligne insérée en base contient `couleur = "Rouge"`
