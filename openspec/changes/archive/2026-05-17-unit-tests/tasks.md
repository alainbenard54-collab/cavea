## 1. Infrastructure de test

- [x] 1.1 Créer `test/helpers/fake_app_localizations.dart` — stub FakeAppLocalizations retournant la clé comme valeur pour les 20 headers CSV (csvHeaderId → 'id', csvHeaderDomaine → 'domaine', etc.)

## 2. bouteille_dao — méthodes non couvertes (compléter le fichier existant)

- [x] 2.1 Test `getBouteilleById` — bouteille trouvée : insérer b1, appeler `getBouteilleById('b1')`, vérifier que l'objet retourné est non-null et que son id est 'b1'
- [x] 2.\1 Test `getBouteilleById` — bouteille introuvable : appeler `getBouteilleById('inconnu')` sur DB vide, vérifier que le résultat est null
- [x] 2.\1 Test `updateBouteille` — modification partielle : insérer b1 avec domaine='DomA', appeler `updateBouteille` avec domaine='DomB' (tous champs), vérifier domaine='DomB' et appellation inchangée
- [x] 2.\1 Test `updateBouteille` — updatedAt modifiable : insérer b1, appeler `updateBouteille` avec updatedAt='2030-01-01T00:00:00Z', vérifier que updatedAt est mis à jour
- [x] 2.\1 Test `deplacerBouteilles` — batch transaction : insérer b1 et b2, appeler `deplacerBouteilles(['b1','b2'], 'Cave B')`, vérifier que les deux bouteilles ont emplacement='Cave B' et date_sortie null
- [x] 2.\1 Test `consommerBouteilles` — batch transaction : insérer b1 et b2, appeler `consommerBouteilles(['b1','b2'], dateSortie:'2026-05-01', noteDegus:9.0)`, vérifier date_sortie et note sur les deux
- [x] 2.\1 Test `rehabiliterBouteille` : insérer b1 consommé (dateSortie+noteDegus+commentaire renseignés), appeler `rehabiliterBouteille('b1')`, vérifier date_sortie/noteDegus/commentaireDegus sont null et b1 réapparaît dans watchStock
- [x] 2.\1 Test `watchHistorique` — stream triée date_sortie desc, exclut stock : insérer b1 (consommé 2026-03), b2 (consommé 2026-05), b3 (stock), vérifier stream=[b2, b1], b3 absent
- [x] 2.\1 Test `watchBouteillesParEmplacement` — match exact : insérer b1 emplacement='Cave A', b2 emplacement='Cave A > Étagère 1', appeler sans includeSublocations, vérifier seul b1 retourné
- [x] 2.\1 Test `watchBouteillesParEmplacement` — includeSublocations=true : même données que 2.9, vérifier b1 et b2 retournés
- [x] 2.\1 Test `watchLocationStats` — groupé stock uniquement : insérer b1 (Cave A, prix=10), b2 (Cave A, prix=null), b3 (Cave B, prix=5), b4 consommé (Cave A) ; vérifier 2 LocationLeaf avec count/sumPrix/nullPrixCount corrects
- [x] 2.\1 Test `getDistinctDomaines` — toutes bouteilles (stock + consommées) : insérer 2 domaines stock + 1 domaine consommé distincts, vérifier les 3 retournés
- [x] 2.\1 Test `getAllDistinctAppellations` — toutes bouteilles : même principe, 3 appellations
- [x] 2.\1 Test `getAllDistinctContenances` — toutes bouteilles, null exclus : 2 contenances renseignées + 1 null, vérifier 2 retournées
- [x] 2.\1 Test `getAllDistinctCrus` — toutes bouteilles, null exclus : même principe
- [x] 2.\1 Test `getDistinctFournisseurs` — toutes bouteilles, null exclus : 2 fournisseurs + 1 null, vérifier 2 retournés

## 3. csv_parser — tests unitaires purs (nouveau fichier)

- [x] 3.\1 Créer `test/features/import_csv/csv_parser_test.dart` avec header SPDX Apache-2.0
- [x] 3.\1 Test séparateur `;` (défaut) : CSV `domaine;appellation;millesime;couleur\nTest;Bordeaux;2018;Rouge`, vérifier companion parsé correctement
- [x] 3.\1 Test séparateur `,` : même CSV avec `,`, appeler `parseCsv(..., separator: ',')`, vérifier companion parsé
- [x] 3.\1 Test séparateur tabulation : même CSV avec `\t`, appeler `parseCsv(..., separator: '\t')`, vérifier companion parsé
- [x] 3.\1 Test BOM UTF-8 retiré : préfixer le CSV avec `﻿`, vérifier que l'en-tête est correctement reconnu (pas d'erreur, companion parsé)
- [x] 3.\1 Test champ quoté contenant le séparateur : domaine = `"Château, Grand"` avec séparateur `,`, vérifier que domaine est `'Château, Grand'` (sans guillemets)
- [x] 3.\1 Test millesime → int : CSV avec `millesime=2018`, vérifier `companion.millesime.value == 2018`
- [x] 3.\1 Test garde_min vide → null : CSV avec `garde_min=` vide et `garde_max=15`, vérifier `gardeMin.value == null`, `gardeMax.value == 15`
- [x] 3.\1 Test prix_achat vide → null : CSV avec `prix_achat=` vide, vérifier `prixAchat.value == null`
- [x] 3.\1 Test prix_achat avec virgule décimale : CSV avec `prix_achat=15,50`, vérifier `prixAchat.value == 15.5`
- [x] 3.\1 Test ligne vide ignorée : CSV avec 2 lignes valides séparées par une ligne vide, vérifier `companions.length == 2, errors.length == 0`
- [x] 3.\1 Test champs obligatoires manquants — domaine vide : vérifier `companions.length == 0, errors.length == 1`
- [x] 3.\1 Test updatedAt valide préservé : CSV avec `updated_at=2025-06-01T10:00:00Z`, vérifier que le companion a exactement cette valeur
- [x] 3.\1 Test updatedAt absent → DateTime générée : CSV sans colonne `updated_at`, vérifier que `updatedAt.value` est une date ISO non vide

## 4. import_service — tests d'intégration in-memory (nouveau fichier)

- [x] 4.\1 Créer `test/features/import_csv/import_service_test.dart` avec header SPDX
- [x] 4.\1 Test id absent en base → insert, `result.inserted == 1` : companion avec UUID aléatoire non présent en base, appeler `run([companion])`, vérifier insertion et compteur
- [x] 4.\1 Test id fixe absent de la base → insert avec cet UUID : companion avec id='fixed-uuid-123', vérifier que la bouteille insérée a bien id='fixed-uuid-123'
- [x] 4.\1 Test id existant, overwrite=true → UPDATE : insérer b1 en base, puis `run([companionModifié], overwrite: true)`, vérifier mise à jour et `result.updated == 1`
- [x] 4.\1 Test id existant, overwrite=false → SKIP : insérer b1 en base, puis `run([companion b1], overwrite: false)`, vérifier pas de modification et `result.skipped == 1`
- [x] 4.\1 Test updatedAt ISO8601 valide → préservé : companion avec updatedAt='2025-01-15T10:00:00Z', vérifier que la bouteille insérée a ce updatedAt exact
- [x] 4.\1 Test rapport compteurs 1 insert + 1 update + 1 skip : `result.inserted==1, result.updated==1, result.skipped==1, result.errors==0`

## 5. csv_export_service — tests unitaires avec stub (nouveau fichier)

- [x] 5.\1 Créer `test/features/export_csv/csv_export_service_test.dart` avec header SPDX
- [x] 5.\1 Test BOM présent : appeler `buildCsv([])`, vérifier que la chaîne commence par `'\u{FEFF}'`
- [x] 5.\1 Test en-tête 20 colonnes : appeler `buildCsv([])` avec séparateur `;`, vérifier que la première ligne après BOM contient exactement 20 champs
- [x] 5.\1 Test en-tête contient 'updated_at' (ou la clé FakeAppLocalizations) : vérifier que la colonne est présente dans l'en-tête
- [x] 5.\1 Test séparateur `;` dans les données : bouteille simple, vérifier que la ligne de données utilise `;` comme séparateur
- [x] 5.\1 Test séparateur `,` dans les données : même test avec `,`
- [x] 5.\1 Test échappement : bouteille avec `domaine = 'Château;Test'` et séparateur `;`, vérifier que domaine est entouré de guillemets dans la sortie
- [x] 5.\1 Test valeur null → chaîne vide : bouteille avec `cru = null`, vérifier que la cellule cru est vide (pas 'null')

## 6. bulk_add_controller — tests Riverpod (nouveau fichier)

- [x] 6.\1 Créer `test/features/bulk_add/bulk_add_controller_test.dart` avec header SPDX
- [x] 6.\1 Test état initial : créer `BulkAddState(dateEntree: DateTime.now())`, vérifier `domaine == ''`, `appellation == ''`, `couleur == ''`, `quantiteTotal == 1`, `groupes.length == 1`, `isValid == false`
- [x] 6.\1 Test isValid true : créer état avec domaine='D', appellation='A', millesime='2018', couleur='Rouge', 1 groupe quantite=1 emplacement='Cave A', vérifier `isValid == true`
- [x] 6.\1 Test isValid false — emplacement invalide : état valide mais emplacement='Cave>>Mauvais', vérifier `isValid == false`
- [x] 6.\1 Test isValid false — somme ≠ total : 2 groupes (1+1), quantiteTotal=3, vérifier `isValid == false`
- [x] 6.\1 Test `setQuantiteTotal(3)` avec un seul groupe : vérifier `state.groupes[0].quantite == 3` et `state.sommeGroupes == 3`
- [x] 6.\1 Test `setQuantiteTotal(5)` avec 2 groupes (1+1) : vérifier que les groupes restent inchangés (répartition conservée)
- [x] 6.\1 Test `addGroupe` : vérifier `groupes.length == 2` après appel, nouveau groupe `quantite==1, emplacement==''`
- [x] 6.\1 Test `removeGroupe(0)` avec 2 groupes : vérifier `groupes.length == 1`
- [x] 6.\1 Test `removeGroupe(0)` avec 1 seul groupe : vérifier `groupes.length == 1` (opération ignorée)
- [x] 6.\1 Test `updateGroupe(0, RepartitionGroup(quantite:2, emplacement:'Cave A'))` : vérifier `groupes[0].quantite == 2` et `groupes[0].emplacement == 'Cave A'`
- [x] 6.\1 Test `sommeGroupes` : ajouter un groupe, mettre quantite=3 et 2, vérifier `sommeGroupes == 5`

## 7. location_node — tests unitaires purs (nouveau fichier)

- [x] 7.\1 Créer `test/features/locations/location_node_test.dart` avec header SPDX
- [x] 7.\1 Test `buildTree([])` → liste vide retournée
- [x] 7.\1 Test `buildTree` avec 2 feuilles `emplacement='Cave A'` (count=1 chacune) → 1 nœud racine 'Cave A' avec `directCount == 1` (ou 2 selon la sémantique — vérifier la vraie implémentation : les feuilles ont leur propre count, le nœud prend le dernier ou la somme ?)
- [x] 7.\1 Test `buildTree` hiérarchie 2 niveaux : feuilles 'Cave A > Étagère 1' (count=2) et 'Cave A > Étagère 2' (count=3) → 1 nœud racine 'Cave A' avec 2 enfants 'Étagère 1' et 'Étagère 2'
- [x] 7.\1 Test `buildTree` mix direct + enfants : feuille 'Cave A' (count=1) et 'Cave A > Étagère 1' (count=2) → nœud 'Cave A' avec `directCount==1` et 1 enfant
- [x] 7.\1 Test `nodeStats(node, false)` → retourne les stats directes du nœud sans agréger les enfants : vérifier que count retourné == directCount du nœud
- [x] 7.\1 Test `nodeStats(node, true)` → agrège récursivement : nœud parent directCount=1 + enfant directCount=2, vérifier count total == 3
- [x] 7.\1 Test `nodeStats` somme prix avec enfant : parent sumPrix=10.0 + enfant sumPrix=5.0, vérifier sumPrix agrégée == 15.0
- [x] 7.\1 Test `nodeStats` avec nullPrixCount agrégé : parent nullPrixCount=1 + enfant nullPrixCount=2, vérifier total == 3

## 8. stock_controller — tests Riverpod (nouveau fichier)

- [x] 8.\1 Créer `test/features/stock/stock_controller_test.dart` avec header SPDX
- [x] 8.\1 Test état initial `StockFilterController` : vérifier `couleurs == {}`, `appellation == null`, `millesime == null`, `texte == ''`, `sortColumn == 'domaine'`, `sortAscending == true`, `maturites == {}`
- [x] 8.\1 Test `toggleCouleur('Rouge')` → `couleurs == {'Rouge'}`, `toggleCouleur('Rouge')` à nouveau → `couleurs == {}`
- [x] 8.\1 Test `toggleMaturite(MaturityLevel.optimal)` → `maturites == {MaturityLevel.optimal}` ET `sortColumn == 'gardeMin'`
- [x] 8.\1 Test `toggleMaturite` deux fois → filtre désactivé et sortColumn reste sur 'gardeMin'
- [x] 8.\1 Test `setSort('millesime')` → `sortColumn == 'millesime'`, `sortAscending == true` ; appel à nouveau → `sortAscending == false`
- [x] 8.\1 Test `setSort` nouvelle colonne : `setSort('couleur')` après `setSort('millesime')` → `sortColumn == 'couleur'`, `sortAscending == true`
- [x] 8.\1 Test `reset()` : activer couleur + maturite + texte, appeler `reset()`, vérifier retour à l'état initial
- [x] 8.\1 Test `hasActiveFilters` false : état initial → `false`
- [x] 8.\1 Test `hasActiveFilters` true avec texte : `setTexte('margaux')` → `true`
- [x] 8.\1 Test `hasActiveFilters` true avec couleur : `toggleCouleur('Rouge')` → `true`
