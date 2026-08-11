## 1. Mise à jour locale (Windows, utilisateur)

- [x] 1.1 Mettre à jour l'installation Flutter locale vers 3.44.9 (`flutter upgrade --force`, forcé après vérification que le seul changement local du SDK était `pubspec.lock` interne, sans valeur)
- [x] 1.2 Confirmer via `flutter --version` : Flutter 3.44.9, Dart 3.12.2 ✅

## 2. Vérification de la contrainte SDK (PC)

- [x] 2.1 Vérifier que `sdk: ^3.12.0` dans `pubspec.yaml` reste satisfait par Dart 3.12.2 (aucune modification attendue) — confirmer via `flutter pub get` sans erreur
- [x] 2.2 Exécuter `flutter pub get` et vérifier l'absence de changement inattendu dans `pubspec.lock`

## 3. Mise à jour des pins CI/release (PC + GitHub Actions)

- [x] 3.1 `.github/workflows/ci.yml` : `flutter-version: '3.44.0'` → `'3.44.9'`
- [x] 3.2 `.github/workflows/release-windows.yml` : même pin `'3.44.0'` → `'3.44.9'`
- [x] 3.3 `ARCHITECTURE.md` : mettre à jour la mention de version (Flutter 3.44.0 → 3.44.9, Dart 3.12.0 → 3.12.2)

## 4. Vérification qualité (PC)

- [x] 4.1 `flutter analyze` → 0 issue
- [x] 4.2 `flutter test` → 0 régression (149/149 attendu, aligné sur le dernier run connu)

## 5. Vérification build multi-plateforme

- [ ] 5.1 PC : `flutter build windows --release --dart-define-from-file=dart-defines.json` → succès
- [ ] 5.2 PC : lancer l'app buildée, vérifier le démarrage et l'accès au stock (fumée rapide, pas de test exhaustif)
- [ ] 5.3 Android : `flutter build apk --split-per-abi --release --dart-define-from-file=dart-defines.json` → succès
- [ ] 5.4 Linux (VM Ubuntu) : `git pull` + `flutter build linux --release` → succès

## 6. Vérification CI

- [ ] 6.1 Committer et pousser sur `master`, vérifier que `ci.yml` passe (flutter analyze + test sur `ubuntu-latest`)
- [ ] 6.2 Surveiller si un tag `v*` déclenche `release-windows.yml` avant la prochaine vraie release — sinon, noter que ce workflow reste non vérifié en conditions réelles jusqu'à la publication v1.3.0 (cf. gap `--dart-define-from-file` déjà identifié séparément)
