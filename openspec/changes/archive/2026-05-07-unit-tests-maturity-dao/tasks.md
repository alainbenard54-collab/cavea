## 1. Setup

- [x] 1.1 Créer les dossiers `test/core/maturity/` et `test/data/daos/` (PC + Android)
- [x] 1.2 Vérifier que `flutter_test` est présent en `dev_dependencies` dans `pubspec.yaml` — aucun ajout requis si déjà présent

## 2. Tests unitaires — maturity_service.dart

- [x] 2.1 Créer `test/core/maturity/maturity_service_test.dart` avec l'import du fichier source et la structure `group`/`test` de base
- [x] 2.2 Tester `computeMaturity` : `gardeMin: null` → `sansDonnee`
- [x] 2.3 Tester `computeMaturity` : `gardeMax: null` → `sansDonnee`
- [x] 2.4 Tester `computeMaturity` : `gardeMin: 0` → `sansDonnee`
- [x] 2.5 Tester `computeMaturity` : `millesime: 0` → `sansDonnee`
- [x] 2.6 Tester `computeMaturity` : âge < gardeMin → `tropJeune` (ex. millesime 2020, gardeMin 7, annee 2026)
- [x] 2.7 Tester `computeMaturity` : âge = gardeMin (limite inférieure) → `optimal`
- [x] 2.8 Tester `computeMaturity` : âge dans la fenêtre → `optimal`
- [x] 2.9 Tester `computeMaturity` : âge = gardeMax (limite supérieure) → `optimal`
- [x] 2.10 Tester `computeMaturity` : âge > gardeMax → `aBoireUrgent`
- [x] 2.11 Tester `urgencyScore` : niveau `aBoireUrgent` → score = age - gardeMax (positif)
- [x] 2.12 Tester `urgencyScore` : niveau `optimal` → score = age - gardeMax (négatif)
- [x] 2.13 Tester `urgencyScore` : niveau `tropJeune` → score = age - gardeMin (négatif)
- [x] 2.14 Tester `urgencyScore` : `gardeMin: null`, `gardeMax: null` → score = 0
- [x] 2.15 Tester `maturitySortOrder` : ordre relatif des 4 niveaux (`aBoireUrgent` < `optimal` < `tropJeune` < `sansDonnee`)
- [x] 2.16 Lancer `flutter test test/core/maturity/` → 0 failure (PC)

## 3. Tests d'intégration — bouteille_dao.dart

- [x] 3.1 Créer `test/data/daos/bouteille_dao_test.dart` avec `setUp` (AppDatabase + NativeDatabase.memory()) et `tearDown` (`await db.close()`)
- [x] 3.2 Tester `watchStock` : bouteilles avec `date_sortie` renseignée exclues du résultat
- [x] 3.3 Tester `watchStock` : liste vide si toutes les bouteilles sont consommées
- [x] 3.4 Tester `watchStockFiltered` : filtre par couleur unique
- [x] 3.5 Tester `watchStockFiltered` : filtre par plusieurs couleurs (multi-sélect)
- [x] 3.6 Tester `watchStockFiltered` : filtre par appellation
- [x] 3.7 Tester `watchStockFiltered` : filtre par millésime
- [x] 3.8 Tester `watchStockFiltered` : filtre par texte, insensible à la casse, sur domaine
- [x] 3.9 Tester `watchStockFiltered` : sans critère → tout le stock retourné
- [x] 3.10 Tester `insertBouteille` : la bouteille apparaît dans `watchStock().first`
- [x] 3.11 Tester `insertBouteilles` : N bouteilles insérées → toutes présentes dans `watchStock().first`
- [x] 3.12 Tester `deplacerBouteille` : `emplacement` mis à jour, `date_sortie` reste null
- [x] 3.13 Tester `deplacerBouteille` : la bouteille reste visible dans `watchStock().first` après déplacement
- [x] 3.14 Tester `consommerBouteille` : avec `noteDegus` et `commentaireDegus` → champs écrits en base
- [x] 3.15 Tester `consommerBouteille` : sans note ni commentaire → `note_degus` et `commentaire_degus` restent null
- [x] 3.16 Tester `consommerBouteille` : la bouteille disparaît de `watchStock().first`
- [x] 3.17 Tester `getDistinctEmplacements` : valeurs distinctes triées, emplacements de bouteilles consommées exclus
- [x] 3.18 Tester `getDistinctCouleurs` : valeurs distinctes triées (stock uniquement)
- [x] 3.19 Lancer `flutter test test/data/daos/` → 0 failure (PC)

## 4. Validation finale

- [x] 4.1 Lancer `flutter test` (suite complète) → tous les tests passent, 0 failure (PC)
