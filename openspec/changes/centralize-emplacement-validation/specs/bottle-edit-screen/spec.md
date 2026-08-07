## MODIFIED Requirements

### Requirement: Validation du format emplacement
Le champ `emplacement` SHALL valider le format hiérarchique : `Niveau1` ou `Niveau1 > Niveau2 > …`. Chaque niveau : lettres (y compris accentuées), chiffres, espaces internes, underscore `_`, tiret `-` — commence par un caractère alphanumérique. Séparateur obligatoire : ` > `.

#### Scenario: Emplacement invalide bloqué
- **WHEN** l'utilisateur saisit un emplacement ne respectant pas le format et tente de sauvegarder
- **THEN** un message d'erreur s'affiche sous le champ et la sauvegarde est bloquée
