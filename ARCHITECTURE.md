# ARCHITECTURE.md

Décisions techniques retenues pour l'application de gestion de cave à vin.

---

## Plateformes cibles

| Plateforme | Statut |
|---|---|
| Windows | Cible principale (desktop) |
| Android | Cible mobile |
| macOS / Linux | Supporté par Flutter, non prioritaire |
| iOS | Hors périmètre (coût Apple Developer) |

---

## Stack technique

| Couche | Choix | Justification |
|---|---|---|
| Framework | **Flutter 3** (Dart) | Un seul codebase pour desktop et mobile |
| Base de données | **drift** (ex-moor) | ORM SQLite type-safe, migrations déclaratives, streams réactifs |
| State management | **Riverpod** | S'intègre naturellement avec les streams drift, testé, moderne |
| Navigation | **go_router** | Navigation déclarative, gère les routes desktop et mobile dans le même codebase |
| UI | **Material 3** | Composants adaptatifs (NavigationRail desktop, BottomNavigationBar mobile) |
| Stockage fichiers | **dart:io** (PC) + **path_provider** | Accès au système de fichiers local (voir section Stockage) |

---

## Modèle de données

Une seule table `bouteilles`. Une ligne = une bouteille physique.

| Champ | Type | Notes |
|---|---|---|
| `id` | TEXT (UUID) | Clé primaire |
| `domaine` | TEXT | |
| `appellation` | TEXT | |
| `millesime` | INTEGER | |
| `couleur` | TEXT | |
| `cru` | TEXT | nullable |
| `contenance` | TEXT | ex: "Bouteille 75 cL" |
| `emplacement` | TEXT | Hiérarchie texte : `Niveau1 > Niveau2 > Niveau3` |
| `date_entree` | TEXT | Format YYYY-MM-DD |
| `date_sortie` | TEXT | YYYY-MM-DD ou vide → vide = en stock |
| `prix_achat` | REAL | nullable |
| `garde_min` | INTEGER | années |
| `garde_max` | INTEGER | années |
| `commentaire_entree` | TEXT | nullable |
| `note_degus` | REAL | nullable |
| `commentaire_degus` | TEXT | nullable |
| `fournisseur_nom` | TEXT | nullable |
| `fournisseur_infos` | TEXT | nullable |
| `producteur` | TEXT | nullable |
| `updated_at` | TEXT | YYYY-MM-DD HH:MM:SS — pour sync future |

**Règles métier :**
- `date_sortie` vide → bouteille en stock
- `date_sortie` renseignée → bouteille consommée / sortie
- Déplacer une bouteille = modifier `emplacement`, pas une sortie
- Maturité calculée à la volée : `millesime + garde_min/max` vs année courante

---

## Modes de déploiement

### Mode 1 — PC seul (full local)

```
App Flutter Desktop
        ↓
   cave.db (local ou dossier Drive/Dropbox visible localement)
```

Pas d'application mobile. `cave.db` peut se trouver sur n'importe quel chemin local, y compris un dossier synchronisé par le client desktop de Drive/Dropbox/OneDrive — `dart:io` y accède de façon transparente.

---

### Mode 2 — Hybride PC + Mobile (cible principale)

```
App Flutter Desktop  ←→  cave.db (espace partagé)  ←→  App Flutter Android
```

Les deux apps sont issues du **même codebase Flutter**, compilées pour leur plateforme respective.

La synchronisation est manuelle et symétrique (voir section Synchronisation).

---

### Mode 3 — Mobile seul (évolution future, hors MVP)

Fonctionnalités PC à porter sur mobile. Le codebase Flutter le supporte déjà structurellement — c'est une question d'activer les vues et formulaires manquants, pas de changer l'architecture. La question du stockage sur mobile devient alors critique (voir point ouvert ci-dessous).

---

## Mécanisme de synchronisation

Applicable aux modes 2 et 3. Le chemin vers le dossier partagé est **configurable dans les paramètres de l'app**.

### Séquence pour prendre la main

```
1. Vérifier cave.lock dans le dossier partagé
   → présent : ouvrir en lecture seule uniquement
   → absent  : continuer

2. Créer cave.lock (contenu : horodatage + identifiant appareil)

3. Copier cave.db du dossier partagé vers le stockage local de l'app

4. Travailler sur la copie locale
```

### Séquence pour libérer

```
5. Copier cave.db local vers le dossier partagé (écrasement complet)

6. Supprimer cave.lock

7. (Optionnel V1+) Comparer updated_at pour détecter les conflits
```

### Le mécanisme est identique sur toutes les plateformes

Que l'app tourne sur PC ou Android, la séquence lock/copie/travail/remplacement/unlock est la même. Ce qui diffère, c'est uniquement la **couche d'accès au stockage partagé** — pas le mécanisme lui-même.

---

## Stockage — couche d'accès selon le mode

### Mode 1 — PC seul (full local)

Pas de synchronisation. L'app travaille directement sur `cave.db` via `dart:io`. Aucun espace partagé, aucun outil tiers requis.

```dart
// Mode 1 : accès direct dart:io, pas de StorageAdapter
final db = drift.LazyDatabase(() async {
  final file = File('D:/cave/cave.db'); // chemin configurable
  return NativeDatabase(file);
});
```

Le fichier peut résider n'importe où sur le système de fichiers local. Il n'y a pas de lock, pas de copie — une seule copie de `cave.db`, toujours ouverte directement.

---

### Modes 2 et 3 — espace partagé via API cloud

Dès qu'un second appareil est impliqué, **l'accès au stockage partagé passe obligatoirement par l'API du service cloud** (Google Drive ou Dropbox). Il n'est pas requis d'installer un client de synchronisation local — l'app appelle l'API directement, que ce soit depuis PC ou Android.

Ce choix garantit une implémentation uniforme entre les deux plateformes : le `StorageAdapter` a la même interface et la même logique sur PC et sur Android, seules les clés OAuth diffèrent.

| Option | API | Complexité | Statut |
|---|---|---|---|
| **A** | Google Drive API (`googleapis` Dart) | Moyenne | Retenu |
| **B** | Dropbox API | Moyenne | Retenu |

> **Point ouvert #1** — choisir entre A et B (ou supporter les deux) avant de développer le mode synchronisé. Les deux suivent le même pattern `StorageAdapter`.

L'interface `StorageAdapter` est identique quel que soit le service :

```dart
abstract class StorageAdapter {
  Future<bool> isLocked();
  Future<void> writeLock(String deviceId);
  Future<void> deleteLock();
  Future<void> download(String localPath);   // cloud → local
  Future<void> upload(String localPath);     // local → cloud
}
```

Les implémentations concrètes (`DriveStorageAdapter`, `DropboxStorageAdapter`) encapsulent OAuth et les appels API — le `SyncService` n'en sait rien.

---

## Structure du projet

```
lib/
├── main.dart
├── app/
│   ├── router.dart              # go_router — toutes les routes
│   └── theme.dart               # Material 3 theme
├── core/
│   ├── config_service.dart      # configuration persistante (SharedPreferences + .env)
│   └── maturity/
│       └── maturity_service.dart  # calcul maturité (tropJeune/optimal/aBoireUrgent)
├── data/
│   ├── database.dart            # drift DB, définition des tables
│   ├── database.g.dart          # code généré drift
│   ├── providers.dart           # Riverpod providers (DB, DAO)
│   ├── daos/
│   │   └── bouteille_dao.dart   # requêtes CRUD + filtres + listes distinctes
│   └── tables/
│       └── bouteilles.dart      # définition table drift
├── features/
│   ├── bottle_actions/          # BottomSheet actions bouteille (Déplacer, Consommer)
│   │   ├── bottle_actions_sheet.dart
│   │   └── widgets/
│   │       ├── deplacer_form.dart
│   │       └── consommer_form.dart
│   ├── bulk_add/                # formulaire ajout en lot
│   │   ├── bulk_add_screen.dart
│   │   ├── bulk_add_controller.dart
│   │   └── widgets/
│   │       └── repartition_row.dart
│   ├── import_csv/              # parsing et import CSV
│   │   ├── import_csv_screen.dart
│   │   ├── import_service.dart
│   │   └── csv_parser.dart
│   ├── setup/                   # wizard premier lancement
│   │   ├── setup_screen.dart
│   │   └── setup_controller.dart
│   └── stock/                   # liste stock + filtres + maturité
│       ├── stock_screen.dart
│       ├── stock_controller.dart
│       ├── stock_table.dart     # table triable desktop (≥ 640px)
│       └── bouteille_list_tile.dart
└── shared/
    └── adaptive_layout.dart     # bascule desktop/mobile (600px)
```

---

## Responsive layout

Un seul widget shell qui adapte la navigation selon la largeur d'écran :

```dart
// Seuil : 600px (convention Flutter Material)
// < 600px  → BottomNavigationBar  (mobile)
// ≥ 600px  → NavigationRail       (desktop/tablette)
```

Les vues elles-mêmes sont les mêmes — seule la navigation change. Certaines actions (import CSV, ajout en lot, statistiques avancées) peuvent être masquées sur mobile jusqu'au mode 3.

---

## Vue "Que boire ?" — logique de calcul

```
année_actuelle = DateTime.now().year

trop_jeune  : millesime + garde_min > année_actuelle  → bleu
optimal     : millesime + garde_min ≤ année_actuelle
              ET millesime + garde_max ≥ année_actuelle  → vert
à_boire     : millesime + garde_max < année_actuelle  → rouge
```

---

## Configuration et premier lancement

### Stratégie à deux niveaux

L'app détecte à chaque démarrage si une configuration valide existe. Deux sources sont consultées, dans l'ordre :

1. **Fichier `.env`** (Windows uniquement) — cherché à côté de l'exécutable. Réservé aux utilisateurs avancés qui veulent pré-configurer avant le premier lancement.
2. **SharedPreferences** — stockage persistant géré par l'app, invisible pour l'utilisateur (AppData sur Windows, données privées sur Android).

Si aucune configuration valide n'est trouvée → **wizard de premier lancement**.

### Wizard de premier lancement

```
Étape 1 : choix du mode
  Mode 1 — PC seul (local)       → disponible
  Mode 2 — PC + Android (cloud)  → "Non disponible dans cette version"
  Mode 3 — Mobile seul           → "Non disponible dans cette version"

Étape 2 (Mode 1) : chemin vers le répertoire contenant cave.db
  → champ texte + bouton "Parcourir" (file picker dossier)
  → valeur par défaut : Documents/cave

Étape 3 : confirmation
  → créer cave.db si inexistant
  → persister la config dans SharedPreferences
  → proposer l'import CSV (ou "Commencer avec une base vide")
```

Android ne lit pas `.env`. Le wizard est le seul chemin de configuration sur mobile.

### Format du fichier `.env` (Windows avancé)

Voir `.env.example` à la racine du projet. Variables utilisées en Mode 1 : `STORAGE_MODE=local`, `LOCAL_DB_PATH`.

---

## Import CSV

### Accès au fichier

L'utilisateur choisit son fichier via un **file picker** (aucun chemin codé en dur). Format attendu : CSV UTF-8, séparateur `;`, colonnes identiques à `cave_clean.csv`.

### Comportement par ligne

| Cas | Action |
|---|---|
| Colonne `id` vide | Générer un UUID v4, insérer |
| `id` présent, absent de la base | Insérer avec cet UUID |
| `id` présent, déjà en base, case "écraser" cochée | UPDATE |
| `id` présent, déjà en base, case "écraser" non cochée | SKIP |

### Rapport d'import

Afficher à la fin : X insérées · Y mises à jour · Z ignorées.

---

## Ordre de développement (MVP)

1. ✅ Configuration initiale + wizard + drift model + import CSV
2. ✅ Vue stock + filtres (couleur multi-sélect, appellation, millésime, recherche texte, table desktop triable)
3. ✅ Maturité intégrée dans la vue stock — colonne GARDE colorée, FilterChips maturité, tri urgence (pas d'écran séparé "à boire")
4. ✅ Actions bouteille — BottomSheet avec Déplacer (autocomplétion emplacement), Consommer (date + note + commentaire), stub Modifier
5. ✅ Ajout en lot — formulaire multi-champs, répartition dynamique, autocomplétion domaine/appellation/cru/contenance/fournisseur, validation garde
6. ~~Changement d'emplacement~~ → fusionné dans étape 4 (BottomSheet)
7. Mécanisme sync (lock / download / upload)
8. Settings (chemin dossier partagé, mode)

---

## Points ouverts

| # | Sujet | Impact |
|---|---|---|
| 1 | Accès Google Drive / Dropbox depuis Android (mode mobile seul) | Bloque le mode 3 uniquement — pas le MVP |
| 2 | Format d'export CSV (même format que l'import, ou autre ?) | V1 |
| 3 | Stratégie de conflit si `cave.db` modifié sur deux appareils sans lock (erreur humaine) | V1 — pour l'instant : dernier upload écrase tout |
