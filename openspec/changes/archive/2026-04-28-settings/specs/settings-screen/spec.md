## ADDED Requirements

### Requirement: Modification du chemin cave.db (Mode 1)
En Mode 1, l'écran Paramètres SHALL afficher le chemin actuel du dossier contenant `cave.db` et permettre à l'utilisateur de le modifier via un sélecteur de dossier. La section SHALL être masquée en Mode 2.

#### Scenario: Affichage du chemin actuel
- **WHEN** l'utilisateur ouvre l'écran Paramètres en Mode 1
- **THEN** la section "Emplacement de la cave" affiche le chemin du dossier courant (extrait de `configService.config.dbPath`) en lecture seule

#### Scenario: Tap sur "Modifier"
- **WHEN** l'utilisateur tape le bouton "Modifier" dans la section chemin
- **THEN** le sélecteur de dossier natif s'ouvre (`FilePicker.platform.getDirectoryPath()`)

#### Scenario: Nouveau dossier sélectionné
- **WHEN** l'utilisateur sélectionne un dossier dans le file picker
- **THEN** le nouveau chemin est sauvegardé dans SharedPreferences (`configService.save()`), le chemin affiché est mis à jour, et un snackbar "Chemin mis à jour — redémarrez l'application pour appliquer" s'affiche

#### Scenario: Annulation du file picker
- **WHEN** l'utilisateur annule le file picker sans sélectionner de dossier
- **THEN** aucun changement n'est effectué, l'écran reste inchangé

#### Scenario: Section masquée en Mode 2
- **WHEN** l'utilisateur ouvre l'écran Paramètres en Mode 2 (Drive)
- **THEN** la section "Emplacement de la cave" n'est pas affichée

---

### Requirement: Valeurs par défaut du formulaire d'ajout en lot
L'écran Paramètres SHALL permettre de configurer les valeurs par défaut pré-sélectionnées dans le formulaire bulk-add : `couleur_defaut` et `contenance_defaut`.

#### Scenario: Affichage des valeurs actuelles
- **WHEN** l'utilisateur ouvre l'écran Paramètres
- **THEN** la section "Ajout en lot — valeurs par défaut" affiche les valeurs courantes de `couleurDefaut` et `contenanceDefaut` lues depuis `ConfigService`

#### Scenario: Modification de couleur par défaut
- **WHEN** l'utilisateur sélectionne une couleur dans le dropdown "Couleur par défaut"
- **THEN** la valeur est immédiatement sauvegardée dans SharedPreferences via `ConfigService`

#### Scenario: Modification de contenance par défaut
- **WHEN** l'utilisateur modifie le champ "Contenance par défaut"
- **THEN** la valeur est sauvegardée dans SharedPreferences via `ConfigService` à la validation (onFieldSubmitted / perte de focus)

#### Scenario: Valeurs par défaut si non configurées
- **WHEN** aucune valeur n'est configurée dans SharedPreferences
- **THEN** `ConfigService` retourne "Rouge" pour `couleurDefaut` et "75 cl" pour `contenanceDefaut`

---

### Requirement: Placeholder Mode 2 (cloud)
L'écran Paramètres SHALL afficher une section "Configuration cloud" avec un message indiquant que la configuration du service cloud sera disponible dans une version future.

#### Scenario: Affichage du placeholder Mode 2
- **WHEN** l'utilisateur ouvre l'écran Paramètres
- **THEN** la section "Configuration cloud" affiche le texte "Gestion du service cloud — disponible dans une version future" avec l'icône cloud_off, sans aucun bouton actif
