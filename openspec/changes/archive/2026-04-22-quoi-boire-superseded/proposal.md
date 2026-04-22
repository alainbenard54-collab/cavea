## Why

L'utilisateur dispose d'une cave bien gérée mais n'a pas de moyen rapide de savoir quelles bouteilles sont à leur apogée aujourd'hui. La vue "Quoi boire ?" répond à cette question en affichant les bouteilles selon leur maturité, calculée à partir du millésime et des gardes min/max.

## What Changes

- Nouvelle vue "Quoi boire ?" accessible depuis la navigation principale
- Indicateurs visuels de maturité colorés (bleu / vert / orange / rouge) calculés à la volée
- Filtrage par couleur de vin pour affiner la sélection
- Tri par maturité (les vins à boire en premier en tête de liste)

## Capabilities

### New Capabilities

- `quoi-boire`: Écran affichant les bouteilles en stock avec leur indicateur de maturité coloré, filtrable par couleur de vin.

### Modified Capabilities

- `bouteilles-db`: Ajout d'une méthode DAO exposant les bouteilles avec `gardeMin`/`gardeMax` nécessaires au calcul de maturité (si pas déjà disponible via `watchStockFiltered`).

## Impact

- `lib/features/quoi_boire/` : nouveau module (screen + widgets + provider)
- `lib/core/navigation/` : ajout de la destination "Quoi boire ?" dans NavigationRail et BottomNavigationBar
- `lib/features/home/` : mise à jour des routes go_router
- Aucune modification du schéma drift (les champs `garde_min`, `garde_max`, `millesime` existent déjà)
- Mode 1 uniquement (MVP)

## Non-goals

- Recommandation IA ou scoring complexe
- Maturité par appellation (règles œnologiques externes)
- Action "consommer" depuis cette vue (hors périmètre étape 3 — étape 4 du MVP)
- Tri par emplacement ou par fournisseur
