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

- [x] 5.1 PC : build Windows sur Flutter 3.44.9 → succès (via `release-windows.yml`, tags v1.3.0/v1.3.1)
- [x] 5.2 PC : app installée et testée manuellement (démarrage, stock, mode partagé) sur v1.3.0 et v1.3.1
- [x] 5.3 Android : `flutter build apk --split-per-abi` sur Flutter 3.44.9 → succès (build v1.3.1, 3 APK générés)
- [x] 5.4 Linux (VM Ubuntu) : Flutter VM aligné en 3.44.9 (`git checkout 3.44.9`), `flutter build linux --release` + `build_linux.sh deb` → succès (v1.3.0 et v1.3.1, testé fonctionnel)

## 6. Vérification CI

- [x] 6.1 `ci.yml` vert sur `master` avec Flutter 3.44.9 (confirmé à plusieurs reprises pendant le cycle v1.3.0/v1.3.1)
- [x] 6.2 `release-windows.yml` déclenché par tag `v*` et vérifié en conditions réelles à 4 reprises (v1.3.0-rc1, v1.3.0, v1.3.1-rc1, v1.3.1) — le gap `--dart-define-from-file` mentionné avait déjà été corrigé séparément avant ce cycle
