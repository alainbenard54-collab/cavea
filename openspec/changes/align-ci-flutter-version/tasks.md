## 1. Mise à jour des workflows

- [x] 1.1 Modifier `flutter-version: '3.41.9'` → `flutter-version: '3.44.0'` dans `.github/workflows/ci.yml` (infrastructure CI, aucun code applicatif PC/Android)
- [x] 1.2 Modifier `flutter-version: '3.41.9'` → `flutter-version: '3.44.0'` dans `.github/workflows/release-windows.yml` (infrastructure CI, aucun code applicatif PC/Android)

## 2. Vérification

- [x] 2.1 Committer et pousser, puis vérifier sur GitHub Actions que le run `CI` déclenché sur ce push passe `flutter pub get` (résolution SDK OK) — confirmé : `pub get` réussit désormais avec Flutter 3.44.0. Le run reste toutefois rouge pour une raison sans rapport avec la version Flutter (voir note ci-dessous) ; "se termine au vert" n'est donc pas entièrement vérifié, hors périmètre de ce change.
- [x] 2.2 Confirmer que `release-windows.yml` n'est pas déclenché par ce push (toujours conditionné au tag `v*`) — vérification statique du fichier, pas de tag à pousser dans ce change
