## MODIFIED Requirements

### Requirement: Parsing et validation du CSV
L'application SHALL parser le fichier CSV ligne par ligne avec le séparateur choisi par l'utilisateur. La première ligne SHALL être traitée comme en-tête. Les colonnes SHALL être identifiées par leur nom (insensible à la casse, tolérance aux espaces). Les lignes mal formées SHALL être comptées comme erreurs et ignorées sans bloquer l'import. Le BOM UTF-8 éventuel en début de fichier SHALL être retiré automatiquement.

Le champ `emplacement`, quand renseigné, SHALL respecter le même format hiérarchique que partout ailleurs dans l'application (`Niveau1` ou `Niveau1 > Niveau2 > …` ; chaque niveau : lettres dont accentuées, chiffres, espaces internes, underscore `_`, tiret `-` — doit commencer par un caractère alphanumérique).

#### Scenario: Fichier valide
- **WHEN** le fichier contient des lignes avec toutes les colonnes attendues
- **THEN** chaque ligne est parsée en un objet `Bouteille` candidat à l'insertion

#### Scenario: Ligne avec colonnes manquantes
- **WHEN** une ligne ne contient pas les colonnes obligatoires (`domaine`, `appellation`, `millesime`, `couleur`)
- **THEN** la ligne est comptée comme erreur et ignorée

#### Scenario: Ligne avec emplacement au format invalide
- **WHEN** la colonne `emplacement` d'une ligne est renseignée mais ne respecte pas le format hiérarchique attendu
- **THEN** la ligne est comptée comme erreur et ignorée (les autres lignes du fichier continuent d'être traitées), et le message d'erreur associé à cette ligne mentionne explicitement que c'est le champ `emplacement` qui est invalide (pas un message générique de type "champ invalide")
