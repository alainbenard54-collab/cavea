## MODIFIED Requirements

### Requirement: Affichage de la liste des bouteilles en stock
L'application SHALL afficher la liste de toutes les bouteilles dont `date_sortie` est NULL ou vide, via un stream réactif. La liste SHALL se mettre à jour automatiquement en cas de modification de la base. Quand le filtre maturité est actif, la liste SHALL être triée par niveau de maturité avec tri secondaire par urgence.

#### Scenario: Affichage initial
- **WHEN** l'utilisateur ouvre l'écran stock
- **THEN** la liste affiche toutes les bouteilles en stock triées par domaine puis millésime

#### Scenario: Base vide
- **WHEN** aucune bouteille n'est en stock
- **THEN** un message "Aucune bouteille en stock" est affiché avec un bouton d'accès à l'import CSV

#### Scenario: Mise à jour réactive
- **WHEN** une bouteille est ajoutée ou consommée en base
- **THEN** la liste se met à jour sans rechargement manuel

---

### Requirement: Colonne GARDE colorée selon maturité
Dans la vue tableau desktop, la colonne GARDE SHALL afficher les années de garde avec un fond coloré reflétant la maturité et un delta lisible. Les couleurs SHALL être : rouge pâle pour `aBoireUrgent`, vert pâle pour `optimal`, bleu pâle pour `tropJeune`, neutre pour `sansDonnee`.

#### Scenario: Bouteille à boire d'urgence
- **WHEN** `age > gardeMax`
- **THEN** la cellule GARDE affiche fond rouge pâle avec le delta `+N an(s)` sous les années de garde

#### Scenario: Bouteille à son apogée
- **WHEN** `gardeMin <= age <= gardeMax`
- **THEN** la cellule GARDE affiche fond vert pâle avec `–N an(s)` (temps restant avant fin de garde)

#### Scenario: Bouteille trop jeune
- **WHEN** `age < gardeMin`
- **THEN** la cellule GARDE affiche fond bleu pâle avec `dans N an(s)` (temps avant maturité)

#### Scenario: Données de garde absentes
- **WHEN** `gardeMin` ou `gardeMax` est null ou 0
- **THEN** la cellule GARDE affiche `—` sans couleur de fond

---

### Requirement: Tri secondaire par urgence dans les groupes de maturité
Quand le filtre maturité est actif, la liste SHALL être triée en deux niveaux : niveau de maturité en primaire, score d'urgence en secondaire.

#### Scenario: Tri urgence dans aBoireUrgent
- **WHEN** le filtre maturité est `aBoireUrgent`
- **THEN** les bouteilles sont triées par `age - gardeMax` décroissant (le plus en retard en premier)

#### Scenario: Tri urgence dans optimal
- **WHEN** le filtre maturité est `optimal`
- **THEN** les bouteilles sont triées par `gardeMax - age` croissant (la plus proche de la limite en premier)

#### Scenario: Tri urgence dans tropJeune
- **WHEN** le filtre maturité est `tropJeune`
- **THEN** les bouteilles sont triées par `gardeMin - age` croissant (la plus proche de la maturité en premier)

---

### Requirement: Vue "Quoi boire ?" supprimée
La destination de navigation "Quoi boire ?" et la route `/quoi-boire` SHALL être supprimées. Ses fonctionnalités sont intégrées dans la vue stock.

#### Scenario: Navigation sans "Quoi boire ?"
- **WHEN** l'utilisateur consulte la navigation principale
- **THEN** seules les destinations Stock et Import CSV sont présentes
