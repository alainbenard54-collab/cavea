## ADDED Requirements

### Requirement: Sélection du fichier CSV via file picker
L'utilisateur SHALL pouvoir choisir son fichier CSV via un file picker natif (pas de chemin codé en dur). Le fichier doit être au format UTF-8, séparateur `;`, avec une ligne d'en-tête correspondant aux colonnes du modèle `bouteilles`.

#### Scenario: Ouverture du file picker
- **WHEN** l'utilisateur clique "Choisir un fichier CSV"
- **THEN** le file picker natif s'ouvre filtré sur `.csv`

#### Scenario: Fichier sélectionné
- **WHEN** l'utilisateur choisit un fichier `.csv` valide
- **THEN** le nom du fichier s'affiche dans l'interface et le bouton "Importer" devient actif

#### Scenario: Annulation du file picker
- **WHEN** l'utilisateur ferme le file picker sans choisir de fichier
- **THEN** l'interface reste inchangée

---

### Requirement: Parsing et validation du CSV
L'application SHALL parser le fichier CSV ligne par ligne. La première ligne SHALL être traitée comme en-tête. Les colonnes SHALL être identifiées par leur nom (insensible à la casse, tolérance aux espaces). Les lignes mal formées SHALL être comptées comme erreurs et ignorées sans bloquer l'import.

#### Scenario: Fichier valide cave_clean.csv
- **WHEN** le fichier contient des lignes avec toutes les colonnes attendues
- **THEN** chaque ligne est parsée en un objet `Bouteille` candidat à l'insertion

#### Scenario: Ligne avec colonnes manquantes
- **WHEN** une ligne ne contient pas les colonnes obligatoires (`domaine`, `appellation`, `millesime`, `couleur`)
- **THEN** la ligne est comptée comme erreur et ignorée

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
