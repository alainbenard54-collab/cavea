## MODIFIED Requirements

### Requirement: Répartition multi-emplacement
La section répartition SHALL permettre de définir des groupes `(quantité, emplacement)`. La somme des quantités SHALL être strictement égale à la quantité totale déclarée avant toute confirmation.

#### Scenario: Ajout d'un groupe de répartition
- **WHEN** l'utilisateur clique "+ Ajouter un emplacement"
- **THEN** une nouvelle ligne `(quantité, emplacement)` apparaît dans la section répartition

#### Scenario: Suppression d'un groupe
- **WHEN** l'utilisateur clique le bouton de suppression sur une ligne (absent si un seul groupe)
- **THEN** la ligne est retirée ; la somme est recalculée

#### Scenario: Contrainte somme == total
- **WHEN** la somme des quantités de répartition ne correspond pas à la quantité totale
- **THEN** un indicateur visuel signale l'écart (`Assignées : X / Y ⚠`) en rouge et la confirmation est bloquée
- **WHEN** la somme est correcte
- **THEN** l'indicateur est vert (`Assignées : X / X ✓`) et le bouton Confirmer est actif si le reste du formulaire est valide

#### Scenario: Validation format emplacement
- **WHEN** un emplacement saisi ne respecte pas le format hiérarchique (`Niveau1` ou `Niveau1 > Niveau2 > Niveau3` ; chaque niveau : lettres dont accentuées, chiffres, espaces internes, underscore `_`, tiret `-` — doit commencer par un caractère alphanumérique)
- **THEN** un message d'erreur s'affiche sous le champ, la confirmation est bloquée

#### Scenario: Autocomplétion emplacement
- **WHEN** l'utilisateur saisit des caractères dans un champ emplacement
- **THEN** les emplacements existants en base (stock uniquement) correspondants sont proposés en suggestion inline
