## ADDED Requirements

### Requirement: computeMaturity retourne sansDonnee quand les données de garde sont absentes ou nulles
La fonction `computeMaturity` SHALL retourner `MaturityLevel.sansDonnee` quand `gardeMin` ou `gardeMax` est null, égal à 0, ou quand `millesime` est ≤ 0.

#### Scenario: gardeMin null
- **WHEN** `computeMaturity(millesime: 2010, gardeMin: null, gardeMax: 10, annee: 2026)` est appelée
- **THEN** le résultat est `MaturityLevel.sansDonnee`

#### Scenario: gardeMax null
- **WHEN** `computeMaturity(millesime: 2010, gardeMin: 5, gardeMax: null, annee: 2026)` est appelée
- **THEN** le résultat est `MaturityLevel.sansDonnee`

#### Scenario: gardeMin égal à 0
- **WHEN** `computeMaturity(millesime: 2010, gardeMin: 0, gardeMax: 10, annee: 2026)` est appelée
- **THEN** le résultat est `MaturityLevel.sansDonnee`

#### Scenario: millesime égal à 0
- **WHEN** `computeMaturity(millesime: 0, gardeMin: 5, gardeMax: 10, annee: 2026)` est appelée
- **THEN** le résultat est `MaturityLevel.sansDonnee`

### Requirement: computeMaturity retourne tropJeune quand l'âge est inférieur à gardeMin
La fonction `computeMaturity` SHALL retourner `MaturityLevel.tropJeune` quand `annee - millesime < gardeMin`.

#### Scenario: bouteille trop jeune d'un an
- **WHEN** `computeMaturity(millesime: 2020, gardeMin: 7, gardeMax: 15, annee: 2026)` est appelée (âge = 6, gardeMin = 7)
- **THEN** le résultat est `MaturityLevel.tropJeune`

#### Scenario: bouteille à exactement gardeMin (limite inférieure — optimal)
- **WHEN** `computeMaturity(millesime: 2019, gardeMin: 7, gardeMax: 15, annee: 2026)` est appelée (âge = 7 = gardeMin)
- **THEN** le résultat est `MaturityLevel.optimal`

### Requirement: computeMaturity retourne optimal quand l'âge est dans la fenêtre de garde
La fonction `computeMaturity` SHALL retourner `MaturityLevel.optimal` quand `gardeMin ≤ annee - millesime ≤ gardeMax`.

#### Scenario: bouteille au milieu de la fenêtre
- **WHEN** `computeMaturity(millesime: 2015, gardeMin: 5, gardeMax: 15, annee: 2026)` est appelée (âge = 11)
- **THEN** le résultat est `MaturityLevel.optimal`

#### Scenario: bouteille à exactement gardeMax (limite supérieure — optimal)
- **WHEN** `computeMaturity(millesime: 2011, gardeMin: 5, gardeMax: 15, annee: 2026)` est appelée (âge = 15 = gardeMax)
- **THEN** le résultat est `MaturityLevel.optimal`

### Requirement: computeMaturity retourne aBoireUrgent quand l'âge dépasse gardeMax
La fonction `computeMaturity` SHALL retourner `MaturityLevel.aBoireUrgent` quand `annee - millesime > gardeMax`.

#### Scenario: bouteille dépassée d'un an
- **WHEN** `computeMaturity(millesime: 2010, gardeMin: 5, gardeMax: 15, annee: 2026)` est appelée (âge = 16)
- **THEN** le résultat est `MaturityLevel.aBoireUrgent`

### Requirement: urgencyScore encode l'urgence relative de manière cohérente
La fonction `urgencyScore` SHALL retourner des valeurs permettant un tri décroissant homogène : plus le score est élevé, plus la bouteille est urgente à consommer, quel que soit le niveau de maturité.

#### Scenario: aBoireUrgent — score positif croissant avec le retard
- **WHEN** `urgencyScore(millesime: 2005, gardeMin: 5, gardeMax: 10, annee: 2026)` est appelée (âge = 21, dépassement = 11)
- **THEN** le score est `11` (age - gardeMax = 21 - 10)

#### Scenario: optimal — score négatif, moins négatif si proche de la limite haute
- **WHEN** `urgencyScore(millesime: 2014, gardeMin: 5, gardeMax: 15, annee: 2026)` est appelée (âge = 12, écart = 12 - 15 = -3)
- **THEN** le score est `-3`

#### Scenario: tropJeune — score négatif, moins négatif si proche de gardeMin
- **WHEN** `urgencyScore(millesime: 2022, gardeMin: 7, gardeMax: 15, annee: 2026)` est appelée (âge = 4, écart = 4 - 7 = -3)
- **THEN** le score est `-3`

#### Scenario: sansDonnee — score nul
- **WHEN** `urgencyScore(millesime: 2010, gardeMin: null, gardeMax: null, annee: 2026)` est appelée
- **THEN** le score est `0`

### Requirement: maturitySortOrder définit l'ordre d'affichage des niveaux
La fonction `maturitySortOrder` SHALL retourner un entier permettant de trier les niveaux dans l'ordre : `aBoireUrgent` (0) → `optimal` (1) → `tropJeune` (2) → `sansDonnee` (3).

#### Scenario: ordre relatif des quatre niveaux
- **WHEN** les quatre niveaux sont comparés par leur ordre
- **THEN** `maturitySortOrder(aBoireUrgent) < maturitySortOrder(optimal) < maturitySortOrder(tropJeune) < maturitySortOrder(sansDonnee)`
