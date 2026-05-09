## ADDED Requirements

### Requirement: Ouverture de l'écran d'édition
L'application SHALL naviguer vers l'écran `BottleEditScreen` depuis le BottomSheet d'actions. L'écran SHALL se charger en plein écran sans barre de navigation, avec un bouton de retour.

#### Scenario: Navigation depuis le BottomSheet
- **WHEN** l'utilisateur appuie sur "Modifier la fiche" dans le BottomSheet
- **THEN** le BottomSheet se ferme et `BottleEditScreen` s'ouvre avec les données actuelles de la bouteille pré-remplies

#### Scenario: Chargement des données actuelles
- **WHEN** `BottleEditScreen` s'ouvre pour une bouteille donnée
- **THEN** tous les champs éditables affichent les valeurs actuellement enregistrées en base

### Requirement: Champs éditables — liste exhaustive
Le formulaire d'édition SHALL exposer exactement les champs non protégés suivants : `domaine`, `appellation`, `millesime`, `couleur`, `cru`, `contenance`, `emplacement`, `date_entree`, `prix_achat`, `garde_min`, `garde_max`, `commentaire_entree`, `fournisseur_nom`, `fournisseur_infos`, `producteur`. Les champs protégés (`id`, `updated_at`, `date_sortie`, `note_degus`, `commentaire_degus`) ne SHALL jamais apparaître dans ce formulaire.

#### Scenario: Champs protégés absents
- **WHEN** l'utilisateur ouvre `BottleEditScreen`
- **THEN** aucun champ pour `id`, `updated_at`, `date_sortie`, `note_degus`, `commentaire_degus` n'est visible

#### Scenario: Tous les champs éditables présents
- **WHEN** l'utilisateur ouvre `BottleEditScreen`
- **THEN** les 15 champs non protégés sont affichés et éditables

### Requirement: Autocomplétion sur les champs texte
Les champs `domaine`, `appellation`, `cru`, `contenance`, `fournisseur_nom` SHALL proposer une autocomplétion sur les valeurs existantes en base (toutes bouteilles, stock et consommées). Le champ `emplacement` SHALL proposer une autocomplétion sur les emplacements existants en stock.

#### Scenario: Autocomplétion domaine
- **WHEN** l'utilisateur saisit des caractères dans le champ domaine
- **THEN** les domaines existants en base contenant la saisie sont proposés en suggestions

#### Scenario: Autocomplétion emplacement
- **WHEN** l'utilisateur saisit des caractères dans le champ emplacement
- **THEN** les emplacements existants en stock correspondants sont proposés

### Requirement: Couleur, cru et contenance via DropdownMenu filtrable
Les champs `couleur`, `cru` et `contenance` SHALL utiliser un `DropdownMenu` avec `enableFilter: true`, identique au composant utilisé dans l'écran d'ajout en lot. L'utilisateur SHALL pouvoir saisir une valeur libre non présente dans la liste (permettant de créer de nouvelles couleurs ou crus). `couleur` est obligatoire et SHALL afficher une erreur si vide. `cru` et `contenance` sont optionnels. Si la couleur actuelle de la bouteille n'est pas dans `refCouleurs`, elle SHALL être incluse dans la liste pour éviter toute perte de données.

#### Scenario: Couleur présente dans refCouleurs
- **WHEN** la couleur de la bouteille est dans `refCouleurs`
- **THEN** le DropdownMenu affiche cette couleur pré-remplie

#### Scenario: Saisie d'une nouvelle couleur
- **WHEN** l'utilisateur saisit une couleur non présente dans la liste de référence
- **THEN** la valeur saisie est acceptée et sauvegardée

#### Scenario: Cru et contenance librement modifiables
- **WHEN** l'utilisateur saisit un cru ou une contenance non présent dans la liste
- **THEN** la valeur saisie est acceptée et sauvegardée

### Requirement: Date d'entrée via sélecteur de date
Le champ `date_entree` SHALL être éditable via un sélecteur de date (DatePicker), affiché comme un bouton avec la date formatée en DD/MM/YYYY. La valeur est stockée au format ISO YYYY-MM-DD.

#### Scenario: Modification de la date d'entrée
- **WHEN** l'utilisateur appuie sur le bouton de date d'entrée
- **THEN** un DatePicker s'ouvre avec la date actuelle pré-sélectionnée et la date choisie remplace la valeur affichée

### Requirement: Bouton de restauration sur les champs autocomplétion
Les champs `domaine`, `appellation`, `emplacement`, `fournisseur_nom` SHALL afficher une icône de restauration (↩) dans leur suffixe lorsque la valeur a été modifiée par rapport à la valeur chargée depuis la base. Un appui sur cette icône SHALL restaurer la valeur d'origine sans fermer l'écran.

#### Scenario: Restauration de la valeur d'origine
- **WHEN** l'utilisateur a modifié la valeur d'un champ autocomplete et appuie sur ↩
- **THEN** le champ revient à la valeur initialement chargée depuis la base, sans toucher aux autres champs

### Requirement: Fermeture sans clavier résiduel
L'action "Annuler" SHALL masquer le clavier virtuel avant de fermer l'écran, sur tous les OS.

#### Scenario: Annulation sur Android avec clavier ouvert
- **WHEN** l'utilisateur appuie sur "Annuler" alors qu'un champ a le focus
- **THEN** le clavier se ferme et l'écran se ferme, sans laisser le clavier visible sur l'écran précédent

### Requirement: Validation garde_min ≤ garde_max
Si `garde_min` et `garde_max` sont tous deux renseignés, le formulaire SHALL bloquer la sauvegarde si `garde_min > garde_max` et afficher un message d'erreur.

#### Scenario: Garde incohérente bloquée
- **WHEN** l'utilisateur saisit garde_min > garde_max et tente de sauvegarder
- **THEN** un message d'erreur s'affiche sous les champs de garde et la sauvegarde est bloquée

#### Scenario: Garde partielle — confirmation requise
- **WHEN** un seul des deux champs garde est renseigné et l'utilisateur tente de sauvegarder
- **THEN** un dialogue avertit que la maturité ne pourra pas être calculée, avec les options "Confirmer" ou "Retour"

### Requirement: Validation du format emplacement
Le champ `emplacement` SHALL valider le format hiérarchique : `Niveau1` ou `Niveau1 > Niveau2 > …`. Chaque niveau commence par un caractère alphanumérique. Séparateur obligatoire : ` > `.

#### Scenario: Emplacement invalide bloqué
- **WHEN** l'utilisateur saisit un emplacement ne respectant pas le format et tente de sauvegarder
- **THEN** un message d'erreur s'affiche sous le champ et la sauvegarde est bloquée

### Requirement: Sauvegarde et retour
À la confirmation, l'application SHALL persister les modifications via `BouteilleDao.updateBouteille()`, mettre à jour `updated_at` automatiquement, puis retourner à l'écran précédent.

#### Scenario: Sauvegarde réussie
- **WHEN** l'utilisateur appuie sur "Enregistrer" avec des données valides
- **THEN** `BouteilleDao.updateBouteille()` est appelé, `updated_at` est mis à jour, et l'écran se ferme

#### Scenario: Retour sans sauvegarde
- **WHEN** l'utilisateur appuie sur le bouton retour ou "Annuler"
- **THEN** aucune modification n'est persistée et l'écran se ferme
