## MODIFIED Requirements

### Requirement: Formulaire d'ajout en lot
Le formulaire d'ajout en lot SHALL permettre de saisir les informations communes à toutes les bouteilles à créer ainsi que la répartition par emplacement.

**Champs obligatoires :** `domaine`, `appellation`, `millesime`, `couleur`.
**Champs optionnels :** `cru`, `contenance` (défaut depuis `ConfigService.contenanceDefaut`), `prix_achat`, `garde_min`, `garde_max`, `commentaire_entree`, `fournisseur_nom`, `fournisseur_infos`, `producteur`, `date_entree` (défaut = aujourd'hui).

#### Scenario: Accès au formulaire
- **WHEN** l'utilisateur sélectionne "Ajouter" dans la navigation
- **THEN** l'écran d'ajout s'ouvre avec le formulaire vide, `date_entree` pré-remplie à aujourd'hui, `contenance` pré-remplie depuis `ConfigService.contenanceDefaut`, et `couleur` pré-sélectionnée depuis `ConfigService.couleurDefaut` si la valeur est présente dans la liste chargée depuis la base

#### Scenario: Valeur par défaut couleur absente en base
- **WHEN** `ConfigService.couleurDefaut` retourne une valeur qui n'existe pas dans la liste des couleurs chargées depuis la base
- **THEN** aucune couleur n'est pré-sélectionnée (l'utilisateur sélectionne manuellement)

#### Scenario: Validation des champs obligatoires
- **WHEN** l'utilisateur confirme sans avoir rempli tous les champs obligatoires
- **THEN** les champs manquants sont signalés ("Obligatoire"), la confirmation est bloquée

#### Scenario: Autocomplétion champs texte
- **WHEN** l'utilisateur saisit au moins un caractère dans domaine, appellation, cru, contenance ou fournisseur_nom
- **THEN** une liste de suggestions inline filtre les valeurs existantes en base (toutes bouteilles — stock ET consommées) par correspondance plein texte (contient, insensible à la casse)
- **WHEN** l'utilisateur clique une suggestion
- **THEN** le champ est rempli avec la valeur sélectionnée, la liste disparaît

#### Scenario: Couleur — dropdown + saisie libre
- **WHEN** l'utilisateur ouvre le champ couleur
- **THEN** un dropdown liste les couleurs existantes en base (toutes bouteilles) + "Autre…"
- **WHEN** l'utilisateur sélectionne "Autre…"
- **THEN** le champ bascule en saisie libre avec une icône pour revenir au dropdown
