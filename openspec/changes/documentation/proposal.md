## Why

Cavea est une application personnelle partageable — il lui manque toute documentation permettant à un tiers (ou à l'auteur lui-même après quelques mois) de comprendre le projet, d'utiliser l'application et de contribuer au code. L'application V1 étant feature-complete, c'est le bon moment pour documenter avant de se lancer dans les releases.

## What Changes

- Ajout d'un **README.md bilingue** (français + anglais dans le même fichier) à la racine du repo, présentant le projet, les modes de déploiement et la stack technique
- Ajout d'une **documentation utilisateur bilingue** (fr + en), structurée en scénarios, dans un répertoire `docs/` versionné dans le repo
- Le README et la doc utilisateur couvrent les deux modes applicatifs : Mode Local (un seul appareil, dart:io direct) et Mode Partagé (Google Drive ou Dropbox, verrou automatique)

Aucune modification de code applicatif. Ce changement est entièrement documentaire.

## Capabilities

### New Capabilities

- `readme-multilingual` : README.md bilingue (fr/en) à la racine du repo — présentation générale, philosophie, modes de déploiement, stack technique, instructions de build et configuration OAuth
- `user-documentation` : documentation utilisateur bilingue (fr/en) structurée en 13 scénarios dans `docs/` — couvre tous les flux utilisateur de l'application V1

### Modified Capabilities

_(aucune — ce changement ne modifie aucune spec existante)_

## Impact

- Aucun impact sur le code applicatif Flutter
- Nouveaux fichiers : `README.md` (racine), `docs/README.md` (index doc utilisateur), `docs/fr/` et `docs/en/` (scénarios bilingues)
- Le répertoire `docs/` est versionné dans le repo GitHub — aucun outillage externe requis
- Mode concerné : Mode 1 et Mode 2 documentés (Mode 3 Android local hors scope, comme dans le code)

## Non-goals

- Documentation de déploiement et de release (APK, Linux packaging, GitHub Actions) — traité séparément dans un chanter dédié
- Captures d'écran ou vidéos de démonstration — hors scope pour l'instant
- Site de documentation statique (GitBook, MkDocs, etc.) — les fichiers Markdown dans le repo suffisent
- Traduction dans d'autres langues que fr et en
