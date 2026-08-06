## Why

`flutter analyze` et `flutter test` sont aujourd'hui des vérifications purement manuelles, documentées dans `.local/build-commands.md` (non versionné) et attendues à 0 erreur/échec avant tout build de release. Rien ne garantit qu'elles sont réellement exécutées avant un push ou une release — le seul workflow GitHub Actions existant (`release-windows.yml`) ne fait que builder et publier l'installateur sur tag, il ne valide ni le code ni les tests en amont. C'est un écart documenté avec le référentiel de gouvernance externe `claude-project-standards`.

## What Changes

- Ajout d'un nouveau workflow GitHub Actions `.github/workflows/ci.yml` exécutant `flutter analyze` puis `flutter test` sur runner `ubuntu-latest`.
- Déclencheurs : `push` sur `master` et `pull_request` ciblant `master`.
- Flutter épinglé en `3.41.9` (même version que `release-windows.yml`), installé via `subosito/flutter-action@v2` avec `cache: true`.
- Le check est informatif à ce stade : aucune règle de protection de branche n'est configurée en parallèle, un échec n'empêche pas un merge ou un push. Ce point pourra être reconsidéré plus tard (hors périmètre de ce change).
- Périmètre volontairement limité à `analyze` + `test`, à l'identique de ce qui est documenté dans `.local/build-commands.md` — pas d'ajout d'un check `dart format` (ce ne serait pas une pratique actuelle du projet).

## Capabilities

### New Capabilities
- `ci-checks`: workflow GitHub Actions exécutant `flutter analyze` et `flutter test` sur push/PR vers `master`, en complément du workflow `windows-ci-release` existant qui ne couvre que le build de release sur tag.

### Modified Capabilities
(aucune — `windows-ci-release` n'est pas modifié par ce change)

## Impact

- Nouveau fichier : `.github/workflows/ci.yml`.
- Aucun changement de code applicatif Dart/Flutter.
- Aucun impact sur les Modes 1/2/3 ni sur `StorageAdapter`/`SyncService`.
- Dépendance externe ajoutée : action `subosito/flutter-action@v2` (déjà utilisée par `release-windows.yml`, pas une nouvelle dépendance pour le projet).
