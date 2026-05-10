## ADDED Requirements

### Requirement: Onglet Emplacements dans la navigation principale
L'application SHALL afficher un onglet "Emplacements" dans la navigation principale, accessible depuis le `NavigationRail` (Windows) et la `BottomBar` (Android), au même niveau que Stock, Ajouter, Import CSV et Paramètres.

#### Scenario: Onglet visible sur Windows
- **WHEN** l'app est ouverte sur Windows (Mode 1 ou Mode 2)
- **THEN** le rail de navigation affiche une entrée "Emplacements" avec une icône appropriée (ex. `Icons.shelves` ou `Icons.inventory_2`)

#### Scenario: Onglet visible sur Android
- **WHEN** l'app est ouverte sur Android (Mode 1 ou Mode 2)
- **THEN** la barre du bas affiche une icône "Emplacements"

---

### Requirement: Arbre hiérarchique des emplacements avec stats
L'écran Emplacements SHALL afficher la liste des emplacements de Niveau 1, chacun accompagné de stats au format `N bouteilles (NN €)`. Les emplacements sont triés alphabétiquement. La valeur monétaire est la somme des `prix_achat` non-nuls des bouteilles en stock de ce nœud. Si aucune bouteille n'a de prix renseigné, le format est `N bouteilles`.

#### Scenario: Affichage initial sans toggle
- **WHEN** l'utilisateur ouvre l'onglet Emplacements, toggle "Inclure sous-emplacements" désactivé
- **THEN** chaque nœud de Niveau 1 affiche le compte et la valeur des bouteilles dont l'emplacement correspond exactement à ce nœud (ex. `Cave` sans `Cave > Casier A`)

#### Scenario: Stats avec toggle activé
- **WHEN** l'utilisateur active le toggle "Inclure sous-emplacements"
- **THEN** chaque nœud de Niveau 1 affiche le compte et la valeur agrégés de toutes les bouteilles dont l'emplacement commence par ce nœud (ex. `Cave` + `Cave > Casier A > Rangée 1`, etc.)

#### Scenario: Prix d'achat partiellement renseigné
- **WHEN** un nœud contient 5 bouteilles dont 3 ont un `prix_achat` et 2 n'en ont pas
- **THEN** le stat affiche `5 bouteilles (NN €)` avec NN = somme des 3 prix renseignés uniquement

---

### Requirement: Navigation dans l'arbre par tap
L'utilisateur SHALL pouvoir naviguer dans l'arbre en tapant sur un nœud parent pour voir ses enfants, niveau par niveau.

#### Scenario: Tap sur un nœud parent avec enfants
- **WHEN** l'utilisateur tape sur un nœud Niveau 1 qui possède des enfants (ex. `Cave > Casier A` existe)
- **THEN** l'app affiche un nouvel écran listant les enfants directs de ce nœud (Niveau 2), avec leurs stats respectives et le même toggle "Inclure sous-emplacements"

#### Scenario: Retour arrière dans l'arbre
- **WHEN** l'utilisateur est dans un écran enfant et appuie sur "Retour"
- **THEN** l'app revient à l'écran parent précédent

#### Scenario: Nœud Niveau 1 sans enfants (emplacement feuille directe)
- **WHEN** l'utilisateur tape sur un nœud Niveau 1 dont toutes les bouteilles ont cet emplacement exact (pas de sous-nœuds)
- **THEN** l'app affiche directement la liste des bouteilles de ce nœud (comportement feuille)

---

### Requirement: Liste de bouteilles au nœud feuille
En tapant sur un nœud qui n'a pas d'enfants (feuille), l'app SHALL afficher la liste des bouteilles en stock dont l'emplacement correspond à ce nœud, avec les mêmes actions que la vue stock.

#### Scenario: Affichage des bouteilles d'un nœud feuille
- **WHEN** l'utilisateur tape sur un nœud feuille (ex. `Cave > Casier A > Rangée 1`)
- **THEN** l'app affiche la liste des bouteilles en stock ayant cet emplacement exact, dans le même format que la vue stock

#### Scenario: Actions disponibles en mode écriture
- **WHEN** l'app est en mode écriture (SyncIdle ou Mode 1) et l'utilisateur tape sur une bouteille dans la liste
- **THEN** le BottomSheet d'actions s'affiche (Consommer, Consulter la fiche, Déplacer, Modifier la fiche) — même comportement que la vue stock

#### Scenario: Actions en mode lecture seule
- **WHEN** l'app est en SyncReadOnly et l'utilisateur tape sur une bouteille dans la liste
- **THEN** le BottomSheet affiche "Mode lecture seule — modifications indisponibles" et le bouton Fermer uniquement

#### Scenario: Multi-sélection en mode écriture
- **WHEN** l'utilisateur effectue un appui long sur une bouteille de la liste (mode écriture)
- **THEN** le mode sélection s'active avec la BulkActionBar (Déplacer / Consommer), identique à la vue stock

#### Scenario: Multi-sélection désactivée en lecture seule
- **WHEN** l'app est en SyncReadOnly
- **THEN** l'appui long sur une bouteille est ignoré (pas d'entrée en mode sélection)

#### Scenario: Liste avec toggle "Inclure sous-emplacements" activé sur un nœud parent
- **WHEN** l'utilisateur active le toggle sur un nœud parent puis tape dessus pour voir la liste
- **THEN** la liste affiche toutes les bouteilles dont l'emplacement commence par ce nœud (match préfixe), pas uniquement l'emplacement exact

---

### Requirement: Toggle "Inclure sous-emplacements"
Chaque écran de l'arbre SHALL afficher un toggle "Inclure sous-emplacements" (désactivé par défaut) qui modifie le calcul des stats et la liste bouteilles des nœuds.

#### Scenario: Activation du toggle
- **WHEN** l'utilisateur active le toggle sur un écran de l'arbre
- **THEN** les stats de tous les nœuds de cet écran se recalculent pour inclure les sous-emplacements ; le toggle reste actif lors de la navigation vers les enfants

#### Scenario: Réinitialisation à l'ouverture de l'onglet
- **WHEN** l'utilisateur quitte l'onglet Emplacements puis y revient
- **THEN** le toggle est réinitialisé à "désactivé"
