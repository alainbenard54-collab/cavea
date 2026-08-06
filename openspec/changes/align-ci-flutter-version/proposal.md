## Why

`.github/workflows/ci.yml` (change `add-ci-analyze-test`, en pause) échoue dès `flutter pub get` : `pubspec.yaml` exige `sdk: ^3.12.0` mais la version Flutter épinglée `3.41.9` embarque Dart `3.11.5`. En vérifiant l'historique des runs Actions, `.github/workflows/release-windows.yml` (même pin `3.41.9`) a le même problème — son run sur le tag `v1.2.0` (2026-06-11) a échoué à l'identique. C'est un défaut préexistant, sans rapport avec l'ajout du nouveau workflow CI, resté inaperçu car l'utilisateur build/upload les releases Windows manuellement (`.local/build-commands.md`), pas via ce workflow automatisé — l'asset de la release v1.2.0 est bien présent sur GitHub malgré l'échec du workflow.

## What Changes

- Épingler `flutter-version: '3.44.0'` (au lieu de `3.41.9`) dans `.github/workflows/ci.yml`.
- Épingler `flutter-version: '3.44.0'` (au lieu de `3.41.9`) dans `.github/workflows/release-windows.yml`.
- Aucun autre changement dans ces deux fichiers (déclencheurs, runners, structure des étapes inchangés).
- `3.44.0` est un choix délibéré et exact — c'est la version Flutter locale actuelle de l'utilisateur (Dart 3.12.0, satisfait `sdk: ^3.12.0`), celle qui a effectivement construit la release v1.2.0 avec succès. Ce n'est pas un `flutter upgrade` vers la dernière version stable disponible ; cette décision reste distincte et à traiter plus tard.

## Capabilities

### New Capabilities
(aucune)

### Modified Capabilities
- `windows-ci-release` : la version Flutter installée par le workflow passe de `3.41.9` à `3.44.0` pour satisfaire la contrainte `sdk: ^3.12.0` de `pubspec.yaml`.

## Impact

- `.github/workflows/release-windows.yml` : modification du pin `flutter-version`.
- `.github/workflows/ci.yml` : modification du même pin. Ce fichier appartient au change `add-ci-analyze-test`, actuellement en pause (4/7 tâches) et non archivé — sa capacité `ci-checks` n'existe donc encore que comme delta spec dans `openspec/changes/add-ci-analyze-test/specs/ci-checks/spec.md`, pas dans `openspec/specs/`. Ce n'est pas une capacité modifiable au sens OpenSpec standard pour l'instant ; cette modification est traitée ici comme un impact d'implémentation direct sur un fichier déjà committé dans le repo, sans delta spec dédié.
- **Effet de bord assumé** : après ce change, le texte de `add-ci-analyze-test/specs/ci-checks/spec.md` restera obsolète (il mentionne encore `Flutter 3.41.9`) jusqu'à ce que `add-ci-analyze-test` soit repris. Ce n'est pas corrigé par ce change-ci — à traiter explicitement à la reprise de `add-ci-analyze-test`.
- Aucun changement de code applicatif Dart/Flutter, aucun impact sur les Modes 1/2/3.
