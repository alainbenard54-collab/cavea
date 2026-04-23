## Why

L'import CSV est la seule façon d'ajouter des bouteilles, ce qui bloque l'usage au quotidien : chaque nouvel achat nécessite de passer par un fichier. Un formulaire d'ajout manuel couvre le cas le plus fréquent — une caisse achetée chez un fournisseur — en une seule saisie, sans quitter l'application.

## What Changes

- Nouvel écran "Ajouter des bouteilles" accessible depuis la navigation principale
- Formulaire avec tous les champs non-protégés (domaine, appellation, millésime, couleur, cru, contenance, prix d'achat, garde min/max, commentaire entrée, fournisseur nom/infos, producteur, date d'entrée)
- Champ "Quantité totale" (entier ≥ 1)
- Section "Répartition" : groupes dynamiques `(quantité, emplacement)` avec autocomplétion emplacement — somme des quantités = quantité totale obligatoire
- Confirmation crée N lignes indépendantes en base (1 UUID par bouteille physique)

## Capabilities

### New Capabilities

- `bulk-add` : formulaire d'ajout manuel de N bouteilles identiques avec répartition multi-emplacement

### Modified Capabilities

- `bouteilles-db` : ajout méthode `insertBouteilles(List<BouteillesCompanion>)` pour insertion en lot transactionnelle

## Impact

- `lib/features/bulk_add/` : nouveau module (écran + formulaire)
- `lib/data/daos/bouteille_dao.dart` : méthode d'insertion en lot
- `lib/shared/adaptive_layout.dart` : ajout destination "Ajouter" dans la navigation
- `lib/app/router.dart` : route `/bulk-add`
- Mode 1 uniquement (MVP)

## Non-goals

- Import depuis un fichier CSV (déjà couvert par l'import CSV existant)
- Ajout de bouteilles avec des millésimes ou appellations différents en une seule passe
- Scan de code-barres ou intégration base de données vins externe
- Modification de bouteilles existantes (couvert par "Modifier la fiche", V1)
