## ADDED Requirements

### Requirement: watchStock n'émet que les bouteilles en stock
`BouteilleDao.watchStock()` SHALL émettre uniquement les bouteilles dont `date_sortie` est null ou vide, excluant les bouteilles consommées.

#### Scenario: stock avec bouteilles mixtes
- **WHEN** la base contient une bouteille avec `date_sortie` null et une avec `date_sortie` renseignée
- **THEN** `watchStock().first` ne retourne que la bouteille sans `date_sortie`

#### Scenario: stock vide après consommation de toutes les bouteilles
- **WHEN** toutes les bouteilles ont une `date_sortie` renseignée
- **THEN** `watchStock().first` retourne une liste vide

### Requirement: watchStockFiltered filtre correctement par couleur, appellation, millésime et texte
`BouteilleDao.watchStockFiltered()` SHALL restreindre les résultats aux bouteilles correspondant aux critères fournis, en ne retournant que les bouteilles en stock.

#### Scenario: filtre par couleur unique
- **WHEN** la base contient des bouteilles Rouge et Blanc, et `couleurs: ['Rouge']` est appliqué
- **THEN** seules les bouteilles Rouge sont retournées

#### Scenario: filtre par plusieurs couleurs
- **WHEN** la base contient des bouteilles Rouge, Blanc et Rosé, et `couleurs: ['Rouge', 'Blanc']` est appliqué
- **THEN** les bouteilles Rouge et Blanc sont retournées, Rosé est exclue

#### Scenario: filtre par appellation
- **WHEN** la base contient des bouteilles de différentes appellations et `appellation: 'Pomerol'` est appliqué
- **THEN** seules les bouteilles Pomerol sont retournées

#### Scenario: filtre par millésime
- **WHEN** la base contient des bouteilles de différents millésimes et `millesime: 2015` est appliqué
- **THEN** seules les bouteilles de 2015 sont retournées

#### Scenario: filtre par texte sur domaine
- **WHEN** `texte: 'petrus'` est appliqué (insensible à la casse)
- **THEN** les bouteilles dont le domaine contient 'petrus' sont retournées

#### Scenario: filtre sans critère retourne tout le stock
- **WHEN** `watchStockFiltered()` est appelé sans paramètres
- **THEN** toutes les bouteilles en stock sont retournées

### Requirement: insertBouteille insère une bouteille en base
`BouteilleDao.insertBouteille()` SHALL créer une nouvelle ligne dans la table bouteilles.

#### Scenario: insertion simple
- **WHEN** `insertBouteille(companion)` est appelé avec un companion valide
- **THEN** la bouteille apparaît dans `watchStock().first`

### Requirement: insertBouteilles insère plusieurs bouteilles en transaction atomique
`BouteilleDao.insertBouteilles()` SHALL insérer toutes les bouteilles dans une seule transaction — soit toutes réussissent, soit aucune.

#### Scenario: insertion en lot de N bouteilles
- **WHEN** `insertBouteilles([b1, b2, b3])` est appelé
- **THEN** les trois bouteilles apparaissent dans `watchStock().first`

### Requirement: deplacerBouteille met à jour l'emplacement sans toucher à date_sortie
`BouteilleDao.deplacerBouteille()` SHALL modifier uniquement le champ `emplacement` de la bouteille identifiée par `id`. Les autres champs, notamment `date_sortie`, SHALL rester inchangés.

#### Scenario: déplacement d'une bouteille en stock
- **WHEN** `deplacerBouteille(id, 'Cave > Étagère 2')` est appelé
- **THEN** la bouteille a `emplacement = 'Cave > Étagère 2'` et `date_sortie` reste null

#### Scenario: déplacement ne retire pas la bouteille du stock
- **WHEN** `deplacerBouteille(id, 'Cave B')` est appelé
- **THEN** la bouteille apparaît toujours dans `watchStock().first`

### Requirement: consommerBouteille enregistre la sortie et les données de dégustation
`BouteilleDao.consommerBouteille()` SHALL écrire `date_sortie`, et optionnellement `note_degus` et `commentaire_degus`, sur la bouteille identifiée par `id`.

#### Scenario: consommation avec note et commentaire
- **WHEN** `consommerBouteille(id, dateSortie: '2026-05-07', noteDegus: 8.5, commentaireDegus: 'Excellent')` est appelé
- **THEN** la bouteille a `date_sortie = '2026-05-07'`, `note_degus = 8.5`, `commentaire_degus = 'Excellent'`

#### Scenario: consommation sans note ni commentaire
- **WHEN** `consommerBouteille(id, dateSortie: '2026-05-07')` est appelé sans note ni commentaire
- **THEN** la bouteille a `date_sortie = '2026-05-07'`, `note_degus` reste null, `commentaire_degus` reste null

#### Scenario: bouteille consommée exclue du stock
- **WHEN** `consommerBouteille` est appelé sur une bouteille en stock
- **THEN** la bouteille disparaît de `watchStock().first`

### Requirement: getDistinctEmplacements retourne les emplacements des bouteilles en stock
`BouteilleDao.getDistinctEmplacements()` SHALL retourner une liste triée des valeurs distinctes de `emplacement` pour les bouteilles en stock uniquement.

#### Scenario: emplacements distincts triés
- **WHEN** la base contient trois bouteilles en stock avec emplacements 'Cave B', 'Cave A', 'Cave A'
- **THEN** le résultat est `['Cave A', 'Cave B']`

#### Scenario: les emplacements des bouteilles consommées sont exclus
- **WHEN** une bouteille avec emplacement 'Chambre' est consommée
- **THEN** 'Chambre' n'apparaît pas dans `getDistinctEmplacements()`

### Requirement: getDistinctCouleurs retourne les couleurs des bouteilles en stock
`BouteilleDao.getDistinctCouleurs()` SHALL retourner une liste triée des valeurs distinctes de `couleur` pour les bouteilles en stock.

#### Scenario: couleurs distinctes
- **WHEN** la base contient des bouteilles Rouge, Blanc, Rouge en stock
- **THEN** le résultat est `['Blanc', 'Rouge']`
