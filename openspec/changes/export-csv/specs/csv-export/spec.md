## ADDED Requirements

### Requirement: Accès depuis la navigation principale
L'onglet "Import CSV" (index 4) SHALL être renommé "Données" avec l'icône `Icons.import_export`. Il SHALL être retiré de `_writeOnlyIndices` afin d'être accessible en SyncReadOnly. Le badge cadenas SHALL apparaître sur le bouton "Importer" interne à l'écran (et non plus sur l'onglet lui-même) quand SyncReadOnly est actif.

#### Scenario: Accès en mode écriture
- **WHEN** l'utilisateur navigue vers l'onglet "Données" en mode écriture
- **THEN** l'écran affiche les deux sections Import et Export, toutes deux actives

#### Scenario: Accès en SyncReadOnly
- **WHEN** l'utilisateur navigue vers l'onglet "Données" en SyncReadOnly
- **THEN** l'écran est accessible, la section Export est active, la section Import affiche le bouton "Importer" grisé

---

### Requirement: Sélection du scope d'export
L'écran Export SHALL proposer deux options mutuellement exclusives via un `SegmentedButton` : **Stock uniquement** (bouteilles sans `date_sortie`) et **Tout** (stock + consommées). L'option par défaut SHALL être "Stock uniquement".

#### Scenario: Scope "Stock uniquement" sélectionné
- **WHEN** l'utilisateur choisit "Stock uniquement" et lance l'export
- **THEN** le CSV ne contient que les bouteilles dont `date_sortie` est null

#### Scenario: Scope "Tout" sélectionné
- **WHEN** l'utilisateur choisit "Tout" et lance l'export
- **THEN** le CSV contient toutes les bouteilles (stock + consommées)

---

### Requirement: Sélection du séparateur à l'export
L'écran Export SHALL proposer trois options de séparateur via un `SegmentedButton` : `;` (défaut), `,`, `Tabulation`. Le séparateur choisi SHALL s'appliquer à toutes les valeurs du CSV généré.

#### Scenario: Séparateur par défaut
- **WHEN** l'utilisateur ouvre l'écran Export sans modifier le séparateur
- **THEN** le CSV généré utilise `;` comme séparateur

#### Scenario: Séparateur virgule
- **WHEN** l'utilisateur sélectionne `,` et exporte
- **THEN** le CSV généré utilise `,` comme séparateur dans toutes les lignes

#### Scenario: Séparateur tabulation
- **WHEN** l'utilisateur sélectionne "Tabulation" et exporte
- **THEN** le CSV généré utilise `\t` comme séparateur

---

### Requirement: Contenu et format du fichier CSV exporté
Le CSV exporté SHALL contenir toutes les colonnes de la table `bouteilles` dans l'ordre suivant : `id`, `domaine`, `appellation`, `millesime`, `couleur`, `cru`, `contenance`, `emplacement`, `date_entree`, `date_sortie`, `prix_achat`, `garde_min`, `garde_max`, `commentaire_entree`, `note_degus`, `commentaire_degus`, `fournisseur_nom`, `fournisseur_infos`, `producteur`, `updated_at`. Le fichier SHALL être encodé en UTF-8 avec BOM (`﻿`). Les valeurs null SHALL être représentées par un champ vide. Les valeurs contenant le séparateur ou des guillemets SHALL être entourées de guillemets doubles (guillemets internes doublés).

#### Scenario: Colonne updated_at présente
- **WHEN** l'utilisateur exporte
- **THEN** chaque ligne du CSV contient la valeur ISO8601 de `updated_at` pour cette bouteille

#### Scenario: Valeur nulle
- **WHEN** un champ nullable (ex. `date_sortie`) est null pour une bouteille
- **THEN** la cellule correspondante est vide dans le CSV

#### Scenario: Valeur contenant le séparateur
- **WHEN** un champ textuel contient le caractère séparateur choisi
- **THEN** la valeur est entourée de guillemets doubles dans le CSV

#### Scenario: Encodage BOM
- **WHEN** le fichier est ouvert dans Excel ou LibreOffice sans configuration d'encodage
- **THEN** les caractères accentués s'affichent correctement

---

### Requirement: Export sur Windows
Sur Windows, l'export SHALL ouvrir un dialog "Enregistrer sous" via `FilePicker.platform.saveFile()` avec le nom suggéré `cave_YYYY-MM-DD.csv`. Le fichier SHALL être écrit via `dart:io`.

#### Scenario: Chemin choisi par l'utilisateur
- **WHEN** l'utilisateur confirme un chemin dans le dialog
- **THEN** le fichier CSV est écrit à cet emplacement et un snackbar de succès s'affiche

#### Scenario: Annulation du dialog
- **WHEN** l'utilisateur annule le dialog FilePicker
- **THEN** aucun fichier n'est créé, l'écran reste inchangé

#### Scenario: Erreur d'écriture
- **WHEN** l'écriture du fichier échoue (permissions, disque plein)
- **THEN** un snackbar d'erreur s'affiche avec le message de l'exception

---

### Requirement: Export sur Android
Sur Android, l'écran SHALL proposer deux boutons d'export : **"Enregistrer"** (utilise `FilePicker.platform.saveFile()` — dialog système "Enregistrer sous") et **"Partager…"** (utilise `share_plus` — feuille de partage système). Le CSV SHALL être écrit dans un fichier temporaire (`getTemporaryDirectory()`) avant d'être partagé via share_plus.

#### Scenario: Enregistrer via FilePicker
- **WHEN** l'utilisateur appuie sur "Enregistrer" sur Android
- **THEN** le dialog Android "Enregistrer sous" s'ouvre, l'utilisateur peut choisir Downloads ou tout autre emplacement accessible

#### Scenario: Partager via share_plus
- **WHEN** l'utilisateur appuie sur "Partager…"
- **THEN** la feuille de partage système Android s'ouvre avec le fichier CSV en pièce jointe (Drive, e-mail, Bluetooth, etc.)

#### Scenario: Annulation FilePicker Android
- **WHEN** l'utilisateur annule le dialog FilePicker
- **THEN** aucun fichier n'est créé ni partagé

---

### Requirement: Nom de fichier suggéré
Le nom suggéré SHALL suivre le format `cave_YYYY-MM-DD.csv` où la date est celle du jour de l'export.

#### Scenario: Nom par défaut
- **WHEN** le dialog de sauvegarde s'ouvre
- **THEN** le champ nom du fichier est pré-rempli avec `cave_2026-05-11.csv` (date du jour)
