## MODIFIED Requirements

### Requirement: BouteilleDao — opérations de base
L'application SHALL fournir un DAO `BouteilleDao` exposant : insertion d'une bouteille, mise à jour complète, récupération de toutes les bouteilles en stock (`date_sortie` NULL ou vide), récupération par UUID, une requête filtrée combinant couleur, appellation, millésime et recherche texte, **deux méthodes de mise à jour ciblées pour les actions rapides, et la liste des emplacements distincts pour l'autocomplétion**.

#### Scenario: Déplacement d'une bouteille
- **WHEN** `deplacerBouteille(id, emplacement)` est appelé avec un UUID présent en base
- **THEN** seul le champ `emplacement` est mis à jour ; `date_sortie` reste null, la bouteille reste en stock

#### Scenario: Consommation d'une bouteille
- **WHEN** `consommerBouteille(id, dateSortie: '...', noteDegus: N, commentaireDegus: '...')` est appelé
- **THEN** `date_sortie`, `note_degus` et `commentaire_degus` sont mis à jour ; les autres champs restent inchangés

#### Scenario: Consommation sans note ni commentaire
- **WHEN** `consommerBouteille(id, dateSortie: '...')` est appelé sans note ni commentaire
- **THEN** seul `date_sortie` est enregistré ; `note_degus` et `commentaire_degus` restent null

#### Scenario: Emplacements distincts pour autocomplétion
- **WHEN** `getDistinctEmplacements()` est appelé
- **THEN** retourne la liste des emplacements non vides distincts présents dans le stock courant, triés alphabétiquement
