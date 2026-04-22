### Requirement: Affichage de la liste des bouteilles en stock
L'application SHALL afficher la liste de toutes les bouteilles dont `date_sortie` est NULL ou vide, via un stream réactif. La liste SHALL se mettre à jour automatiquement en cas de modification de la base.

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

### Requirement: Affichage d'une ligne de bouteille
Chaque ligne de la liste SHALL afficher au minimum : domaine, appellation, millésime, couleur (sous forme de badge coloré), emplacement. Les champs optionnels (cru, contenance) SHALL être affichés s'ils sont renseignés.

#### Scenario: Ligne complète
- **WHEN** une bouteille a tous les champs renseignés
- **THEN** domaine, appellation, millésime, badge couleur et emplacement sont visibles

#### Scenario: Champs optionnels absents
- **WHEN** cru ou contenance sont vides
- **THEN** ces champs ne prennent pas de place dans la ligne

---

### Requirement: Filtre par couleur
L'application SHALL permettre de filtrer la liste par couleur de vin (Rouge, Blanc, Rosé, Effervescent, etc.). Un filtre "Toutes" SHALL remettre l'affichage complet. Les valeurs de couleur disponibles SHALL être déduites des données en base.

#### Scenario: Filtre couleur actif
- **WHEN** l'utilisateur sélectionne "Rouge"
- **THEN** seules les bouteilles avec `couleur = 'Rouge'` sont affichées

#### Scenario: Remise à zéro couleur
- **WHEN** l'utilisateur sélectionne "Toutes"
- **THEN** toutes les bouteilles en stock sont affichées

---

### Requirement: Filtre par appellation
L'application SHALL permettre de filtrer par appellation. Les valeurs disponibles SHALL être déduites des données en base (pas de liste codée en dur).

#### Scenario: Filtre appellation actif
- **WHEN** l'utilisateur sélectionne une appellation
- **THEN** seules les bouteilles de cette appellation sont affichées

---

### Requirement: Filtre par millésime
L'application SHALL permettre de filtrer par millésime. Les années disponibles SHALL être déduites des données en base, triées décroissant.

#### Scenario: Filtre millésime actif
- **WHEN** l'utilisateur sélectionne un millésime
- **THEN** seules les bouteilles de ce millésime sont affichées

---

### Requirement: Recherche texte sur le domaine
L'application SHALL permettre une recherche texte libre filtrée sur le champ `domaine` (recherche insensible à la casse, correspondance partielle).

#### Scenario: Recherche active
- **WHEN** l'utilisateur saisit "margaux" dans le champ de recherche
- **THEN** seules les bouteilles dont le domaine contient "margaux" (insensible à la casse) sont affichées

#### Scenario: Recherche vidée
- **WHEN** l'utilisateur efface le champ de recherche
- **THEN** le filtre texte est désactivé, les autres filtres restent actifs

---

### Requirement: Combinaison des filtres
Tous les filtres actifs SHALL s'appliquer simultanément (AND logique). Un compteur SHALL indiquer le nombre de bouteilles affichées vs le total en stock.

#### Scenario: Plusieurs filtres actifs
- **WHEN** couleur = "Rouge" ET millésime = 2015 sont tous deux actifs
- **THEN** seules les bouteilles rouges de 2015 sont affichées

#### Scenario: Compteur
- **WHEN** des filtres sont actifs
- **THEN** l'interface affiche "X bouteilles (sur Y)"

---

### Requirement: Layout adaptatif
L'application SHALL utiliser `NavigationRail` pour les largeurs ≥600px (desktop) et `BottomNavigationBar` pour les largeurs <600px (mobile). Les destinations de navigation SHALL être identiques dans les deux cas.

#### Scenario: Affichage desktop
- **WHEN** la fenêtre est ≥600px de large
- **THEN** une NavigationRail est visible sur le côté gauche

#### Scenario: Affichage mobile
- **WHEN** la fenêtre est <600px de large
- **THEN** une BottomNavigationBar est visible en bas de l'écran
