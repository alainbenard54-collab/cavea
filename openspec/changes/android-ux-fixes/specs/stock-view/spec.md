## ADDED Requirements

### Requirement: Densité de la table réduite en paysage Android
En orientation paysage sur Android, `StockTable` SHALL réduire son padding vertical par cellule pour maximiser le nombre de lignes visibles.

#### Scenario: Padding compact en paysage
- **WHEN** `Platform.isAndroid` ET `MediaQuery.orientation == Orientation.landscape`
- **THEN** le padding vertical des cellules SHALL être 4 dp (au lieu de 10 dp)

#### Scenario: Padding normal hors paysage Android
- **WHEN** Windows/Linux OU orientation portrait
- **THEN** le padding vertical des cellules SHALL rester à 10 dp

### Requirement: Aucune zone blanche sous la liste (toutes plateformes)
La zone liste du stock SHALL occuper tout l'espace disponible sous les filtres, sans laisser de vide en bas.

#### Scenario: Layout filtres/liste sans zone morte
- **WHEN** les filtres occupent moins de la moitié de la hauteur disponible
- **THEN** la liste SHALL s'étendre jusqu'à la barre de navigation, sans espace vide résiduel
- **HOW** `LayoutBuilder` + `ConstrainedBox(maxHeight: H/2)` pour les filtres, `Expanded` pour la liste (ne pas utiliser `Flexible(flex:1)` + `Expanded(flex:1)`)

### Requirement: Densité des tuiles portrait (BouteilleListTile)
`BouteilleListTile` SHALL afficher les tuiles en mode compact pour maximiser le nombre de lignes visibles en portrait Android.

#### Scenario: Tuile dense
- **WHEN** la liste mobile est affichée (`ListView.builder`, largeur < 640 dp)
- **THEN** chaque `BouteilleListTile` SHALL utiliser `ListTile(dense: true)` (52 dp au lieu de 72 dp)
