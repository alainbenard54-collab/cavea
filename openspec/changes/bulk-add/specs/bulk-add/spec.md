## ADDED Requirements

### Requirement: Formulaire d'ajout en lot
L'application SHALL fournir un écran d'ajout manuel accessible depuis la navigation principale. Le formulaire SHALL exposer tous les champs non-protégés de la bouteille et permettre d'indiquer une quantité totale avec une répartition multi-emplacement.

**Champs obligatoires :** `domaine`, `appellation`, `millesime`, `couleur`.
**Champs optionnels :** `cru`, `contenance` (défaut "75 cl"), `prix_achat`, `garde_min`, `garde_max`, `commentaire_entree`, `fournisseur_nom`, `fournisseur_infos`, `producteur`, `date_entree` (défaut = aujourd'hui).

#### Scenario: Accès au formulaire
- **WHEN** l'utilisateur sélectionne "Ajouter" dans la navigation
- **THEN** l'écran d'ajout s'ouvre avec le formulaire vide, date_entree pré-remplie à aujourd'hui, et contenance pré-remplie à "75 cl"

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

---

### Requirement: Répartition multi-emplacement
La section répartition SHALL permettre de définir des groupes `(quantité, emplacement)`. La somme des quantités SHALL être strictement égale à la quantité totale déclarée avant toute confirmation.

#### Scenario: Ajout d'un groupe de répartition
- **WHEN** l'utilisateur clique "+ Ajouter un emplacement"
- **THEN** une nouvelle ligne `(quantité, emplacement)` apparaît dans la section répartition

#### Scenario: Suppression d'un groupe
- **WHEN** l'utilisateur clique le bouton de suppression sur une ligne (absent si un seul groupe)
- **THEN** la ligne est retirée ; la somme est recalculée

#### Scenario: Contrainte somme == total
- **WHEN** la somme des quantités de répartition ne correspond pas à la quantité totale
- **THEN** un indicateur visuel signale l'écart (`Assignées : X / Y ⚠`) en rouge et la confirmation est bloquée
- **WHEN** la somme est correcte
- **THEN** l'indicateur est vert (`Assignées : X / X ✓`) et le bouton Confirmer est actif si le reste du formulaire est valide

#### Scenario: Validation format emplacement
- **WHEN** un emplacement saisi ne respecte pas le format hiérarchique (`Niveau1` ou `Niveau1 > Niveau2 > Niveau3`)
- **THEN** un message d'erreur s'affiche sous le champ, la confirmation est bloquée

#### Scenario: Autocomplétion emplacement
- **WHEN** l'utilisateur saisit des caractères dans un champ emplacement
- **THEN** les emplacements existants en base (stock uniquement) correspondants sont proposés en suggestion inline

---

### Requirement: Validation de la garde
La cohérence des données de garde SHALL être vérifiée avant insertion.

#### Scenario: Incohérence garde_min > garde_max
- **WHEN** l'utilisateur confirme avec garde_min et garde_max renseignés et garde_min > garde_max
- **THEN** un message d'erreur s'affiche (snackbar), l'insertion est bloquée

#### Scenario: Garde non renseignée — avertissement
- **WHEN** l'utilisateur confirme avec garde_min ou garde_max absent
- **THEN** un dialogue avertit que la maturité ne pourra pas être calculée
- **WHEN** l'utilisateur confirme dans le dialogue ("Confirmer sans garde")
- **THEN** l'insertion procède normalement
- **WHEN** l'utilisateur choisit "Retour — saisir la garde"
- **THEN** le dialogue se ferme et le formulaire reste visible sans insertion

---

### Requirement: Confirmation et insertion en lot
L'application SHALL insérer les N bouteilles en une transaction atomique. Chaque bouteille SHALL recevoir un UUID distinct. En cas d'erreur, aucune bouteille ne doit être créée.

#### Scenario: Insertion réussie
- **WHEN** l'utilisateur confirme un formulaire valide (champs obligatoires + répartition correcte + garde cohérente)
- **THEN** N bouteilles identiques sont créées avec des UUID distincts, chacune avec son emplacement selon la répartition, et l'écran revient au stock

#### Scenario: Insertion avec un seul emplacement
- **WHEN** la répartition contient un seul groupe couvrant toutes les bouteilles
- **THEN** toutes les bouteilles reçoivent le même emplacement

#### Scenario: Annulation
- **WHEN** l'utilisateur quitte l'écran sans confirmer
- **THEN** aucune bouteille n'est créée
