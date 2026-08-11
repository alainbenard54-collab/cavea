## Context

`ci.yml` et `release-windows.yml` épinglent Flutter en dur (`subosito/flutter-action@v2`, `flutter-version: '3.44.0'`), tous deux sur `runs-on: windows-latest` (sauf `ci.yml` qui tourne sur `ubuntu-latest` — seul `release-windows.yml` est concerné par le runner Windows). `pubspec.yaml` porte la contrainte `sdk: ^3.12.0`. Voir proposal.md pour la motivation du bump vers 3.44.9.

Aucune couche de stockage n'est concernée (ni `dart:io` Mode 1, ni `StorageAdapter` Mode 2/3) — ce change ne touche que l'outillage de build.

## Goals / Non-Goals

**Goals:**
- Aligner le pin Flutter local, CI (`ci.yml`) et release (`release-windows.yml`) sur 3.44.9
- Documenter, sans les corriger maintenant, les points de vigilance liés au runner CI Windows

**Non-Goals:**
- Corriger préventivement le runner `windows-latest` (VS2026/Windows Server 2025) — voir Risks
- Toucher au gap `--dart-define-from-file` de `release-windows.yml` (déjà identifié séparément, traité au moment de la prochaine vraie release v1.3.0, pas ici)

## Decisions

### D1 — Ne pas épingler `windows-2022` en préventif

**Choix** : garder `runs-on: windows-latest` dans `release-windows.yml`, ne pas basculer vers `windows-2022` par anticipation du risque VS2026.

**Pourquoi** : le risque (chaîne de build Windows native de Flutter pas encore validée sur VS2026/Windows Server 2025) est une hypothèse, pas un problème observé. `windows-latest` a déjà basculé début juin 2026 — si un run CI avait cassé depuis, on l'aurait su via `ci.yml` (`ubuntu-latest`, non concerné) ou un build manuel. Épingler `windows-2022` sans preuve de problème ajouterait de la dette (image qui vieillit, désynchro avec l'écosystème) pour un risque non confirmé.

**Alternative rejetée** : épingler `windows-2022` par précaution. Rejetée — correctif prématuré pour un problème hypothétique, hors du périmètre de ce change (bump Flutter, pas audit CI).

**Mitigation si le risque se matérialise** : si `release-windows.yml` échoue après ce bump, diagnostiquer d'abord si la cause est Flutter 3.44.9 ou l'image VS2026 (en testant localement avec 3.44.9 sur le PC Windows de l'utilisateur, qui tourne sur son propre OS, indépendant du runner GitHub) avant de choisir entre pin `windows-2022` ou autre correctif.

## Risks / Trade-offs

- **[Risque] Runner `windows-latest` sur VS2026/Windows Server 2025 depuis juin 2026** → Mitigation : voir D1, diagnostiquer au premier run CI post-bump plutôt que de corriger à l'aveugle.
- **[Risque] Régression silencieuse non détectée par `flutter analyze`/`flutter test`** (comportement runtime différent entre patchs Flutter) → Mitigation : vérification manuelle des 3 plateformes (Windows, Linux, Android) avant de considérer la tâche terminée, comme pour les deux montées de version précédentes.
