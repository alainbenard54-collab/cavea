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
├── data/
│   ├── database.dart            # drift DB, définition des tables
│   ├── daos/
│   │   └── bouteille_dao.dart   # requêtes CRUD + filtres
│   └── sync/
│       ├── sync_service.dart    # orchestration download/upload
│       └── lock_manager.dart    # gestion cave.lock
├── domain/
│   └── bouteille.dart           # modèle métier (calcul maturité, etc.)
├── features/
│   ├── stock/                   # liste + filtres
│   ├── a_boire/                 # vue "que boire" avec indicateurs couleur
│   ├── ajout/                   # formulaire unitaire + ajout en lot
│   ├── mouvements/              # changement d'emplacement
│   ├── historique/              # bouteilles consommées (V1)
│   ├── import_csv/              # parsing cave_clean.csv
│   └── settings/                # choix mode, chemin dossier partagé
└── shared/
    ├── widgets/                 # composants réutilisables
    └── adaptive_layout.dart     # bascule desktop/mobile
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

## Ordre de développement (MVP)

1. Modèle drift + import `cave_clean.csv`
2. Vue stock + filtres (couleur, appellation, millésime, recherche texte)
3. Vue "à boire"
4. Action "consommer" (renseigne `date_sortie`)
5. Ajout en lot
6. Changement d'emplacement
7. Mécanisme sync (lock / download / upload)
8. Settings (chemin dossier partagé, mode)

---

## Points ouverts

| # | Sujet | Impact |
|---|---|---|
| 1 | Accès Google Drive / Dropbox depuis Android (mode mobile seul) | Bloque le mode 3 uniquement — pas le MVP |
| 2 | Format d'export CSV (même format que l'import, ou autre ?) | V1 |
| 3 | Stratégie de conflit si `cave.db` modifié sur deux appareils sans lock (erreur humaine) | V1 — pour l'instant : dernier upload écrase tout |
