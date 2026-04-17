## Why

Le projet Flutter vient d'être initialisé : aucune dépendance métier, aucune base de données, aucune configuration. Cette première étape MVP pose les fondations indispensables pour que l'app soit utilisable — configuration au premier lancement, modèle de données drift, et import des bouteilles existantes depuis un fichier CSV.

## What Changes

- Ajout de toutes les dépendances Flutter/Dart nécessaires (`drift`, `flutter_riverpod`, `go_router`, `shared_preferences`, `file_picker`, `flutter_dotenv`, `uuid`, `path_provider`, `path`)
- Wizard de premier lancement : détecte l'absence de configuration, guide l'utilisateur (Mode 1 uniquement) et persiste les préférences
- Support fichier `.env` (Windows avancé) pour pré-configurer sans passer par le wizard
- Modèle drift complet : table `bouteilles` avec tous les champs ARCHITECTURE.md, migrations déclaratives
- DAO `BouteilleDao` : CRUD de base et requête "toutes les bouteilles en stock"
- Providers Riverpod pour la base et le DAO
- Feature import CSV : file picker, parse UTF-8 séparateur `;`, gestion UUID, rapport d'import
- `main.dart` et `router.dart` minimaux : l'app démarre, passe par le wizard ou directement à l'écran principal selon l'état de la config
- Modes 2 et 3 : sélectionnables dans le wizard mais marqués "Non disponible dans cette version"

## Capabilities

### New Capabilities

- `app-config`: Configuration de l'application — lecture `.env`, SharedPreferences, wizard de premier lancement, persistance du mode et du chemin `cave.db`
- `bouteilles-db`: Modèle de données drift — table `bouteilles`, migrations, DAO, providers Riverpod
- `import-csv`: Import de bouteilles depuis un fichier CSV — file picker, parsing, gestion doublons par UUID, rapport

### Modified Capabilities

_(aucune — projet vierge, pas de spec existante)_

## Impact

- `pubspec.yaml` : ajout de 9 dépendances runtime + 2 dev
- `lib/` : création de l'arborescence complète (`core/`, `data/`, `features/setup/`, `features/import_csv/`, `app/`)
- Plateforme : **Mode 1 uniquement** (dart:io direct, Windows desktop)
- Android compilable mais wizard Mode 2/3 non fonctionnel (bloqué "Non disponible")
- Pas de sync, pas de StorageAdapter dans ce change

## Non-goals

- Modes 2 et 3 (cloud, StorageAdapter, OAuth) — hors périmètre MVP étape 1
- Vue stock, filtres, "à boire", consommation — étapes MVP suivantes
- Export CSV, historique, statistiques — V1/V2
- Validation avancée du formulaire d'import (tolérance d'erreur basique suffit)
