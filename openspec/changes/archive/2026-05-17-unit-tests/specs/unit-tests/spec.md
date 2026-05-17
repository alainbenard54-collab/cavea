## Purpose
Tests unitaires et d'intégration couvrant toutes les couches logiques non-UI de la V1 : DAO (méthodes manquantes), parsing/import/export CSV, contrôleurs Riverpod, arbre d'emplacements, formatage localisé.

## ADDED Requirements

### Requirement: Tests DAO — méthodes batch et streams manquants
Les méthodes `deplacerBouteilles`, `consommerBouteilles`, `rehabiliterBouteille`, `watchHistorique`, `watchBouteillesParEmplacement`, `watchLocationStats`, `getBouteilleById`, `updateBouteille`, `getAllDistinct*` et `getDistinctDomaines/Fournisseurs` SHALL être couvertes par des tests d'intégration drift in-memory.

#### Scenario: getBouteilleById — bouteille trouvée
- **WHEN** une bouteille est insérée et `getBouteilleById(id)` est appelé avec son id
- **THEN** la bouteille est retournée avec tous ses champs

#### Scenario: getBouteilleById — bouteille introuvable
- **WHEN** `getBouteilleById('id-inconnu')` est appelé sur une DB vide
- **THEN** la valeur retournée est `null`

#### Scenario: updateBouteille — mise à jour partielle
- **WHEN** une bouteille est insérée puis `updateBouteille` est appelé avec un companion modifiant uniquement le domaine
- **THEN** le domaine est mis à jour et tous les autres champs restent inchangés

#### Scenario: deplacerBouteilles — transaction batch
- **WHEN** `deplacerBouteilles(['b1','b2'], 'Cave B')` est appelé
- **THEN** les deux bouteilles ont `emplacement = 'Cave B'` et `date_sortie` reste null

#### Scenario: consommerBouteilles — transaction batch
- **WHEN** `consommerBouteilles(['b1','b2'], dateSortie: '2026-05-01', noteDegus: 9.0)` est appelé
- **THEN** les deux bouteilles ont `date_sortie = '2026-05-01'`, `note_degus = 9.0`

#### Scenario: rehabiliterBouteille — efface date_sortie et degustation
- **WHEN** une bouteille consommée (avec note et commentaire) est réhabilitée
- **THEN** `date_sortie`, `note_degus`, `commentaire_degus` sont null et la bouteille réapparaît dans le stock

#### Scenario: watchHistorique — triée date_sortie desc, exclut le stock
- **WHEN** 2 bouteilles consommées (dates différentes) et 1 en stock sont en base
- **THEN** le stream retourne les 2 consommées triées par date_sortie desc, sans la bouteille en stock

#### Scenario: watchBouteillesParEmplacement — match exact
- **WHEN** `watchBouteillesParEmplacement('Cave A')` est appelé avec une bouteille en 'Cave A' et une en 'Cave A > Étagère 1'
- **THEN** seule la bouteille 'Cave A' est retournée (match exact, sans sous-emplacements)

#### Scenario: watchBouteillesParEmplacement — includeSublocations
- **WHEN** `watchBouteillesParEmplacement('Cave A', includeSublocations: true)` est appelé
- **THEN** les bouteilles de 'Cave A' ET 'Cave A > Étagère 1' sont retournées

#### Scenario: watchLocationStats — groupé par emplacement, stock uniquement
- **WHEN** 3 bouteilles en stock (2 dans 'Cave A' dont 1 avec prix, 1 dans 'Cave B') et 1 consommée dans 'Cave A'
- **THEN** le stream retourne 2 LocationLeaf : Cave A (count=2, sumPrix partielle) et Cave B (count=1)

#### Scenario: getDistinctDomaines — toutes bouteilles (stock + consommées)
- **WHEN** 2 domaines distincts en stock et 1 domaine supplémentaire consommé
- **THEN** les 3 domaines sont retournés (toutes bouteilles, pas de filtre date_sortie)

#### Scenario: getAllDistinctAppellations — toutes bouteilles
- **WHEN** 2 appellations en stock et 1 appellation dans les consommées
- **THEN** les 3 appellations sont retournées

#### Scenario: getDistinctFournisseurs — exclut les null
- **WHEN** 2 bouteilles avec fournisseur_nom renseigné, 1 avec null
- **THEN** seuls les 2 fournisseurs non-null sont retournés

---

### Requirement: Tests csv_parser — séparateurs, BOM, champs quotés, types
`parseCsv` SHALL être couvert par des tests unitaires purs vérifiant séparateurs, BOM UTF-8, champs quotés, conversions de types et lignes invalides.

#### Scenario: Séparateur point-virgule (défaut)
- **WHEN** un CSV avec séparateur `;` est parsé sans argument separator
- **THEN** les champs sont correctement séparés

#### Scenario: Séparateur virgule
- **WHEN** un CSV avec séparateur `,` est parsé avec `separator: ','`
- **THEN** les champs sont correctement séparés

#### Scenario: Séparateur tabulation
- **WHEN** un CSV avec séparateur `\t` est parsé avec `separator: '\t'`
- **THEN** les champs sont correctement séparés

#### Scenario: BOM UTF-8 retiré automatiquement
- **WHEN** le CSV commence par le BOM `﻿`
- **THEN** le BOM est ignoré et l'en-tête est parsé correctement

#### Scenario: Champ quoté contenant le séparateur
- **WHEN** un champ est entre guillemets et contient une virgule ou un point-virgule
- **THEN** le champ entier (avec son séparateur interne) est retourné comme une seule valeur

#### Scenario: millesime converti en int
- **WHEN** le CSV contient `millesime=2018`
- **THEN** le companion a `millesime.value == 2018` (int)

#### Scenario: garde_min/garde_max nullable
- **WHEN** `garde_min` est vide et `garde_max` vaut `15`
- **THEN** `gardeMin.value == null` et `gardeMax.value == 15`

#### Scenario: prix_achat nullable
- **WHEN** `prix_achat` est vide
- **THEN** `prixAchat.value == null`

#### Scenario: Ligne vide ignorée
- **WHEN** le CSV contient une ligne vide entre deux lignes valides
- **THEN** la ligne vide est ignorée et les 2 autres lignes produisent des companions

#### Scenario: Ligne avec mauvais nombre de colonnes — champs manquants ignorés
- **WHEN** une ligne a moins de colonnes que l'en-tête
- **THEN** les colonnes présentes sont parsées, les manquantes traitées comme vides

#### Scenario: Champs obligatoires manquants — erreur
- **WHEN** `domaine` ou `appellation` ou `millesime` ou `couleur` est vide
- **THEN** la ligne est ignorée et une `ParseError` est ajoutée au résultat

---

### Requirement: Tests import_service — insert/update/skip/erreur
`ImportService.run` SHALL être couvert par des tests d'intégration avec DB in-memory vérifiant les 4 cas de traitement et les compteurs du rapport.

#### Scenario: id absent dans le companion → insert avec UUID généré
- **WHEN** un companion sans id (id généré par parseCsv) n'existe pas en base
- **THEN** il est inséré et `result.inserted == 1`

#### Scenario: id présent, absent de la base → insert avec cet UUID
- **WHEN** un companion avec id fixe n'existe pas en base
- **THEN** il est inséré avec cet id exact et `result.inserted == 1`

#### Scenario: id présent, déjà en base, overwrite=true → UPDATE
- **WHEN** un companion avec id existant est importé avec `overwrite: true`
- **THEN** la bouteille est mise à jour et `result.updated == 1`

#### Scenario: id présent, déjà en base, overwrite=false → SKIP
- **WHEN** un companion avec id existant est importé avec `overwrite: false`
- **THEN** la bouteille n'est pas modifiée et `result.skipped == 1`

#### Scenario: updatedAt valide ISO8601 — préservé
- **WHEN** le companion a `updatedAt = '2025-01-15T10:00:00Z'`
- **THEN** la bouteille insérée a exactement ce `updatedAt`

#### Scenario: Rapport compteurs corrects
- **WHEN** 3 companions dont 1 insert, 1 update (overwrite=true), 1 skip
- **THEN** `result.inserted==1, result.updated==1, result.skipped==1, result.errors==0`

---

### Requirement: Tests csv_export_service — BOM, champs, scope, séparateur
`CsvExportService.buildCsv` SHALL être couvert par des tests unitaires vérifiant la présence du BOM, la structure de l'en-tête et des données, le filtrage par scope, et le séparateur.

#### Scenario: BOM UTF-8 en tête du fichier
- **WHEN** `buildCsv` est appelé avec une liste de bouteilles
- **THEN** la chaîne retournée commence par `﻿`

#### Scenario: En-tête contient tous les champs (20 colonnes)
- **WHEN** `buildCsv` est appelé
- **THEN** la première ligne (après le BOM) contient exactement 20 colonnes dont `updated_at`

#### Scenario: Séparateur `;` appliqué
- **WHEN** `buildCsv` est appelé avec `separator: ';'`
- **THEN** les champs de chaque ligne sont séparés par `;`

#### Scenario: Séparateur `,` appliqué
- **WHEN** `buildCsv` est appelé avec `separator: ','`
- **THEN** les champs de chaque ligne sont séparés par `,`

#### Scenario: Champ contenant le séparateur — échappement guillemets
- **WHEN** un champ contient le séparateur (ex. domaine = `"Château, Grand"`)
- **THEN** le champ est entouré de guillemets doubles dans la sortie

#### Scenario: Valeur null dans une ligne → chaîne vide
- **WHEN** une bouteille a `cru = null`
- **THEN** la cellule correspondante est une chaîne vide (pas `'null'`)

---

### Requirement: Tests bulk_add_controller — état initial, isValid, setQuantiteTotal, CRUD groupes
`BulkAddState` et `BulkAddNotifier` SHALL être couverts par des tests Riverpod avec `ProviderContainer`.

#### Scenario: État initial — domaine/appellation vides, isValid false
- **WHEN** `BulkAddNotifier` est créé
- **THEN** `domaine == ''`, `appellation == ''`, `isValid == false`

#### Scenario: isValid — true quand tous les champs obligatoires remplis et somme correcte
- **WHEN** domaine, appellation, millesime, couleur sont renseignés ET la somme des groupes == quantiteTotal ET tous les emplacements valides
- **THEN** `isValid == true`

#### Scenario: isValid — false si emplacement invalide
- **WHEN** un groupe a `emplacement = 'Cave>>Mauvais'` (format invalide)
- **THEN** `isValid == false`

#### Scenario: setQuantiteTotal avec un seul groupe → quantiteGroupe ajustée
- **WHEN** `setQuantiteTotal(3)` est appelé avec un seul groupe
- **THEN** le groupe unique a `quantite == 3` et `sommeGroupes == 3`

#### Scenario: setQuantiteTotal avec 2 groupes → répartition inchangée
- **WHEN** 2 groupes (1+1) existent et `setQuantiteTotal(5)` est appelé
- **THEN** les groupes restent à 1+1 (somme ne correspond plus, isValid=false)

#### Scenario: addGroupe — ajoute un groupe vide
- **WHEN** `addGroupe()` est appelé
- **THEN** `groupes.length` augmente de 1 et le nouveau groupe a `quantite == 1, emplacement == ''`

#### Scenario: removeGroupe — supprime le groupe d'index donné
- **WHEN** 2 groupes existent et `removeGroupe(0)` est appelé
- **THEN** il reste 1 groupe

#### Scenario: removeGroupe — ignoré si un seul groupe
- **WHEN** 1 seul groupe existe et `removeGroupe(0)` est appelé
- **THEN** `groupes.length == 1` (pas de suppression)

#### Scenario: updateGroupe — met à jour quantite et emplacement
- **WHEN** `updateGroupe(0, RepartitionGroup(quantite: 2, emplacement: 'Cave A'))` est appelé
- **THEN** `groupes[0].quantite == 2` et `groupes[0].emplacement == 'Cave A'`

---

### Requirement: Tests location_node — buildTree et nodeStats
`buildTree` et `nodeStats` SHALL être couverts par des tests unitaires purs sans DB.

#### Scenario: buildTree liste vide → résultat vide
- **WHEN** `buildTree([])` est appelé
- **THEN** la liste retournée est vide

#### Scenario: buildTree — emplacement simple répété → nœud unique avec directCount
- **WHEN** `buildTree` reçoit 2 feuilles avec `emplacement = 'Cave A'`
- **THEN** un seul nœud racine 'Cave A' avec `directCount == 2` est retourné

#### Scenario: buildTree — hiérarchie 2 niveaux
- **WHEN** `buildTree` reçoit 'Cave A > Étagère 1' (count=2) et 'Cave A > Étagère 2' (count=3)
- **THEN** un nœud racine 'Cave A' avec 2 enfants est retourné

#### Scenario: buildTree — mix direct + enfants
- **WHEN** `buildTree` reçoit 'Cave A' (count=1) et 'Cave A > Étagère 1' (count=2)
- **THEN** le nœud 'Cave A' a `directCount==1` et 1 enfant 'Étagère 1'

#### Scenario: nodeStats includeChildren=false → stats directes uniquement
- **WHEN** `nodeStats(node, false)` est appelé sur un nœud avec enfants
- **THEN** seuls `directCount`, `directSumPrix`, `directNullPrixCount` du nœud sont retournés

#### Scenario: nodeStats includeChildren=true → agrège récursivement
- **WHEN** un nœud parent a `directCount=1` et un enfant avec `directCount=2`
- **THEN** `nodeStats(parent, true).$1 == 3`

---

### Requirement: Tests stock_controller — filtres et tri
`StockFilterController` et `_sorted` SHALL être couverts par des tests unitaires sans DB.

#### Scenario: État initial — aucun filtre, tri domaine asc
- **WHEN** `StockFilterController` est créé
- **THEN** `couleurs` vide, `appellation` null, `texte == ''`, `sortColumn == 'domaine'`, `sortAscending == true`

#### Scenario: toggleCouleur — ajoute puis retire
- **WHEN** `toggleCouleur('Rouge')` est appelé deux fois
- **THEN** après le 1er appel `couleurs == {'Rouge'}`, après le 2ème `couleurs == {}`

#### Scenario: toggleMaturite — active le filtre et bascule le tri sur GARDE
- **WHEN** `toggleMaturite(MaturityLevel.optimal)` est appelé
- **THEN** `maturites == {MaturityLevel.optimal}` et `sortColumn == 'gardeMin'`

#### Scenario: setSort — même colonne inverse l'ordre
- **WHEN** `setSort('millesime')` est appelé deux fois
- **THEN** après le 1er appel `sortAscending == true`, après le 2ème `sortAscending == false`

#### Scenario: setSort — nouvelle colonne remet l'ordre à asc
- **WHEN** `setSort('millesime')` est appelé puis `setSort('couleur')`
- **THEN** `sortColumn == 'couleur'`, `sortAscending == true`

#### Scenario: reset — efface tous les filtres
- **WHEN** des filtres sont actifs et `reset()` est appelé
- **THEN** l'état revient à l'état initial

#### Scenario: hasActiveFilters — true si au moins un filtre actif
- **WHEN** `texte == 'margaux'`
- **THEN** `hasActiveFilters == true`

#### Scenario: hasActiveFilters — false si aucun filtre
- **WHEN** l'état est l'état initial
- **THEN** `hasActiveFilters == false`
