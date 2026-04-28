## Context

`ConfigService` (`lib/core/config_service.dart`) gère actuellement `storageMode` et `dbPath` dans SharedPreferences. Il est instancié comme singleton global `configService` et initialisé dans `main()` avant `runApp()`.

`SettingsScreen` (`lib/features/settings/settings_screen.dart`) existe déjà avec deux sections : activation/désactivation Drive, et À propos. Elle sera étendue sans restructuration majeure.

`BulkAddScreen` (`lib/features/bulk_add/bulk_add_screen.dart`) a un `TODO(settings)` explicite en ligne 463 : `const defaultCouleur = 'Rouge'` et une constante identique pour la contenance.

## Goals / Non-Goals

**Goals:**
- Étendre `AppConfig` / `ConfigService` avec `couleurDefaut` et `contenanceDefaut`
- Ajouter dans `SettingsScreen` : section chemin cave.db (Mode 1) + section valeurs par défaut bulk-add
- Remplacer les constantes hardcodées dans `BulkAddScreen` par la lecture de `configService`

**Non-Goals:**
- Configuration Mode 2 (placeholder uniquement — aucune logique)
- Validation du nouveau chemin (présence de `cave.db` ou du dossier)
- Migration automatique de `cave.db` lors du changement de chemin
- Riverpod provider sur ConfigService (le singleton suffit pour des valeurs lues une fois au chargement)

## Decisions

**D1 — Étendre AppConfig avec nullable + fallback dans ConfigService**

`AppConfig` reçoit `couleurDefaut` et `contenanceDefaut` en optionnel (nullable). `ConfigService` retourne des valeurs hardcodées ("Rouge" / "75 cl") si les clés sont absentes de SharedPreferences. Avantage : aucune migration requise, rétrocompatible avec les configs existantes.

Alternative rejetée : valeurs non-nullable avec défauts en dur dans AppConfig. Plus propre, mais force une reconstruction de l'objet à chaque `save()` même quand les settings ne sont pas modifiés.

**D2 — Pas de provider Riverpod pour les defaults bulk-add**

`BulkAddScreen` lit `configService.couleurDefaut` / `configService.contenanceDefaut` directement dans `initState()` / `didChangeDependencies()`. Ces valeurs ne changent pas pendant la session. Pas besoin de reactivité.

**D3 — Changement de chemin cave.db : rechargement de l'app requis**

Modifier `dbPath` à chaud nécessiterait de rouvrir la base drift, ce qui est complexe. Le pattern choisi : sauvegarder le nouveau chemin dans SharedPreferences + afficher un snackbar "Redémarrez l'application pour appliquer le changement". Simple et sans risque.

**D4 — File picker pour le dossier (Mode 1)**

`file_picker` (déjà en dépendance dans `pubspec.yaml`) expose `FilePicker.platform.getDirectoryPath()`. Sur Windows, ouvre un dialog natif de sélection de dossier. Sur Android (Mode 1 hors MVP), la section sera masquée.

## Risks / Trade-offs

- **Chemin invalide après changement** → L'app plantera au prochain démarrage si le dossier n'existe pas. Mitigation : afficher le chemin courant en lecture et demander confirmation. Hors MVP : validation du chemin avant sauvegarde.
- **File picker Android** → `getDirectoryPath()` peut se comporter différemment selon l'API Android. Non bloquant : la section chemin est affichée uniquement en Mode 1 (PC).
