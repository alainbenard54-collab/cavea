## Context

Le projet tourne sur Flutter 3.41.6 (Windows natif) et 3.41.9 (Linux VM). Les dépendances pubspec.yaml ont été figées lors de la phase V1. Les commandes Flutter s'exécutent sur Windows natif — Claude ne peut pas les lancer directement ; chaque étape requiert une action manuelle de l'utilisateur suivie d'un retour de résultat.

Stack à mettre à jour (ordre de risque décroissant) :
- `drift` / `drift_dev` : ORM avec code-gen — une mise à jour majeure peut changer le schéma généré
- `flutter_riverpod` / `riverpod` : state management — les versions majeures ont cassé des APIs par le passé
- `go_router` : navigation — les versions majeures changent parfois la signature des `GoRoute`
- `intl` : étroitement couplé à `flutter_localizations` — doit rester aligné avec la version Flutter
- `googleapis` / `google_sign_in` / `flutter_secure_storage` : stack Mode 2 (sync Drive/Dropbox)
- `share_plus`, `file_picker`, `path_provider` : utilitaires fichiers
- `flutter_launcher_icons`, `build_runner` : dev_dependencies, sans impact runtime

## Goals / Non-Goals

**Goals:**
- SDK Flutter à la dernière version stable disponible au moment de l'exécution
- Toutes les dépendances à leur dernière version compatible
- Suite de tests (78 cas) : 0 régression
- `flutter analyze` : 0 erreur, 0 warning nouveau
- pubspec.yaml `sdk:` contrainte mise à jour si nécessaire

**Non-Goals:**
- Introduire de nouvelles dépendances
- Refactorer le code existant au-delà des corrections imposées par les breaking changes
- Modifier les specs fonctionnelles ou la logique métier
- Mettre à jour le scaffold `linux/` (celui-ci n'est pas dans le repo, régénéré localement)

## Decisions

### D1 — Ordre d'upgrade : SDK d'abord, dépendances ensuite

`flutter upgrade` met à jour le SDK et le Dart bundlé. Seulement après, `flutter pub upgrade --major-versions` calcule les versions compatibles avec le nouveau SDK. Inverser l'ordre produit des contraintes incohérentes.

**Alternatif rejeté** : mettre à jour les versions dans pubspec.yaml manuellement → erreur-prone, ne profite pas du solveur pub.

### D2 — Utiliser `--major-versions` pour accepter les bumps majeurs

Sans ce flag, pub ne franchit jamais une limite de version majeure (ex : go_router ^13 → ^14). Avec ce flag, pub propose les dernières majeures compatibles et liste les incompatibilités.

**Alternatif rejeté** : `flutter pub upgrade` seul → reste dans les bornes des contraintes actuelles, ne trouve pas les nouvelles majeures.

### D3 — Relancer build_runner après toute mise à jour drift

drift génère `*.g.dart` et `*.drift.dart` à partir des annotations Dart. Si la version de drift_dev change le format de ces fichiers, les anciens générés causeront des erreurs de compilation. La commande `dart run build_runner build --delete-conflicting-outputs` régénère tout proprement.

**Quand déclencher** : systématiquement après `flutter pub upgrade`, même si drift ne change pas de version majeure.

### D4 — intl doit rester aligné avec flutter_localizations

Flutter embarque une version précise d'`intl`. Si pubspec.yaml contraint `intl` à une version incompatible, les messages localisés échouent à la compilation. Après upgrade Flutter, vérifier que la contrainte `intl:` dans pubspec.yaml est compatible avec `flutter pub deps | grep intl`.

### D5 — Validation par les tests unitaires existants, pas de tests supplémentaires

Les 78 cas existants couvrent les couches logiques non-UI (DAO, services, controllers). Ils constituent le filet de sécurité pour détecter toute régression introduite par un breaking change non corrigé. Aucun nouveau test n'est requis dans ce change.

## Risks / Trade-offs

**[Risque] Breaking change go_router → Mitigation** : vérifier CHANGELOG go_router avant d'accepter un bump majeur. Les changements les plus courants : signature de `redirect`, suppression de `GoRouterState.location`. Grep `GoRoute(` et `context.go(` dans `lib/` pour identifier les points d'impact.

**[Risque] drift codegen incompatible avec nouveau dart SDK → Mitigation** : si `build_runner` échoue après upgrade, vérifier que drift et drift_dev sont à la même version. Consulter le CHANGELOG drift sur pub.dev.

**[Risque] google_sign_in breaking change (Android/Windows) → Mitigation** : google_sign_in a changé son API d'initialisation entre les majeures. Vérifier `GoogleSignIn()` dans `lib/features/sync/drive_storage_adapter.dart`.

**[Risque] intl désalignement après upgrade Flutter → Mitigation** : si erreur `intl version X not compatible`, contraindre explicitement la version dans pubspec.yaml en suivant la version embarquée par la nouvelle Flutter.

**[Risque] flutter_secure_storage Android platform channel change → Mitigation** : vérifier les options `AndroidOptions` dans `lib/services/config_service.dart` si la version majeure change.

## Migration Plan

1. `flutter upgrade` — met à jour le SDK
2. `flutter pub upgrade --major-versions` — met à jour les dépendances
3. `dart run build_runner build --delete-conflicting-outputs` — régénère le code drift
4. `flutter analyze` — identifie les breaking changes à corriger
5. Corrections Dart si nécessaire (guidées par Claude)
6. `flutter test` — valide 0 régression
7. Mise à jour pubspec.yaml `sdk:` si la contrainte minimale a changé
8. Commit + push

**Rollback** : `git checkout pubspec.yaml pubspec.lock` puis `flutter pub get` restaure l'état précédent si l'upgrade est insatisfaisant. Le code Dart modifié est également réversible via git.

## Open Questions

- Quelles versions exactes seront proposées par `flutter pub upgrade --major-versions` ? (à découvrir à l'exécution)
- Des breaking changes nécessiteront-ils des corrections dans `lib/` ? (à identifier via `flutter analyze`)
- La contrainte `sdk:` devra-t-elle être resserrée ou élargie ? (dépend de la nouvelle version Dart bundlée)
