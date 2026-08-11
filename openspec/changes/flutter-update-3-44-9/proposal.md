## Why

Flutter 3.44.0 (pin actuel du projet, sorti le 2026-05-18) n'est plus la dernière version stable. Le flux officiel des releases (`releases_windows.json`) confirme que `3.44.9` (sortie le 2026-08-06) est la dernière stable réelle, toujours dans la branche mineure 3.44.x — donc composée uniquement de correctifs de patch, pas de la prochaine minor 3.47 (visait août 2026, pas encore sortie). C'est la troisième montée de version du projet, après `flutter-update` (2026-05-18, 3.41.6→3.41.9) et `flutter-update` (2026-05-24, 3.41.9→3.44.0), toutes deux archivées.

## What Changes

- `.github/workflows/ci.yml` : pin `flutter-version` `'3.44.0'` → `'3.44.9'`
- `.github/workflows/release-windows.yml` : même pin
- `ARCHITECTURE.md` : mention de version mise à jour (3.44.0 → 3.44.9, Dart 3.12.0 → 3.12.2)
- Mise à jour de l'installation Flutter locale de l'utilisateur (Windows) vers 3.44.9
- `pubspec.yaml` : la contrainte `sdk: ^3.12.0` est probablement inchangée — Dart 3.12.2 la satisfait déjà (à confirmer après `flutter --version` local)
- Aucun changement de code applicatif Dart attendu (bump de patch, pas de breaking change côté API Flutter/Dart)

## Capabilities

### New Capabilities
*(aucune)*

### Modified Capabilities
*(aucune)* — `skip_specs: true` déclaré dans `.openspec.yaml`. La capacité `sdk-version` existante (`openspec/specs/sdk-version/spec.md`) est déjà formulée de façon générique ("dernière version stable du SDK Flutter disponible au moment de la mise à jour") : son texte reste vrai après ce bump, aucune modification de contenu nécessaire.

## Impact

- Tous les modes (1, 2, 3) — pas d'impact fonctionnel, uniquement outillage/CI
- Point de vigilance distinct (documenté dans design.md) : le runner GitHub Actions `windows-latest` a basculé en juin 2026 de Visual Studio 2022 vers Visual Studio 2026 / Windows Server 2025 sous le même label flottant — changement indépendant de ce bump Flutter, mais à surveiller au premier run CI après ce change

## Non-goals

- Attendre ou anticiper la minor 3.47 — décision utilisateur explicite de cibler 3.44.9 maintenant
- Mise à jour des dépendances tierces (`googleapis`, `file_picker`, etc.) au-delà de ce qu'entraîne mécaniquement `flutter pub get` — hors scope, comme pour les deux montées précédentes
- Créer une nouvelle capacité dédiée à la version (le change du 2026-05-24 avait introduit `toolchain-version` avec un numéro figé — capacité aujourd'hui disparue des specs actuelles ; ce change s'appuie sur `sdk-version`, déjà générique, sans dupliquer)
