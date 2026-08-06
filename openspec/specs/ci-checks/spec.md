## Purpose

Garantit que `flutter analyze` et `flutter test` sont exécutés automatiquement sur GitHub Actions à chaque push et pull request vers `master`, sans dépendre d'une exécution manuelle par le mainteneur.

## Requirements

### Requirement: Workflow GitHub Actions exécutant analyze et test sur push/PR vers master
Le projet SHALL contenir `.github/workflows/ci.yml` s'exécutant sur `ubuntu-latest`, déclenché par `push` sur la branche `master` et par `pull_request` ciblant `master`.

Le workflow SHALL :
- Checkout le code source
- Installer Flutter `3.44.0` (stable) via `subosito/flutter-action@v2` avec `cache: true`
- Exécuter `flutter pub get`
- Exécuter `flutter analyze`
- Exécuter `flutter test`

Le workflow SHALL échouer (statut rouge sur GitHub) si `flutter analyze` remonte au moins une erreur ou si `flutter test` remonte au moins un échec.

#### Scenario: Push sur master avec code valide
- **WHEN** un commit est poussé sur `master` et que `flutter analyze` / `flutter test` ne remontent aucune erreur ni échec
- **THEN** le workflow `ci.yml` se déclenche et se termine avec un statut vert

#### Scenario: Push sur master avec une erreur d'analyse
- **WHEN** un commit poussé sur `master` introduit une erreur détectée par `flutter analyze`
- **THEN** le workflow `ci.yml` se déclenche et se termine avec un statut rouge, sans empêcher le push lui-même (aucune règle de protection de branche associée)

#### Scenario: Pull request vers master
- **WHEN** une pull request est ouverte ou mise à jour avec `master` comme branche cible
- **THEN** le workflow `ci.yml` se déclenche sur le commit de la pull request et son statut est visible dans la pull request

#### Scenario: Push sur une branche autre que master
- **WHEN** un commit est poussé sur une branche qui n'est ni `master` ni la source d'une pull request vers `master`
- **THEN** le workflow `ci.yml` ne se déclenche pas

#### Scenario: Échec de test
- **WHEN** `flutter test` remonte au moins un échec, même si `flutter analyze` ne remonte aucune erreur
- **THEN** le workflow `ci.yml` se termine avec un statut rouge
