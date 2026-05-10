## ADDED Requirements

### Requirement: Onglet Emplacements dans la navigation principale
L'application SHALL afficher un onglet "Emplacements" (`Icons.shelves`, index 2) dans la navigation principale, accessible depuis le `NavigationRail` (Windows) et la `_MobileBar` (Android). L'onglet est toujours accessible, y compris en mode SyncReadOnly. `_writeOnlyIndices = {1, 3}` (Ajouter=1, Import CSV=3).

#### Scenario: Onglet visible sur Windows
- **WHEN** l'app est ouverte sur Windows (Mode 1 ou Mode 2)
- **THEN** le rail de navigation affiche une entrée "Emplacements" avec `Icons.shelves`

#### Scenario: Onglet visible sur Android
- **WHEN** l'app est ouverte sur Android (Mode 1 ou Mode 2)
- **THEN** la barre du bas affiche une icône "Emplacements"

#### Scenario: Onglet accessible en lecture seule
- **WHEN** l'app est en SyncReadOnly
- **THEN** l'onglet Emplacements reste accessible (pas dans `_writeOnlyIndices`)

---

### Requirement: Widget unique avec navigation interne
L'écran Emplacements SHALL être implémenté comme un seul `ConsumerStatefulWidget` (`LocationTreeScreen`) gérant toute la navigation en interne via `List<String> _path`, sans `Navigator.push`. La NavigationRail et la BottomBar restent visibles à tous les niveaux de l'arbre.

#### Scenario: Navigation sans couvrir le shell
- **WHEN** l'utilisateur descend dans l'arbre (Niveau1 → Niveau2 → liste bouteilles)
- **THEN** la NavigationRail (Windows) ou la BottomBar (Android) reste visible à tous les niveaux

#### Scenario: Données toujours fraîches
- **WHEN** l'utilisateur déplace ou consomme une bouteille depuis la liste d'un emplacement
- **THEN** les stats de l'arbre se mettent à jour en temps réel (stream drift reconstruit le nœud à chaque rebuild)

---

### Requirement: Fil d'ariane cliquable dans l'AppBar
L'AppBar SHALL afficher un fil d'ariane avec "Emplacements" toujours présent en racine, les segments intermédiaires cliquables, et le segment courant non-cliquable.

#### Scenario: Fil d'ariane complet à tous les niveaux
- **WHEN** l'utilisateur est à n'importe quel niveau (arbre ou liste bouteilles)
- **THEN** l'AppBar affiche : Emplacements (cliquable si pas à la racine) › Niveau1 (cliquable si pas le dernier) › Niveau2 (non-cliquable si courant)

#### Scenario: Navigation par tap sur le fil d'ariane
- **WHEN** l'utilisateur tape sur un segment intermédiaire du fil d'ariane
- **THEN** l'app navigue directement à ce niveau (tous les niveaux inférieurs sont retirés du chemin)

---

### Requirement: Arbre hiérarchique avec stats toujours agrégées
L'écran Emplacements SHALL afficher les nœuds de Niveau 1 avec des stats toujours agrégées (sous-emplacements inclus). Format : `N bouteille(s) (NN €)` ou `N bouteille(s) (NN €) dont K sans prix` quand la somme est partielle.

#### Scenario: Stats agrégées automatiquement
- **WHEN** l'utilisateur ouvre l'onglet Emplacements
- **THEN** chaque nœud affiche le compte et la valeur de toutes les bouteilles de ce nœud et de ses sous-emplacements (agrégation Dart récursive via `nodeStats(node, true)`)

#### Scenario: Indication bouteilles sans prix
- **WHEN** un nœud contient des bouteilles dont certaines ont un `prix_achat` et d'autres non
- **THEN** le stat affiche `N bouteilles (NN €) dont K sans prix` (NN = somme partielle des prix renseignés)

#### Scenario: Aucun prix renseigné
- **WHEN** toutes les bouteilles d'un nœud ont `prix_achat` null
- **THEN** le stat affiche uniquement `N bouteille(s)` (pas de montant)

---

### Requirement: Mix nœuds + bouteilles directes
Un nœud parent peut contenir à la fois des sous-emplacements ET des bouteilles directement rattachées. Les deux SHALL être accessibles depuis le même écran.

#### Scenario: Affichage mixte
- **WHEN** un nœud parent a des enfants ET des bouteilles avec cet emplacement exact
- **THEN** l'écran affiche d'abord les sous-nœuds, puis une tuile "Directement dans cet emplacement" avec les stats des bouteilles directes

---

### Requirement: Liste de bouteilles avec badge maturité
En tapant sur un nœud feuille ou sur "Directement dans cet emplacement", l'app SHALL afficher la liste des bouteilles avec un badge maturité compact en trailing (à la place de l'emplacement, redondant avec le fil d'ariane).

#### Scenario: Badge maturité dans la liste
- **WHEN** l'utilisateur consulte la liste bouteilles d'un emplacement
- **THEN** chaque bouteille affiche un badge compact : "Optimal" (vert), "Trop jeune" (bleu), "À boire !" (rouge) — aucun badge si pas de données de garde

#### Scenario: Actions disponibles en mode écriture
- **WHEN** l'app est en mode écriture et l'utilisateur tape sur une bouteille dans la liste
- **THEN** le BottomSheet d'actions s'affiche (Consommer, Consulter la fiche, Déplacer, Modifier la fiche)

#### Scenario: Actions en mode lecture seule
- **WHEN** l'app est en SyncReadOnly et l'utilisateur tape sur une bouteille
- **THEN** le BottomSheet affiche "Mode lecture seule — modifications indisponibles" et Fermer uniquement

#### Scenario: Multi-sélection en mode écriture
- **WHEN** l'utilisateur effectue un appui long sur une bouteille (mode écriture)
- **THEN** le mode sélection s'active avec la BulkActionBar (Déplacer / Consommer)

#### Scenario: Multi-sélection désactivée en lecture seule
- **WHEN** l'app est en SyncReadOnly
- **THEN** l'appui long est ignoré

---

### Requirement: Bouton back Android
L'app SHALL intercepter le bouton back Android pour naviguer dans l'arbre avant de remonter à la navigation principale.

#### Scenario: Back dans l'arbre
- **WHEN** l'utilisateur appuie sur le bouton back Android depuis un niveau de l'arbre
- **THEN** l'app remonte d'un niveau dans l'arbre (via `PopScope(canPop: !_canGoBack)`)

#### Scenario: Back depuis la racine
- **WHEN** l'utilisateur appuie sur le bouton back Android depuis la racine de l'arbre
- **THEN** le comportement de navigation par défaut s'applique (remonte à l'écran précédent ou quitte l'app)
