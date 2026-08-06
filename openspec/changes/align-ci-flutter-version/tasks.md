## 1. Mise à jour des workflows

- [x] 1.1 Modifier `flutter-version: '3.41.9'` → `flutter-version: '3.44.0'` dans `.github/workflows/ci.yml` (infrastructure CI, aucun code applicatif PC/Android)
- [x] 1.2 Modifier `flutter-version: '3.41.9'` → `flutter-version: '3.44.0'` dans `.github/workflows/release-windows.yml` (infrastructure CI, aucun code applicatif PC/Android)

## 2. Vérification

- [ ] 2.1 Committer et pousser, puis vérifier sur GitHub Actions que le run `CI` déclenché sur ce push passe `flutter pub get` (résolution SDK OK) et se termine au vert
- [x] 2.2 Confirmer que `release-windows.yml` n'est pas déclenché par ce push (toujours conditionné au tag `v*`) — vérification statique du fichier, pas de tag à pousser dans ce change
