## Purpose
Améliorer la densité d'affichage de la vue stock sur Android et supprimer la zone blanche sous la liste sur toutes les plateformes.

## ADDED Requirements

### Requirement: Padding compact en paysage Android (StockTable)
En orientation paysage sur Android, `StockTable` SHALL réduire son padding vertical par cellule.

#### Scenario: Padding compact en paysage
- **WHEN** `Platform.isAndroid` ET `MediaQuery.orientation == Orientation.landscape`
- **THEN** le padding vertical des cellules SHALL être 4 dp (au lieu de 10 dp)

#### Scenario: Padding normal hors paysage Android
- **WHEN** Windows/Linux OU orientation portrait
- **THEN** le padding vertical des cellules SHALL rester à 10 dp

### Requirement: Aucune zone blanche sous la liste (toutes plateformes)
La liste SHALL occuper tout l'espace disponible sous les filtres, sans zone vide résiduelle.

#### Scenario: Layout filtres/liste sans zone morte
- **WHEN** les filtres occupent moins de la moitié de la hauteur disponible
- **THEN** la liste SHALL s'étendre jusqu'à la barre de navigation sans espace vide
- **HOW** `LayoutBuilder` + `ConstrainedBox(maxHeight: H/2)` pour les filtres, `Expanded` pour la liste

### Requirement: Tuiles portrait compactes (BouteilleListTile)
`BouteilleListTile` SHALL afficher les tuiles en mode dense pour maximiser les lignes visibles.

#### Scenario: Tuile dense
- **WHEN** la liste mobile est affichée (largeur < 640 dp)
- **THEN** chaque `BouteilleListTile` SHALL utiliser `ListTile(dense: true)` (52 dp au lieu de 72 dp)
