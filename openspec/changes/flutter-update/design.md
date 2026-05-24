## Context

Flutter 3.41.9 / Dart 3.11.5 étaient la version en production. Flutter 3.44.0 / Dart 3.12.0 sont sortis le 15 mai 2026 (canal stable). La mise à jour est effectuée avant la release v1.1.0 pour aligner Windows et Linux sur la même toolchain.

## Goals / Non-Goals

**Goals:**
- Contrainte SDK `pubspec.yaml` alignée sur Dart 3.12.0
- `pubspec.lock` reflétant les 4 dépendances transitives mises à jour
- Documentation (`ARCHITECTURE.md`) à jour

**Non-Goals:**
- Mise à jour des dépendances tierces (googleapis, file_picker, etc.)
- Correction de breaking changes (aucun identifié)

## Decisions

**Contrainte SDK `^3.12.0` plutôt que `>=3.12.0 <4.0.0`** : le caret est la convention Dart standard et équivalent ici — conserve la lisibilité.

**Pas de `flutter pub upgrade`** : `flutter upgrade` + `flutter pub get` suffisent. Monter toutes les dépendances tierces en une seule fois serait un changement de scope non planifié.

## Risks / Trade-offs

[Régression silencieuse Dart 3.12] → Mitigation : `flutter analyze` (0 issues) + `flutter test` (122/122) déjà validés sur Windows avant commit.

[Divergence VM Linux] → Mitigation : VM dispose déjà de Flutter 3.44.0 via snap ; `git pull` suffira après commit.
