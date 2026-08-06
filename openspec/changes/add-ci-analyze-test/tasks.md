## 1. Workflow CI

- [x] 1.1 Créer `.github/workflows/ci.yml` avec déclencheurs `push` sur `master` et `pull_request` ciblant `master` (infrastructure CI, aucun code applicatif PC/Android)
- [x] 1.2 Configurer le job sur `ubuntu-latest`, checkout du code, installation Flutter `3.41.9` via `subosito/flutter-action@v2` (`channel: stable`, `cache: true`)
- [x] 1.3 Ajouter les étapes `flutter pub get`, `flutter analyze`, `flutter test`

## 2. Vérification

- [ ] 2.1 Pousser une branche de test (ou ouvrir une PR) et vérifier que le workflow `ci.yml` se déclenche et passe au vert sur le code actuel
- [ ] 2.2 Vérifier que le workflow ne se déclenche pas sur un push vers une branche qui n'est ni `master` ni source d'une PR vers `master`
- [ ] 2.3 Confirmer que `release-windows.yml` n'est pas impacté (toujours déclenché uniquement sur tag `v*`)

## 3. Documentation

- [x] 3.1 Mentionner le nouveau workflow CI dans `.local/build-commands.md` (la CI automatise désormais ce qui y est documenté manuellement — ne pas supprimer la procédure manuelle, elle reste utile en local avant tout build de release)
