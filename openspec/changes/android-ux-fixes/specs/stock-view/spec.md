## ADDED Requirements

### Requirement: Densité de la table réduite en paysage Android
En orientation paysage sur Android, `StockTable` SHALL réduire son padding vertical par cellule pour maximiser le nombre de lignes visibles sans scroll, compte tenu de la hauteur d'écran limitée (~360dp).

#### Scenario: Padding compact en paysage
- **WHEN** `Platform.isAndroid` est vrai ET `MediaQuery.orientation == Orientation.landscape`
- **THEN** le padding vertical des cellules de la table SHALL être de 4dp (au lieu de 10dp en portrait)

#### Scenario: Padding normal hors paysage Android
- **WHEN** la plateforme est Windows/Linux OU l'orientation est portrait
- **THEN** le padding vertical des cellules SHALL rester à 10dp (comportement inchangé)
