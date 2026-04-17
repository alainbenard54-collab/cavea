## Context

Le projet Flutter `cavea` vient d'être initialisé (`flutter create`). Le `pubspec.yaml` ne contient aucune dépendance métier. Il n'existe pas encore de base de données, ni de couche de configuration, ni d'interface utilisateur. Ce change installe les fondations de l'application : configuration, modèle de données, et premier outil d'alimentation (import CSV).

Contrainte forte : **Mode 1 uniquement** pour ce change. L'accès au stockage se fait via `dart:io` direct (`NativeDatabase`), sans `StorageAdapter`, sans sync.

## Goals / Non-Goals

**Goals:**
- Définir toutes les dépendances Flutter/Dart nécessaires au projet
- Implémenter un `ConfigService` qui abstrait la lecture `.env` / SharedPreferences
- Implémenter un wizard de premier lancement (Mode 1 uniquement opérationnel)
- Créer le schéma drift complet (`bouteilles`) avec migrations
- Exposer la base et le DAO via Riverpod
- Implémenter l'import CSV avec file picker, gestion UUID, rapport

**Non-Goals:**
- StorageAdapter, SyncService, DriveStorageAdapter, DropboxStorageAdapter
- Vue stock, filtres, "à boire", consommation, ajout manuel de bouteilles
- Modes 2 et 3 fonctionnels

---

## Decisions

### D1 — Configuration : `.env` + SharedPreferences (pas de fichier JSON custom)

**Choix** : `flutter_dotenv` pour lire `.env` (Windows avancé) + `shared_preferences` pour persister la config issue du wizard.

**Pourquoi** : `shared_preferences` est le standard Flutter pour les préférences utilisateur — invisible, multi-plateforme, aucune gestion de chemin. Le `.env` est un bonus pour les power users Windows qui veulent pré-configurer, géré par `flutter_dotenv`. Évite d'inventer un troisième format.

**Alternative écartée** : Stocker la config dans un fichier JSON dans `AppData`. Plus de contrôle mais plus de code de sérialisation, pas de gain pour le cas d'usage.

**Fichiers concernés** : `lib/core/config_service.dart`

---

### D2 — Drift : `NativeDatabase` via `drift_flutter`

**Choix** : `drift_flutter` expose `NativeDatabase` pour Windows/Android. Le chemin est fourni par `ConfigService`. Pas de `LazyDatabase` wrapping inutile pour le Mode 1.

**Fichiers concernés** : `lib/data/database.dart`, `lib/data/providers.dart`

```
lib/data/
├── database.dart         ← @DriftDatabase, table Bouteilles, schéma v1
├── tables/
│   └── bouteilles.dart   ← définition drift de la table
├── daos/
│   └── bouteille_dao.dart
└── providers.dart        ← appDatabaseProvider, bouteillesDaoProvider
```

---

### D3 — Riverpod : providers async pour la base

**Choix** : `appDatabaseProvider` est un `Provider<AppDatabase>` initialisé via `ProviderScope.overrides` au démarrage (après résolution du chemin par `ConfigService`). Les widgets consomment `bouteillesDaoProvider` sans connaître le chemin.

**Pourquoi** : Permet d'injecter la base après configuration, sans reconstruire l'arbre entier. Pattern standard Riverpod pour les ressources initialisées async.

---

### D4 — Wizard : go_router avec redirection initiale

**Choix** : Au démarrage, `main.dart` appelle `ConfigService.load()`. Si aucune config → route `/setup`. Sinon → route `/`. go_router gère la redirection déclarativement.

```
lib/app/router.dart      ← routes: /setup, /, /import-csv
lib/features/setup/
├── setup_screen.dart    ← wizard multi-étapes (mode → chemin → confirmation)
└── setup_controller.dart
```

---

### D5 — Import CSV : parser maison (pas de dépendance csv externe)

**Choix** : Parser le CSV manuellement avec `String.split(';')` et traitement ligne par ligne. Pas de package `csv` externe.

**Pourquoi** : Le format est simple et fixe (séparateur `;`, pas de champs avec `;` entre guillemets dans `cave_clean.csv`). Ajouter un package pour 20 lignes de parsing serait du sur-engineering. Si le format se complexifie (champs avec guillemets), on ajoutera `package:csv` alors.

**Gestion de l'encodage** : `File.readAsString(encoding: utf8)` — le CSV est UTF-8.

**Fichiers concernés** :
```
lib/features/import_csv/
├── import_csv_screen.dart    ← file picker, case "écraser", bouton import, rapport
├── csv_parser.dart           ← parse String → List<BouteilleCompanion>
└── import_service.dart       ← orchestration : parse → insert/update/skip
```

---

### D6 — UUID : package `uuid` v4

**Choix** : `Uuid().v4()` pour générer les UUIDs des lignes sans `id` dans le CSV. Même générateur utilisé pour les futures insertions manuelles.

---

## Arborescence complète créée par ce change

```
lib/
├── main.dart                          ← ProviderScope, chargement config, CaveApp
├── app/
│   ├── router.dart                    ← go_router
│   └── theme.dart                     ← Material 3 theme (minimal)
├── core/
│   └── config_service.dart            ← lecture .env + SharedPreferences
├── data/
│   ├── database.dart                  ← @DriftDatabase
│   ├── tables/
│   │   └── bouteilles.dart            ← table drift
│   ├── daos/
│   │   └── bouteille_dao.dart         ← CRUD + watchStock()
│   └── providers.dart                 ← appDatabaseProvider, bouteillesDaoProvider
├── features/
│   ├── setup/
│   │   ├── setup_screen.dart
│   │   └── setup_controller.dart
│   └── import_csv/
│       ├── import_csv_screen.dart
│       ├── csv_parser.dart
│       └── import_service.dart
└── shared/
    └── adaptive_layout.dart           ← stub (sera étoffé à l'étape 2)
```

**pubspec.yaml — dépendances runtime à ajouter :**
```yaml
drift: ^2.20.0
drift_flutter: ^0.2.0
flutter_riverpod: ^2.6.0
riverpod: ^2.6.0
go_router: ^14.0.0
shared_preferences: ^2.3.0
file_picker: ^8.1.0
flutter_dotenv: ^5.2.0
uuid: ^4.5.0
path_provider: ^2.1.0
path: ^1.9.0
```

**dev_dependencies :**
```yaml
build_runner: ^2.4.0
drift_dev: ^2.20.0
```

---

## Risks / Trade-offs

**[Risque] Encodage du CSV** → Le fichier `cave_clean.csv` est UTF-8. Si un utilisateur fournit un CSV en Latin-1 (Windows-1252), les accents seront corrompus. Mitigation : afficher un avertissement si des caractères de remplacement (U+FFFD) sont détectés après parsing.

**[Risque] Versions des packages drift** → drift v2.20+ requiert Dart ≥ 3.3. Flutter 3.41.6 embarque Dart ≥ 3.5 — compatible. Vérifier `pubspec.lock` après `flutter pub get`.

**[Trade-off] Parser CSV maison** → Fragile si des valeurs contiennent `;` entre guillemets. Acceptable pour `cave_clean.csv` dont on connaît le format. À remplacer par `package:csv` si nécessaire.

**[Risque] file_picker sur Windows** → Nécessite aucune permission spéciale. Sur Android, requiert `READ_EXTERNAL_STORAGE` (Android < 13) ou `READ_MEDIA_*` (Android 13+) — à configurer dans `android/app/src/main/AndroidManifest.xml`.

## Open Questions

_(aucune question ouverte — périmètre du change clarifié)_
