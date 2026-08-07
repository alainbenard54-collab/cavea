## MODIFIED Requirements

### Requirement: Action Déplacer
L'application SHALL permettre de modifier l'emplacement d'une bouteille sans la sortir du stock. Le champ SHALL proposer une autocomplétion sur les emplacements existants en base.

#### Scenario: Déplacement valide
- **WHEN** l'utilisateur saisit ou sélectionne un emplacement et confirme
- **THEN** `emplacement` est mis à jour, `date_sortie` reste null, la bouteille reste en stock

#### Scenario: Autocomplétion emplacement
- **WHEN** l'utilisateur commence à saisir un emplacement
- **THEN** les emplacements existants en base correspondants sont proposés en suggestion (liste inline sous le champ)

#### Scenario: Emplacement invalide
- **WHEN** l'utilisateur confirme un emplacement ne respectant pas le format hiérarchique
- **THEN** un message d'erreur s'affiche sous le champ, la sauvegarde est bloquée

**Format emplacement** : `Niveau1` ou `Niveau1 > Niveau2 > …`. Chaque niveau : lettres (y compris accentuées), chiffres, espaces internes, underscore `_`, tiret `-` — doit commencer par un caractère alphanumérique. Séparateur obligatoire : ` > ` (espace-chevron-espace). Exemples valides : `Cave`, `Cave principale`, `Cave > Étagère 3`, `Cave > Rangée A > Position 2`, `Liebherr Vinothek > sortie_réfrigérateur ou habitat`.
