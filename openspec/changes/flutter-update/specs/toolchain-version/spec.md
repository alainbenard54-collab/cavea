## ADDED Requirements

### Requirement: Toolchain Flutter 3.44.0 / Dart 3.12.0
Le projet SHALL déclarer une contrainte SDK minimale de `^3.12.0` dans `pubspec.yaml` et être compilable sans erreur avec Flutter 3.44.0.

#### Scenario: Analyse statique propre
- **WHEN** `flutter analyze` est exécuté sur le codebase
- **THEN** le résultat est "No issues found!"

#### Scenario: Suite de tests intacte
- **WHEN** `flutter test` est exécuté
- **THEN** tous les tests passent (0 failure)

#### Scenario: Build Windows release
- **WHEN** `flutter build windows --release` est exécuté
- **THEN** le binaire est produit sans erreur de compilation
