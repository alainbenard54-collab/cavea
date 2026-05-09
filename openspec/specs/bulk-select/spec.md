## ADDED Requirements

### Requirement: Entrée en mode sélection par appui long
L'application SHALL entrer en mode sélection multiple quand l'utilisateur effectue un appui long sur une ligne de la vue stock. La bouteille cible SHALL être automatiquement sélectionnée lors de l'entrée en mode sélection.

#### Scenario: Appui long sur une ligne
- **WHEN** l'utilisateur effectue un appui long sur une ligne de la liste ou du tableau stock
- **THEN** le mode sélection est activé, la bouteille concernée est cochée, et les checkboxes apparaissent sur toutes les lignes visibles

#### Scenario: Appui long ignoré si déjà en mode sélection
- **WHEN** le mode sélection est actif et l'utilisateur effectue un appui long sur une ligne
- **THEN** le comportement est identique à un tap simple (bascule de la sélection)

---

### Requirement: Bascule de sélection par tap en mode sélection
En mode sélection, l'application SHALL remplacer le comportement du tap simple (ouverture du BottomSheet) par une bascule de la case à cocher de la ligne.

#### Scenario: Tap sur une ligne non sélectionnée en mode sélection
- **WHEN** le mode sélection est actif et l'utilisateur tape sur une ligne non cochée
- **THEN** la ligne est ajoutée à la sélection, sa checkbox est cochée

#### Scenario: Tap sur une ligne sélectionnée en mode sélection
- **WHEN** le mode sélection est actif et l'utilisateur tape sur une ligne cochée
- **THEN** la ligne est retirée de la sélection, sa checkbox est décochée

#### Scenario: Tap normal en dehors du mode sélection
- **WHEN** le mode sélection est inactif et l'utilisateur tape sur une ligne
- **THEN** le BottomSheet d'actions unitaires s'ouvre (comportement inchangé)

---

### Requirement: Sortie du mode sélection
L'application SHALL quitter le mode sélection et vider la sélection courante quand l'utilisateur appuie sur "Annuler" dans la barre d'actions contextuelle.

#### Scenario: Annuler la sélection
- **WHEN** l'utilisateur appuie sur "Annuler" dans la barre d'actions contextuelle
- **THEN** le mode sélection est désactivé, toutes les checkboxes disparaissent, le BottomSheet unitaire redevient actif sur tap

#### Scenario: Retour à la sélection normale après action
- **WHEN** une action en lot (Déplacer ou Consommer) est confirmée et exécutée
- **THEN** le mode sélection est automatiquement désactivé et la sélection est vidée

---

### Requirement: Compteur de sélection
La barre d'actions contextuelle SHALL afficher le nombre de bouteilles actuellement sélectionnées.

#### Scenario: Affichage du compteur
- **WHEN** le mode sélection est actif avec N bouteilles sélectionnées
- **THEN** la barre contextuelle affiche "N bouteille(s) sélectionnée(s)"

#### Scenario: Mise à jour dynamique du compteur
- **WHEN** l'utilisateur coche ou décoche une ligne en mode sélection
- **THEN** le compteur se met à jour immédiatement

---

### Requirement: Checkboxes sur les lignes en mode sélection
En mode sélection, chaque ligne de la vue stock (liste et tableau desktop) SHALL afficher une checkbox indiquant son état de sélection.

#### Scenario: Checkbox visible en mode sélection
- **WHEN** le mode sélection est actif
- **THEN** chaque ligne affiche une checkbox à gauche, cochée si la bouteille est dans la sélection, décochée sinon

#### Scenario: Checkbox absente en mode normal
- **WHEN** le mode sélection est inactif
- **THEN** aucune checkbox n'est affichée sur les lignes
