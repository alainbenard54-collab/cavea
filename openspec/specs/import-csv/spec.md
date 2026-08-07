## ADDED Requirements

### Requirement: Sélection du fichier CSV via file picker
L'utilisateur SHALL pouvoir choisir son fichier CSV via un file picker natif (pas de chemin codé en dur). Le fichier doit être au format UTF-8, avec une ligne d'en-tête correspondant aux colonnes du modèle `bouteilles`. Le séparateur SHALL être sélectionnable dans l'interface via un `SegmentedButton` : `;` (défaut), `,`, `Tabulation`. Le séparateur choisi est transmis au parseur avant l'import.

#### Scenario: Ouverture du file picker
- **WHEN** l'utilisateur clique "Choisir un fichier CSV"
- **THEN** le file picker natif s'ouvre filtré sur `.csv`

#### Scenario: Fichier sélectionné
- **WHEN** l'utilisateur choisit un fichier `.csv` valide
- **THEN** le nom du fichier s'affiche dans l'interface et le bouton "Importer" devient actif

#### Scenario: Annulation du file picker
- **WHEN** l'utilisateur ferme le file picker sans choisir de fichier
- **THEN** l'interface reste inchangée

#### Scenario: Séparateur virgule à l'import
- **WHEN** l'utilisateur sélectionne `,` et importe un fichier avec virgule comme séparateur
- **THEN** les colonnes sont correctement parsées

#### Scenario: Séparateur tabulation à l'import
- **WHEN** l'utilisateur sélectionne "Tabulation" et importe un fichier TSV
- **THEN** les colonnes sont correctement parsées

---

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

---

### Requirement: Gestion des UUIDs à l'import
L'application SHALL gérer trois cas selon la valeur de la colonne `id` dans le CSV.

#### Scenario: Colonne id vide
- **WHEN** la colonne `id` d'une ligne est vide ou absente
- **THEN** un UUID v4 est généré pour cette bouteille et elle est insérée

#### Scenario: UUID présent, absent de la base
- **WHEN** la colonne `id` contient un UUID qui n'existe pas encore dans `bouteilles`
- **THEN** la bouteille est insérée avec cet UUID

#### Scenario: UUID présent, déjà en base, case "écraser" non cochée
- **WHEN** la colonne `id` contient un UUID déjà présent et la case "Écraser les existants" est décochée
- **THEN** la ligne est comptée comme ignorée (SKIP) sans modifier la base

#### Scenario: UUID présent, déjà en base, case "écraser" cochée
- **WHEN** la colonne `id` contient un UUID déjà présent et la case "Écraser les existants" est cochée
- **THEN** la bouteille existante est mise à jour avec les valeurs du CSV (UPDATE)

---

### Requirement: Rapport d'import
À la fin de l'import, l'application SHALL afficher un résumé : nombre de lignes insérées, mises à jour, ignorées, et en erreur.

#### Scenario: Import terminé avec succès
- **WHEN** le parsing et l'insertion sont terminés sans erreur fatale
- **THEN** l'interface affiche "X insérées · Y mises à jour · Z ignorées · W erreurs"

#### Scenario: Fichier illisible ou format invalide
- **WHEN** le fichier sélectionné ne peut pas être parsé (encodage, format)
- **THEN** un message d'erreur clair est affiché et aucune donnée n'est modifiée

---

### Requirement: Préservation de updated_at à l'import
Lors d'un import, si la colonne `updated_at` est présente dans le fichier CSV et contient une valeur ISO8601 valide, l'application SHALL utiliser cette valeur (et non `DateTime.now()`). Si la colonne est absente, vide, ou contient une valeur non-ISO8601, l'application SHALL générer `DateTime.now()` comme valeur par défaut.

#### Scenario: updated_at valide dans le CSV
- **WHEN** une ligne contient `updated_at` avec une valeur ISO8601 valide
- **THEN** la bouteille insérée ou mise à jour conserve cette valeur de `updated_at`

#### Scenario: updated_at absent du CSV
- **WHEN** le fichier importé ne contient pas de colonne `updated_at`
- **THEN** `updated_at` est initialisé à `DateTime.now()` pour chaque bouteille importée

#### Scenario: updated_at invalide dans le CSV
- **WHEN** une ligne contient `updated_at` avec une valeur non-ISO8601
- **THEN** `updated_at` est initialisé à `DateTime.now()` (comportement silencieux, pas d'erreur)
