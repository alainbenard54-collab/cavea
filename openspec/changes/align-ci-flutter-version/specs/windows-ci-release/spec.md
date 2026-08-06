## MODIFIED Requirements

### Requirement: Workflow GitHub Actions publiant l'installateur Windows sur chaque tag v*
Le projet SHALL contenir `.github/workflows/release-windows.yml` s'exécutant sur `windows-latest` lors d'un push de tag correspondant à `v*`.

Le workflow SHALL :
- Checkout le code source
- Installer Flutter `3.44.0` via `subosito/flutter-action@v2`
- Exécuter `flutter pub get` puis `flutter build windows --release`
- Compiler l'installateur via `iscc windows/packaging/cavea.iss`
- Uploader `Cavea-{tag}-windows-setup.exe` comme asset de la GitHub Release via `softprops/action-gh-release@v2`

#### Scenario: Push d'un tag v1.0.0
- **WHEN** le mainteneur exécute `git push origin v1.0.0`
- **THEN** le workflow se déclenche, produit `Cavea-v1.0.0-windows-setup.exe` et l'attache à la release GitHub v1.0.0

#### Scenario: Push sur master sans tag
- **WHEN** un commit est poussé sur master sans tag
- **THEN** le workflow ne se déclenche pas

#### Scenario: Tag non-release (ex: v1.0.0-beta)
- **WHEN** le mainteneur pousse un tag `v1.0.0-beta`
- **THEN** le workflow se déclenche et publie l'asset sur la pre-release correspondante

#### Scenario: Résolution des dépendances compatible avec la contrainte SDK du projet
- **WHEN** le workflow exécute `flutter pub get`
- **THEN** la version Flutter installée (`3.44.0`, Dart 3.12.0) satisfait la contrainte `sdk: ^3.12.0` de `pubspec.yaml`, et la résolution des dépendances réussit
