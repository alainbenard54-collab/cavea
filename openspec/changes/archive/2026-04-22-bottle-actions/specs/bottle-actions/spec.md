## ADDED Requirements

### Requirement: BottomSheet d'actions rapides
L'application SHALL afficher un BottomSheet modal lors d'un clic sur une ligne du stock (liste mobile ou tableau desktop). Le BottomSheet SHALL afficher le domaine et le millésime de la bouteille en titre, et proposer 4 actions : Déplacer, Consommer, Modifier la fiche, Annuler.

#### Scenario: Ouverture du BottomSheet depuis le tableau desktop
- **WHEN** l'utilisateur clique sur une ligne du tableau stock (desktop)
- **THEN** le BottomSheet s'ouvre avec le nom de la bouteille en titre et les 4 actions

#### Scenario: Ouverture depuis la liste mobile
- **WHEN** l'utilisateur appuie sur une ligne de la liste mobile
- **THEN** le BottomSheet s'ouvre avec les mêmes 4 actions

#### Scenario: Fermeture sans action
- **WHEN** l'utilisateur appuie sur "Annuler" ou swipe vers le bas
- **THEN** le BottomSheet se ferme sans modification

---

### Requirement: Formulaire Déplacer
L'application SHALL permettre de modifier l'emplacement d'une bouteille. Le champ SHALL proposer une autocomplétion sur les emplacements existants en base.

#### Scenario: Déplacement confirmé
- **WHEN** l'utilisateur saisit ou sélectionne un emplacement et confirme
- **THEN** `emplacement` est mis à jour, `date_sortie` reste null, la bouteille reste en stock

#### Scenario: Autocomplétion emplacement
- **WHEN** l'utilisateur saisit des caractères dans le champ emplacement
- **THEN** les emplacements existants en base contenant ces caractères sont proposés en suggestion

#### Scenario: Annulation du déplacement
- **WHEN** l'utilisateur appuie sur Annuler dans le formulaire
- **THEN** le BottomSheet se ferme sans modification

---

### Requirement: Formulaire Consommer
L'application SHALL permettre de sortir une bouteille du stock. La date de consommation SHALL être pré-remplie avec la date du jour et modifiable. La note et le commentaire SHALL être optionnels.

#### Scenario: Consommation à la date du jour
- **WHEN** l'utilisateur confirme sans modifier la date
- **THEN** `date_sortie` = date du jour au format ISO, la bouteille disparaît du stock

#### Scenario: Consommation à une date passée
- **WHEN** l'utilisateur modifie la date via le DatePicker et confirme
- **THEN** `date_sortie` = date choisie (passée uniquement, pas de date future)

#### Scenario: Enregistrement note et commentaire
- **WHEN** l'utilisateur active le switch note, saisit une valeur et/ou un commentaire
- **THEN** `note_degus` et `commentaire_degus` sont enregistrés avec `date_sortie`

#### Scenario: Consommation sans note ni commentaire
- **WHEN** l'utilisateur confirme sans activer le switch note ni saisir de commentaire
- **THEN** `date_sortie` est enregistrée, `note_degus` et `commentaire_degus` restent null

---

### Requirement: Stub Modifier la fiche (MVP)
L'application SHALL exposer une entrée "Modifier la fiche" dans le BottomSheet. En MVP, cette entrée SHALL afficher un SnackBar "Fonctionnalité à venir".

#### Scenario: Clic sur Modifier la fiche en MVP
- **WHEN** l'utilisateur appuie sur "Modifier la fiche"
- **THEN** le BottomSheet se ferme et un SnackBar affiche "Fonctionnalité à venir"
