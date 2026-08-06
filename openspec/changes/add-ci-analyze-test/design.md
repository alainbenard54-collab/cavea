## Context

Voir proposal.md - Why. Le seul workflow GitHub Actions existant, `.github/workflows/release-windows.yml`, se déclenche uniquement sur push de tag `v*` et ne fait que builder/publier — il ne valide jamais `flutter analyze` ni `flutter test` avant une release. Ces deux commandes sont documentées dans `.local/build-commands.md` comme prérequis manuel avant tout build de release, mais rien ne force leur exécution.

Contrainte propre à l'environnement de développement actuel : Flutter ne peut pas être exécuté depuis la session Claude Code (installé nativement sous Windows, hors du sandbox WSL). GitHub Actions exécute sur ses propres runners et n'a pas cette contrainte.

## Goals / Non-Goals

**Goals:**
- Exécution automatique de `flutter analyze` + `flutter test` à chaque push et pull request vers `master`.
- Cohérence avec le workflow de release existant (même version Flutter épinglée : `3.41.9`).

**Non-Goals:**
- Pas de configuration de branch protection / required status check dans ce change — le check reste informatif (statut visible sur GitHub, mais rien n'empêche un push ou un merge en cas d'échec). Décision utilisateur explicite, reconsidérable plus tard.
- Pas de check de formatage (`dart format --set-exit-if-changed`) — hors périmètre, ce n'est pas une pratique documentée actuellement du projet.
- Pas de modification de `release-windows.yml`.
- Pas de couverture de code (`flutter test --coverage`) ni de publication de rapport — non demandé.

## Decisions

**Nouveau fichier `.github/workflows/ci.yml`, distinct de `release-windows.yml`.**
Alternative écartée : ajouter un job `analyze+test` dans `release-windows.yml`. Rejetée car les déclencheurs sont incompatibles (tag `v*` vs push/PR sur `master`) et les runners diffèrent (`windows-latest` pour le build réel vs `ubuntu-latest` suffisant et moins coûteux pour analyze/test qui ne dépendent d'aucune API Windows-spécifique).

**Runner `ubuntu-latest`.**
Alternative écartée : `windows-latest` par cohérence avec le build de release. Rejetée : `flutter analyze` et `flutter test` n'exercent aucun code spécifique à une plateforme (pas de `dart:io` Windows, pas de plugin natif testé ici), Ubuntu est plus rapide à démarrer et moins cher en minutes GitHub Actions.

**Déclencheurs `push` sur `master` + `pull_request` ciblant `master`.**
Décision utilisateur (validée via question posée avant implémentation). Couvre le flux solo actuel (push direct) et un flux futur à base de PR sans sur-contraindre dès maintenant.

**Version Flutter épinglée `3.41.9` via `subosito/flutter-action@v2`, `cache: true`.**
Décision utilisateur. Garantit que la CI teste exactement la version utilisée pour builder les releases (`release-windows.yml` utilise la même). Alternative écartée : `channel: stable` sans version figée — risque de dérive silencieuse entre ce qui est testé en CI et ce qui sert à builder une release.

**Check informatif, pas de branch protection.**
Décision utilisateur. Configurer une règle de protection sur `master` est une action affectant un système partagé (paramètres GitHub du repo) — hors périmètre de ce change technique, à instruire séparément si souhaité plus tard.

**Périmètre limité à `analyze` + `test`.**
Décision utilisateur. Reproduit exactement `.local/build-commands.md`, pas d'extension du contrat de qualité au-delà de ce qui existe déjà.

## Risks / Trade-offs

- [Aucune protection de branche] → le check peut être rouge sans bloquer quoi que ce soit ; le mainteneur doit surveiller le statut manuellement sur GitHub. Mitigation : accepté comme non-goal explicite, reconsidérable dans un change ultérieur.
- [Dérive de version Flutter] → si `release-windows.yml` est mis à jour vers une nouvelle version Flutter sans mettre à jour `ci.yml` (ou l'inverse), la CI peut valider une version différente de celle utilisée en release. Mitigation : aucune automatisation prévue dans ce change ; à surveiller manuellement lors des futures montées de version Flutter.
- [Minutes GitHub Actions] → chaque push/PR consomme des minutes CI (gratuites sur repo public, limitées sur repo privé). Mitigation : `cache: true` réduit le temps d'installation Flutter ; le repo `alainbenard54-collab/cavea` — à vérifier s'il est public ou privé, sans impact sur la décision de ce change.
