### Requirement: Filtre couleur multi-sélect
L'application SHALL permettre de sélectionner simultanément plusieurs couleurs de vin via des FilterChips. Aucune sélection = toutes les couleurs affichées. Les valeurs SHALL être déduites des données en base.

#### Scenario: Sélection unique
- **WHEN** l'utilisateur active le chip "Rouge"
- **THEN** seules les bouteilles rouges sont affichées

#### Scenario: Sélection multiple
- **WHEN** l'utilisateur active "Liquoreux" puis "Moelleux"
- **THEN** les bouteilles liquoreuses ET moelleuses sont affichées (OR logique entre couleurs)

#### Scenario: Désélection
- **WHEN** l'utilisateur désactive tous les chips couleur
- **THEN** toutes les couleurs sont affichées

---

### Requirement: Filtre maturité avec chips colorés
L'application SHALL permettre de filtrer par niveau de maturité via des FilterChips colorés. Un seul niveau peut être actif à la fois. Aucune sélection = tous les niveaux affichés.

#### Scenario: Filtre aBoireUrgent
- **WHEN** l'utilisateur active le chip rouge "À boire urgent !"
- **THEN** seules les bouteilles dont `age > gardeMax` sont affichées, triées par dépassement décroissant

#### Scenario: Filtre optimal
- **WHEN** l'utilisateur active le chip vert "À boire"
- **THEN** seules les bouteilles à leur apogée sont affichées, triées par proximité de fin de garde

#### Scenario: Filtre tropJeune
- **WHEN** l'utilisateur active le chip bleu "Trop jeune"
- **THEN** seules les bouteilles trop jeunes sont affichées, triées par proximité de maturité

#### Scenario: Filtre sansDonnee
- **WHEN** l'utilisateur active le chip gris "?"
- **THEN** seules les bouteilles sans données de garde sont affichées

#### Scenario: Désactivation du filtre maturité
- **WHEN** l'utilisateur désactive le chip maturité actif
- **THEN** tous les niveaux sont affichés, le tri par colonne reprend

---

### Requirement: Filtres avancés repliables (millésime + appellation)
L'application SHALL proposer un panneau "Filtres avancés" repliable contenant les filtres millésime et appellation. Ce panneau SHALL être replié par défaut.

#### Scenario: Ouverture du panneau
- **WHEN** l'utilisateur clique sur "Filtres avancés"
- **THEN** les dropdowns millésime et appellation apparaissent

#### Scenario: Filtre millésime actif depuis le panneau avancé
- **WHEN** l'utilisateur sélectionne un millésime dans le panneau avancé
- **THEN** seules les bouteilles de ce millésime sont affichées, combiné avec les autres filtres actifs
