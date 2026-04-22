## ADDED Requirements

### Requirement: Calcul de maturité d'une bouteille
L'application SHALL calculer la maturité d'une bouteille à la volée en comparant `DateTime.now().year - millesime` aux bornes `gardeMin` et `gardeMax`. Le résultat SHALL être un niveau parmi : `tropJeune`, `optimal`, `aBoireUrgent`, `sansDonnee`.

#### Scenario: Bouteille trop jeune
- **WHEN** `DateTime.now().year - millesime < gardeMin`
- **THEN** le niveau de maturité est `tropJeune`

#### Scenario: Bouteille à son apogée
- **WHEN** `gardeMin <= DateTime.now().year - millesime <= gardeMax`
- **THEN** le niveau de maturité est `optimal`

#### Scenario: Bouteille à boire d'urgence
- **WHEN** `DateTime.now().year - millesime > gardeMax`
- **THEN** le niveau de maturité est `aBoireUrgent`

#### Scenario: Données de garde absentes
- **WHEN** `gardeMin` ou `gardeMax` est null ou égal à 0
- **THEN** le niveau de maturité est `sansDonnee`

---

### Requirement: Badge visuel de maturité
L'application SHALL afficher un badge coloré (chip Material 3) reflétant le niveau de maturité de chaque bouteille. Les couleurs SHALL être : bleu pour `tropJeune`, vert pour `optimal`, rouge pour `aBoireUrgent`, gris pour `sansDonnee`.

#### Scenario: Badge bleu — trop jeune
- **WHEN** le niveau de maturité est `tropJeune`
- **THEN** un chip bleu affiche le label "Trop jeune"

#### Scenario: Badge vert — optimal
- **WHEN** le niveau de maturité est `optimal`
- **THEN** un chip vert affiche le label "À boire"

#### Scenario: Badge rouge — à boire d'urgence
- **WHEN** le niveau de maturité est `aBoireUrgent`
- **THEN** un chip rouge affiche le label "À boire !"

#### Scenario: Badge gris — pas de données
- **WHEN** le niveau de maturité est `sansDonnee`
- **THEN** un chip gris affiche le label "?"

---

### Requirement: Affichage de la liste "Quoi boire ?"
L'application SHALL afficher la liste de toutes les bouteilles en stock avec leur badge de maturité. La liste SHALL être triée par niveau de maturité : `aBoireUrgent` en premier, puis `optimal`, puis `tropJeune`, puis `sansDonnee`.

#### Scenario: Affichage initial
- **WHEN** l'utilisateur ouvre la vue "Quoi boire ?"
- **THEN** toutes les bouteilles en stock sont affichées avec leur badge, triées par urgence décroissante

#### Scenario: Mise à jour réactive
- **WHEN** une bouteille est ajoutée ou consommée en base
- **THEN** la liste se met à jour sans rechargement manuel

#### Scenario: Aucune bouteille en stock
- **WHEN** la cave est vide
- **THEN** un message "Aucune bouteille en stock" est affiché

---

### Requirement: Filtre par couleur de vin
L'application SHALL permettre de filtrer la liste "Quoi boire ?" par couleur de vin. Les valeurs disponibles SHALL être déduites des données en base. Un filtre "Toutes" SHALL remettre l'affichage complet.

#### Scenario: Filtre couleur actif
- **WHEN** l'utilisateur sélectionne "Rouge"
- **THEN** seules les bouteilles rouges sont affichées, triées par maturité

#### Scenario: Remise à zéro
- **WHEN** l'utilisateur sélectionne "Toutes"
- **THEN** toutes les bouteilles en stock sont affichées

---

### Requirement: Navigation vers la vue "Quoi boire ?"
L'application SHALL exposer la vue "Quoi boire ?" comme destination principale de navigation, accessible depuis la NavigationRail (desktop ≥600px) et la BottomNavigationBar (mobile <600px).

#### Scenario: Accès depuis NavigationRail
- **WHEN** la fenêtre est ≥600px et l'utilisateur clique sur "Quoi boire ?" dans la NavigationRail
- **THEN** l'écran "Quoi boire ?" s'affiche

#### Scenario: Accès depuis BottomNavigationBar
- **WHEN** la fenêtre est <600px et l'utilisateur tape sur "Quoi boire ?" dans la BottomNavigationBar
- **THEN** l'écran "Quoi boire ?" s'affiche
