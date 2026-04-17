## MODIFIED Requirements

### Requirement: BouteilleDao — opérations de base
L'application SHALL fournir un DAO `BouteilleDao` exposant : insertion d'une bouteille, mise à jour complète, récupération de toutes les bouteilles en stock (`date_sortie` NULL ou vide), récupération par UUID, **et une requête filtrée combinant couleur, appellation, millésime et recherche texte**.

#### Scenario: Lecture du stock sans filtre
- **WHEN** `watchStock()` est appelé
- **THEN** retourne un Stream des bouteilles dont `date_sortie` est NULL ou vide, trié par `domaine` puis `millesime`

#### Scenario: Lecture filtrée
- **WHEN** `watchStockFiltered(couleur: 'Rouge', millesime: 2015)` est appelé
- **THEN** retourne un Stream des bouteilles rouges de 2015 en stock

#### Scenario: Filtre texte
- **WHEN** `watchStockFiltered(texte: 'margaux')` est appelé
- **THEN** retourne un Stream des bouteilles dont le domaine contient 'margaux' (insensible à la casse)

#### Scenario: Insertion d'une bouteille
- **WHEN** `insertBouteille(bouteille)` est appelé avec un objet valide
- **THEN** la bouteille est persistée et le stream `watchStock()` émet la nouvelle liste

#### Scenario: Mise à jour d'une bouteille existante
- **WHEN** `updateBouteille(bouteille)` est appelé avec un UUID présent en base
- **THEN** tous les champs sont mis à jour et `updated_at` est rafraîchi

#### Scenario: Valeurs distinctes pour les filtres
- **WHEN** `getDistinctCouleurs()`, `getDistinctAppellations()`, `getDistinctMillesimes()` sont appelés
- **THEN** retournent les valeurs uniques présentes dans le stock, triées
