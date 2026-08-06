## 1. Workflow CI

- [x] 1.1 Créer `.github/workflows/ci.yml` avec déclencheurs `push` sur `master` et `pull_request` ciblant `master` (infrastructure CI, aucun code applicatif PC/Android)
- [x] 1.2 Configurer le job sur `ubuntu-latest`, checkout du code, installation Flutter `3.44.0` via `subosito/flutter-action@v2` (`channel: stable`, `cache: true`) — version corrigée par le change `align-ci-flutter-version` (le pin initial `3.41.9` était incompatible avec `sdk: ^3.12.0` de `pubspec.yaml`)
- [x] 1.3 Ajouter les étapes `flutter pub get`, `flutter analyze`, `flutter test`

## 2. Vérification

- [x] 2.1 Pousser et vérifier que le workflow `ci.yml` se déclenche et passe au vert — confirmé : run https://github.com/alainbenard54-collab/cavea/actions/runs/31096937618 (commit 185b5b4) vert de bout en bout (pub get, analyze, test)
- [x] 2.2 Vérifier que le workflow ne se déclenche pas sur un push vers une branche qui n'est ni `master` ni source d'une PR vers `master`
- [x] 2.3 Confirmer que `release-windows.yml` n'est pas impacté (toujours déclenché uniquement sur tag `v*`)

## 3. Documentation

- [x] 3.1 Mentionner le nouveau workflow CI dans `.local/build-commands.md` (la CI automatise désormais ce qui y est documenté manuellement — ne pas supprimer la procédure manuelle, elle reste utile en local avant tout build de release)
