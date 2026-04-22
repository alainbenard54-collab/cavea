## MODIFIED Requirements

### Requirement: Lignes cliquables ouvrant le BottomSheet d'actions
Chaque ligne de la liste mobile et du tableau desktop SHALL être cliquable. Un clic SHALL ouvrir le BottomSheet d'actions rapides (`bottle-actions`) avec la bouteille correspondante en contexte.

#### Scenario: Clic sur une ligne (desktop)
- **WHEN** l'utilisateur clique sur une ligne du tableau stock (desktop)
- **THEN** le BottomSheet d'actions s'ouvre avec le domaine et le millésime de la bouteille en titre

#### Scenario: Appui sur une ligne (mobile)
- **WHEN** l'utilisateur appuie sur une ligne de la liste mobile
- **THEN** le BottomSheet d'actions s'ouvre avec les mêmes 4 actions disponibles
