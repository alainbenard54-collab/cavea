### Requirement: BottomSheet d'actions rapides
L'application SHALL afficher un BottomSheet modal lors d'un clic sur une ligne de la vue stock. Ce BottomSheet SHALL proposer les actions dans l'ordre suivant : Consommer, Consulter la fiche, Déplacer, Modifier la fiche, Annuler.

#### Scenario: Ouverture du BottomSheet
- **WHEN** l'utilisateur clique sur une ligne de la liste ou du tableau stock
- **THEN** un BottomSheet s'ouvre avec le nom de la bouteille en titre et les 5 actions dans l'ordre : Consommer, Consulter la fiche, Déplacer, Modifier la fiche, Annuler

#### Scenario: Fermeture par Annuler ou swipe
- **WHEN** l'utilisateur appuie sur "Annuler" ou fait un swipe vers le bas
- **THEN** le BottomSheet se ferme sans modification

---

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

**Format emplacement** : `Niveau1` ou `Niveau1 > Niveau2 > …`. Chaque niveau : lettres (y compris accentuées), chiffres, espaces internes — doit commencer par un caractère alphanumérique. Séparateur obligatoire : ` > ` (espace-chevron-espace). Exemples valides : `Cave`, `Cave principale`, `Cave > Étagère 3`, `Cave > Rangée A > Position 2`.

---

### Requirement: Action Consommer
L'application SHALL permettre de sortir une bouteille du stock en enregistrant une date de consommation, une note optionnelle et un commentaire optionnel.

#### Scenario: Consommation à la date du jour
- **WHEN** l'utilisateur confirme sans modifier la date
- **THEN** `date_sortie` = date du jour, la bouteille disparaît du stock

#### Scenario: Consommation à une date passée (déclaration tardive)
- **WHEN** l'utilisateur modifie la date via le DatePicker avant de confirmer
- **THEN** `date_sortie` = date choisie

#### Scenario: Enregistrement note et commentaire
- **WHEN** l'utilisateur saisit une note (/10) et/ou un commentaire de dégustation
- **THEN** `note_degus` et `commentaire_degus` sont enregistrés avec `date_sortie`

---

### Requirement: Action Modifier la fiche (interface prête, MVP stub)
L'application SHALL exposer une entrée "Modifier la fiche" dans le BottomSheet. En V1, cette entrée SHALL naviguer vers l'écran d'édition complète `BottleEditScreen` via la route `/bottle-edit/:id`. Le stub "Fonctionnalité à venir" est supprimé.

**Champs protégés — jamais exposés dans le formulaire d'édition :**
- `id` (clé primaire)
- `updated_at` (auto-géré)
- `date_sortie` (uniquement via action Consommer)
- `note_degus` (uniquement via action Consommer)
- `commentaire_degus` (uniquement via action Consommer)

#### Scenario: Clic sur Modifier la fiche (V1)
- **WHEN** l'utilisateur appuie sur "Modifier la fiche" dans le BottomSheet
- **THEN** le BottomSheet se ferme et `BottleEditScreen` s'ouvre avec les données actuelles de la bouteille

---

### Requirement: Action Consulter la fiche
L'application SHALL exposer une action "Consulter la fiche" dans le BottomSheet permettant d'accéder à la vue lecture seule `BottleDetailScreen`. Cette action SHALL être disponible en mode normal ET en mode `SyncReadOnly`.

#### Scenario: Clic sur Consulter la fiche (mode normal)
- **WHEN** l'utilisateur appuie sur "Consulter la fiche" depuis le BottomSheet en mode normal
- **THEN** le BottomSheet se ferme et `BottleDetailScreen` s'ouvre via la route `/bottle/:id`

#### Scenario: Clic sur Consulter la fiche (mode SyncReadOnly)
- **WHEN** l'utilisateur appuie sur "Consulter la fiche" depuis le BottomSheet en mode `SyncReadOnly`
- **THEN** le BottomSheet se ferme et `BottleDetailScreen` s'ouvre via la route `/bottle/:id`

---

### Requirement: BottomSheet en mode SyncReadOnly avec accès à la fiche
En mode `SyncReadOnly`, le BottomSheet SHALL afficher uniquement l'action "Consulter la fiche" et le bouton "Fermer". Les actions Consommer, Déplacer et Modifier la fiche SHALL rester cachées.

#### Scenario: BottomSheet SyncReadOnly
- **WHEN** le BottomSheet s'ouvre alors que `SyncService` est en état `SyncReadOnly`
- **THEN** seules les options "Consulter la fiche" et "Fermer" sont visibles ; Consommer, Déplacer et Modifier la fiche sont absentes

#### Scenario: Navigation fiche depuis SyncReadOnly
- **WHEN** l'utilisateur appuie sur "Consulter la fiche" en mode `SyncReadOnly`
- **THEN** `BottleDetailScreen` s'ouvre normalement (la lecture seule ne bloque pas la consultation)
