## 1. Mise à jour pubspec.yaml et lock

- [x] 1.1 Mettre à jour la contrainte SDK dans `pubspec.yaml` : `^3.11.4` → `^3.12.0` (PC + Linux)
- [x] 1.2 Exécuter `flutter pub get` pour régénérer `pubspec.lock` avec les 4 dépendances mises à jour (meta, test, test_api, test_core)

## 2. Vérification qualité (Windows)

- [x] 2.1 Exécuter `flutter analyze` → 0 issues
- [x] 2.2 Exécuter `flutter test` → 122/122 ✅

## 3. Documentation

- [x] 3.1 Mettre à jour `ARCHITECTURE.md` : version Flutter 3.41.9 → 3.44.0, Dart 3.11.5 → 3.12.0

## 4. Commit et vérification build

- [x] 4.1 Commiter les fichiers modifiés (`pubspec.yaml`, `pubspec.lock`, `ARCHITECTURE.md`)
- [x] 4.2 Demander à l'utilisateur de lancer `flutter build windows --release` et confirmer le succès
