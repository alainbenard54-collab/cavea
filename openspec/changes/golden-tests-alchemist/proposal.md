## Why

La suite de tests actuelle (`unit-tests`, `dao-integration-tests`, `maturity-unit-tests`) couvre exhaustivement les couches logiques non-UI mais ne détecte aucune dérive visuelle (couleur, positionnement, espacement) sur les écrans et widgets. Ce point était identifié par le référentiel `claude-project-standards` (point 9) mais volontairement différé : il dépendait d'un environnement CI stable (`ci.yml` sur `ubuntu-latest`, résolu) et d'une version Flutter à jour (3.44.9, résolue et validée — `flutter analyze` 0 issue, `flutter test` 149/149). Les deux prérequis sont maintenant levés, il est cohérent d'introduire les golden tests maintenant, avant de reprendre les builds et la préparation de la release v1.3.0.

## What Changes

- Ajout de la dépendance `alchemist` (dev_dependency) pour la génération et la comparaison de golden tests Flutter
- Création de la structure de test golden (dossier dédié, ex. `test/golden/`) et d'un harnais de base (thème Material 3, localisations, taille de viewport) réutilisable par tous les golden tests
- Premier jeu de golden tests sur un sous-ensemble représentatif d'écrans/widgets (liste précise à trancher dans `design.md`)
- Documentation de la commande/process pour régénérer volontairement les références golden après un changement visuel intentionnel

## Capabilities

### New Capabilities
- `golden-tests`: infrastructure et premier jeu de tests de non-régression visuelle (golden tests) basés sur le package Alchemist — harnais, structure de dossiers, références versionnées, process de régénération.

### Modified Capabilities
(aucune — les capacités UI existantes ne changent pas de comportement, seule une nouvelle couche de vérification est ajoutée)

## Impact

- `pubspec.yaml` : nouvelle dev_dependency `alchemist`
- Nouveau dossier de tests golden + fichiers de référence PNG versionnés dans le dépôt
- Aucun impact sur le code applicatif (`lib/`) ni sur les modes de déploiement (Mode 1/2/3)
- Explicitement hors périmètre : câblage dans `.github/workflows/ci.yml` (change séparé à venir) et tout ce qui touche aux builds/release v1.3.0
