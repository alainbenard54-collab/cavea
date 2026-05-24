## Why

Flutter 3.41.9 / Dart 3.11.5 ont été remplacés par Flutter 3.44.0 / Dart 3.12.0 (stable, sortie 15 mai 2026). La mise à jour aligne Windows et Linux sur la même version avant la release v1.1.0.

## What Changes

- `pubspec.yaml` : contrainte SDK `^3.11.4` → `^3.12.0`
- `pubspec.lock` : 4 dépendances mises à jour (meta, test, test_api, test_core)
- `ARCHITECTURE.md` : mention de la version Flutter mise à jour

## Capabilities

### New Capabilities

Aucune.

### Modified Capabilities

Aucune — aucun changement de comportement applicatif, uniquement une montée de version d'outillage.

## Non-goals

- Mise à jour des dépendances tierces (`googleapis`, `file_picker`, etc.) — hors scope
- Changements de code liés à des breaking changes Dart 3.12 — aucun identifié (`flutter analyze` 0 issues)

## Impact

- Tous les modes (1, 2) — pas d'impact fonctionnel
- `flutter analyze` : 0 issues ✅
- `flutter test` : 122/122 ✅
- `flutter build windows --release` : à vérifier après commit
