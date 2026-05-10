# ARCHITECTURE.md

Décisions techniques retenues pour l'application de gestion de cave à vin.

---

## Plateformes cibles

| Plateforme | Statut |
|---|---|
| Windows | Cible principale (desktop) — MVP ✅ |
| Android | Cible mobile — MVP ✅ |
| Linux | V1 — effort modéré (Mode 1 sans changement, Mode 2 via OAuth desktop, packaging AppImage/.deb) |
| macOS | Non prioritaire |
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
├── main.dart                    # AppWrapper (WidgetsBindingObserver, cycle de vie sync)
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
│   ├── bottle_actions/          # BottomSheet actions bouteille (Déplacer, Consommer, Modifier)
│   │   ├── bottle_actions_sheet.dart
│   │   └── widgets/
│   │       ├── deplacer_form.dart
│   │       └── consommer_form.dart
│   ├── bottle_detail/           # Fiche lecture seule d'une bouteille (V1)
│   │   └── bottle_detail_screen.dart
│   ├── bottle_edit/             # Écran d'édition complète d'une bouteille (V1)
│   │   └── bottle_edit_screen.dart
│   ├── bulk_add/                # formulaire ajout en lot
│   │   ├── bulk_add_screen.dart
│   │   ├── bulk_add_controller.dart
│   │   └── widgets/
│   │       └── repartition_row.dart
│   ├── locations/               # Navigation par emplacement — arbre hiérarchique (V1)
│   │   ├── location_tree_screen.dart  # écran unique avec nav interne (pas de Navigator.push)
│   │   ├── location_node.dart         # LocationNode, buildTree(), nodeStats()
│   │   ├── location_node_tile.dart    # LocationNodeTile + locationStatsLabel()
│   │   └── location_provider.dart     # locationLeavesProvider, locationBottleListProvider
│   ├── import_csv/              # parsing et import CSV
│   │   ├── import_csv_screen.dart
│   │   ├── import_service.dart
│   │   └── csv_parser.dart
│   ├── settings/                # paramètres : mode sync, à propos (step 8 partiel)
│   │   └── settings_screen.dart
│   ├── setup/                   # wizard premier lancement
│   │   ├── setup_screen.dart
│   │   └── setup_controller.dart
│   └── stock/                   # liste stock + filtres + maturité + multi-sélection
│       ├── stock_screen.dart
│       ├── stock_controller.dart
│       ├── stock_table.dart         # table triable desktop (≥ 640px)
│       ├── bouteille_list_tile.dart
│       ├── selection_controller.dart  # SelectionState + SelectionController (autoDispose)
│       └── widgets/
│           ├── bulk_action_bar.dart      # barre contextuelle mode sélection
│           ├── deplacer_batch_sheet.dart # BottomSheet Déplacer en lot
│           └── consommer_batch_sheet.dart # BottomSheet Consommer en lot
├── services/                    # couche cloud / sync (Mode 2)
│   ├── storage_adapter.dart     # interface abstraite StorageAdapter
│   ├── drive_storage_adapter.dart  # impl. Google Drive (drive.file scope, dossier Cavea)
│   └── sync_service.dart        # états SyncState, syncOnStartup(), releaseIfNeeded()
├── shared/
│   └── adaptive_layout.dart     # bascule desktop/mobile (600px), AppBar indicateurs
└── widgets/
    └── sync_status_indicator.dart  # icônes mode + verrou dans AppBar (Mode 2 uniquement)
```

---

## Responsive layout

Un seul widget shell qui adapte la navigation selon la plateforme et la largeur :

```dart
// Android (toujours)   → _MobileBar (barre en bas, 3 zones)
// Windows ≥ 600px      → _DesktopRail (NavigationRail côté gauche)
// Windows < 600px      → _MobileBar
final useRail = isDesktop(context) && !Platform.isAndroid;
```

**Android utilise toujours `_MobileBar`**, quel que soit l'orientation. En paysage Android la largeur dépasse 600 dp, mais `NavigationRail` ne tient pas en hauteur avec le clavier ouvert. La détection par `Platform.isAndroid` est donc préférable à la détection par largeur seule.

Les vues elles-mêmes sont les mêmes — seule la navigation change.

**Destinations** (index 0→4) : Stock, Ajouter, Emplacements, Import CSV, Paramètres. `_writeOnlyIndices = {1, 3}` (Ajouter et Import CSV grisés en SyncReadOnly). Emplacements (index 2) est toujours accessible.

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
7. ✅ Mécanisme sync (lock / download / upload)
8. ✅ Settings (chemin dossier partagé, mode)

---

## Configuration — ConfigService

`lib/core/config_service.dart` — singleton global initialisé dans `main()` avant `runApp()`.

Données persistées dans SharedPreferences :

| Clé | Type | Usage |
|---|---|---|
| `storage_mode` | String | `'local'` ou `'drive'` |
| `db_path` | String | Chemin absolu vers cave.db |
| `couleur_defaut` | String | Valeur pré-sélectionnée dans bulk-add |
| `contenance_defaut` | String | Valeur pré-remplie dans bulk-add |
| `ref_couleurs` | List\<String\> | Liste de référence couleurs (builtin si absent) |
| `ref_contenances` | List\<String\> | Liste de référence contenances (builtin si absent) |
| `ref_crus` | List\<String\> | Liste de référence crus (builtin si absent) |

Les listes de référence ont des valeurs builtin par défaut (`ConfigService.builtinCouleurs` etc.) qui s'appliquent si l'utilisateur n'a pas personnalisé la liste. Dans les formulaires d'ajout, la liste affichée = union(liste de référence, valeurs existantes en base).

---

## Internationalisation (V1)

Approche retenue : **`flutter_localizations` + `intl` + fichiers ARB** (standard Flutter officiel).

```
lib/l10n/
├── app_fr.arb   # français (langue par défaut)
└── app_en.arb   # anglais
```

- Génération automatique via `flutter gen-l10n` → `AppLocalizations` accessible dans tous les widgets
- Ajout d'une langue par un contributeur externe = créer `app_XX.arb` + PR
- Sélection de langue : détection automatique du système + sélection manuelle dans les paramètres (persistée dans SharedPreferences)

---

## Multi-sélection de bouteilles (V1 ✅)

Sélection multiple depuis la vue stock via appui long → cases à cocher apparaissent. Barre d'actions contextuelle (`BulkActionBar`) fixée en bas d'écran.

**État** : `SelectionController extends StateNotifier<SelectionState>` (`.autoDispose`) dans `lib/features/stock/selection_controller.dart`. `SelectionState` = `{bool isSelectMode, Set<String> selectedIds}`.

**Entrée/sortie :**
- Appui long sur une ligne → `enterSelectMode(id)` : isSelectMode=true, ligne cochée
- Tap en mode sélection → `toggleId(id)` : bascule coche
- Annuler ou après action → `reset()` : isSelectMode=false, Set vidé
- Navigation hors stock → autoDispose réinitialise automatiquement

**SyncReadOnly** : appui long désactivé (`onLongPress: null`) — Déplacer et Consommer étant bloqués en lecture seule, autoriser le mode sélection créerait une impasse UX.

**Actions batch** — transactions drift atomiques (`BouteilleDao`) :
- **Déplacer** : `DeplacerBatchSheet` → `deplacerBouteilles(List<String> ids, String emplacement)`
- **Consommer** : `ConsommerBatchSheet` → `consommerBouteilles(List<String> ids, {dateSortie, noteDegus, commentaireDegus})`

Les BottomSheets batch utilisent `UncontrolledProviderScope(container: ProviderScope.containerOf(context))` pour accéder aux providers Riverpod depuis le contexte modal.

Fichiers : `selection_controller.dart`, `widgets/bulk_action_bar.dart`, `widgets/deplacer_batch_sheet.dart`, `widgets/consommer_batch_sheet.dart`.

---

## Navigation par emplacement (V1 ✅)

Onglet dédié (`Icons.shelves`, index 2) donnant accès à l'arbre hiérarchique des emplacements.

**Architecture — widget unique** : `LocationTreeScreen` (ConsumerStatefulWidget) gère toute la navigation en interne via `List<String> _path` + deux booléens (`_showingBottleList`, `_directOnly`). Aucun `Navigator.push` — la NavigationRail/BottomBar reste donc toujours visible.

**Données** : `watchLocationStats()` dans `BouteilleDao` — `SELECT emplacement, COUNT(*), SUM(prix_achat), SUM(CASE WHEN prix_achat IS NULL…)` groupé par emplacement. Retourne `Stream<List<LocationLeaf>>`. `buildTree(List<LocationLeaf>)` divise sur ` > ` et construit récursivement l'arbre trié alphabétiquement.

**`LocationNode`** : `{label, fullPath, children, directCount, directSumPrix, directNullPrixCount}`. `nodeStats(node, true)` agrège récursivement count + sumPrix + nullPrixCount des enfants.

**Fraîcheur des données** : `_findCurrentNode(tree, _path)` parcourt l'arbre reconstruit depuis le stream drift à chaque rebuild. Après un Déplacer ou Consommer, les stats se mettent à jour instantanément.

**Fil d'ariane** : "Emplacements" toujours visible en racine, segments intermédiaires cliquables (`_navigateToLevel(i)` ou `_navigateToRoot()`), dernier segment non-cliquable.

**Liste bouteilles** : `locationBottleListProvider(emplacement)` — match exact sur `emplacement`. Badge maturité compact en trailing (pas l'emplacement, redondant avec le fil d'ariane). Multi-sélection et actions BottomSheet identiques à la vue Stock.

Fichiers : `lib/features/locations/` (4 fichiers). DAO : `watchLocationStats()`, `watchBouteillesParEmplacement()`.

---

## Quitter Android en mode écriture (V1)

Sur Android en Mode 2 (partagé), l'OS tue le process quelques ms après `AppLifecycleState.paused`, avant la fin des requêtes HTTP. La libération du lock à la fermeture est donc non fiable (voir section "Android — libération du lock à la fermeture" dans CLAUDE.md).

**Feature V1** : quand `_MobileBar` affiche le bouton "Sauvegarder et libérer" (`!isReadOnly && isAndroid && syncService.isActive`), afficher également un bouton **Quitter** (icône `exit_to_app`) qui :
1. Déclenche `syncService.releaseManual()` (upload Drive + suppression lock)
2. Attend la fin de l'opération (état `SyncIdle` ou `SyncReadOnly`)
3. Appelle `exit(0)` pour fermer le process proprement

Ce bouton remplace le pattern "ferme l'app → session interrompue → récupération au prochain démarrage" par une sortie propre explicite. Il ne s'affiche qu'en mode écriture actif (pas en lecture seule, pas en Mode 1).

Emplacement dans `_MobileBar` : dans la zone sync (gauche), aux côtés de `_AbandonWriteIconBtn` et `_SaveReleaseIconBtn`.

---

## Points ouverts

| # | Sujet | Impact |
|---|---|---|
| 1 | ~~Accès Google Drive depuis Android~~ | ✅ Résolu — Mode 2 Android opérationnel (android-lock-ux) |
| 2 | Support Dropbox | V1 — StorageAdapter déjà abstrait, ajouter DropboxStorageAdapter + sélecteur fournisseur dans Settings |
| 3 | Format d'export CSV (même format que l'import, ou autre ?) | V1 |
| 4 | Stratégie de conflit si `cave.db` modifié sur deux appareils sans lock (erreur humaine) | V1 — pour l'instant : dernier upload écrase tout |
| 5 | Mise à jour Flutter vers version stable courante | V1 — vérifier compatibilité dépendances avant migration |
| 6 | Support Linux — packaging AppImage/.deb | V1 |
