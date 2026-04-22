### Requirement: BottomSheet d'actions rapides
L'application SHALL afficher un BottomSheet modal lors d'un clic sur une ligne de la vue stock. Ce BottomSheet SHALL proposer les actions : Déplacer, Consommer, Modifier la fiche, Annuler.

#### Scenario: Ouverture du BottomSheet
- **WHEN** l'utilisateur clique sur une ligne de la liste ou du tableau stock
- **THEN** un BottomSheet s'ouvre avec le nom de la bouteille en titre et les 4 actions disponibles

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
L'application SHALL exposer une entrée "Modifier la fiche" dans le BottomSheet. En MVP, cette entrée SHALL afficher un message "Fonctionnalité à venir". L'implémentation complète est prévue en V1.

**Champs protégés — jamais exposés dans le formulaire d'édition :**
- `id` (clé primaire)
- `updated_at` (auto-géré)
- `date_sortie` (uniquement via action Consommer)
- `note_degus` (uniquement via action Consommer)
- `commentaire_degus` (uniquement via action Consommer)

#### Scenario: Clic sur Modifier la fiche (MVP)
- **WHEN** l'utilisateur appuie sur "Modifier la fiche" en MVP
- **THEN** un message "Fonctionnalité à venir" est affiché (SnackBar ou dialog)

#### Scenario: Clic sur Modifier la fiche (V1)
- **WHEN** l'utilisateur appuie sur "Modifier la fiche" en V1
- **THEN** l'écran d'édition complète s'ouvre avec tous les champs non protégés éditables
