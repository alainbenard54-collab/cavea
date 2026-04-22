### Requirement: Affichage de la liste des bouteilles en stock
L'application SHALL afficher la liste de toutes les bouteilles dont `date_sortie` est NULL ou vide, via un stream réactif. La liste SHALL se mettre à jour automatiquement en cas de modification de la base. Quand le filtre maturité est actif, la liste SHALL être triée par urgence au lieu du tri par colonne.

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
Chaque ligne de la liste SHALL afficher au minimum : domaine, appellation, millésime, couleur (sous forme d'icône colorée), emplacement. Les champs optionnels (cru, contenance) SHALL être affichés s'ils sont renseignés.

#### Scenario: Ligne complète
- **WHEN** une bouteille a tous les champs renseignés
- **THEN** domaine, appellation, millésime, icône couleur et emplacement sont visibles

#### Scenario: Champs optionnels absents
- **WHEN** cru ou contenance sont vides
- **THEN** ces champs ne prennent pas de place dans la ligne

---

### Requirement: Colonne GARDE colorée selon maturité (vue desktop)
Dans le tableau desktop, la colonne GARDE SHALL afficher les années de garde avec un fond coloré reflétant la maturité et un delta lisible. Les couleurs SHALL être : rouge pâle pour `aBoireUrgent`, vert pâle pour `optimal`, bleu pâle pour `tropJeune`, neutre pour `sansDonnee`.

#### Scenario: Bouteille à boire d'urgence
- **WHEN** `age > gardeMax` (`age = annéeActuelle - millesime`)
- **THEN** la cellule GARDE affiche fond rouge pâle avec `+N an(s)` (années de dépassement)

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

### Requirement: Filtre couleur multi-sélect
L'application SHALL permettre de filtrer par plusieurs couleurs simultanément via des FilterChips. Aucune sélection = toutes les couleurs. Les valeurs SHALL être déduites des données en base.

#### Scenario: Sélection multiple
- **WHEN** l'utilisateur active "Liquoreux" puis "Moelleux"
- **THEN** les bouteilles liquoreuses ET moelleuses sont affichées (OR logique entre couleurs sélectionnées)

#### Scenario: Désélection totale
- **WHEN** l'utilisateur désactive tous les chips couleur
- **THEN** toutes les couleurs sont affichées

---

### Requirement: Filtre maturité avec chips colorés
L'application SHALL permettre de filtrer par niveau de maturité via des FilterChips colorés. Un seul niveau peut être actif à la fois.

#### Scenario: Filtre aBoireUrgent
- **WHEN** l'utilisateur active le chip rouge "À boire urgent !"
- **THEN** seules les bouteilles dont `age > gardeMax` sont affichées, triées par dépassement décroissant

#### Scenario: Filtre optimal
- **WHEN** l'utilisateur active le chip vert "À boire"
- **THEN** seules les bouteilles à leur apogée sont affichées, triées par proximité de fin de garde croissante

#### Scenario: Filtre tropJeune
- **WHEN** l'utilisateur active le chip bleu "Trop jeune"
- **THEN** seules les bouteilles trop jeunes sont affichées, triées par proximité de maturité croissante

---

### Requirement: Tri secondaire par urgence dans les groupes de maturité
Quand le filtre maturité est actif, la liste SHALL être triée par score d'urgence décroissant dans le groupe sélectionné.

#### Scenario: Tri urgence dans aBoireUrgent
- **WHEN** le filtre maturité est `aBoireUrgent`
- **THEN** les bouteilles sont triées par `age - gardeMax` décroissant (le plus en retard en premier)

#### Scenario: Tri urgence dans optimal
- **WHEN** le filtre maturité est `optimal`
- **THEN** les bouteilles sont triées par `gardeMax - age` décroissant (la plus proche de la limite en premier)

---

### Requirement: Filtres avancés repliables
L'application SHALL proposer un panneau "Filtres avancés" repliable contenant les filtres appellation et millésime. Ce panneau SHALL être replié par défaut.

#### Scenario: Filtre millésime depuis le panneau avancé
- **WHEN** l'utilisateur sélectionne un millésime dans le panneau avancé
- **THEN** seules les bouteilles de ce millésime sont affichées, combiné avec les autres filtres actifs

---

### Requirement: Recherche texte
L'application SHALL permettre une recherche texte libre sur domaine, appellation et millésime (insensible à la casse, correspondance partielle).

#### Scenario: Recherche active
- **WHEN** l'utilisateur saisit "margaux"
- **THEN** seules les bouteilles dont le domaine ou l'appellation contient "margaux" sont affichées

#### Scenario: Recherche vidée
- **WHEN** l'utilisateur efface le champ de recherche
- **THEN** le filtre texte est désactivé, les autres filtres restent actifs

---

### Requirement: Combinaison des filtres
Tous les filtres actifs SHALL s'appliquer simultanément. Les couleurs entre elles sont en OR logique ; tous les autres filtres sont en AND. Un compteur SHALL indiquer le nombre de bouteilles affichées vs le total en stock.

#### Scenario: Compteur avec filtres actifs
- **WHEN** des filtres sont actifs
- **THEN** l'interface affiche "X / Y bouteilles"

---

### Requirement: Layout adaptatif
L'application SHALL utiliser `NavigationRail` pour les largeurs ≥600px (desktop) et `BottomNavigationBar` pour les largeurs <600px (mobile).

#### Scenario: Affichage desktop
- **WHEN** la fenêtre est ≥600px de large
- **THEN** une NavigationRail est visible sur le côté gauche

#### Scenario: Affichage mobile
- **WHEN** la fenêtre est <600px de large
- **THEN** une BottomNavigationBar est visible en bas de l'écran

#### Scenario: Seuil tableau vs liste
- **WHEN** la largeur disponible du contenu (hors NavigationRail) est ≥ 640px
- **THEN** le tableau desktop est affiché ; en dessous, la liste mobile est affichée (mesuré via LayoutBuilder)

---

### Requirement: Lignes cliquables ouvrant le BottomSheet d'actions
Chaque ligne de la liste mobile et du tableau desktop SHALL être cliquable. Un clic SHALL ouvrir le BottomSheet d'actions rapides avec la bouteille correspondante en contexte.

#### Scenario: Clic sur une ligne (desktop)
- **WHEN** l'utilisateur clique sur une ligne du tableau stock
- **THEN** le BottomSheet d'actions s'ouvre avec le domaine et le millésime de la bouteille en titre

#### Scenario: Appui sur une ligne (mobile)
- **WHEN** l'utilisateur appuie sur une ligne de la liste mobile
- **THEN** le BottomSheet d'actions s'ouvre avec les mêmes 4 actions disponibles
