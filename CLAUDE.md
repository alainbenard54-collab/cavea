# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project purpose

Flutter application for personal wine cellar management. Single codebase compiled for Windows desktop (primary) and Android (mobile). No backend server, no cloud hosting — data lives in a local SQLite file (`cave.db`), optionally shared via a cloud storage API.

Full specifications are in `PRD.md` (features and priorities) and `ARCHITECTURE.md` (technical decisions). Read those files before proposing any significant change.

---

## Tech stack

| Layer | Choice | Notes |
|---|---|---|
| Framework | Flutter 3 (Dart) | Single codebase for desktop + mobile |
| Database | drift (SQLite) | Type-safe ORM, declarative migrations, reactive streams |
| State management | Riverpod | Integrates naturally with drift streams |
| Navigation | go_router | Declarative, handles desktop and mobile routes |
| UI | Material 3 | NavigationRail (desktop) / BottomNavigationBar (mobile), threshold 600px. Stock table shown when content area ≥ 640px (measured via LayoutBuilder, excludes NavigationRail width). |

Do not introduce alternative state management (Provider, BLoC, GetX) or navigation solutions without an explicit decision.

---

## Deployment modes — critical for storage decisions

### Mode 1 — Windows only (full local)
- `dart:io` direct access to `cave.db` on the local filesystem
- No StorageAdapter, no sync, no lock — single copy, always open directly
- No cloud dependency, no credentials required

### Mode 2 — Shared (any device combination)
- **Any combination** of devices sharing the same `cave.db` via cloud API: Windows+Windows, Android+Android, or Windows+Android
- Sync is semi-automatic: download + lock auto au démarrage, upload + unlock auto à la fermeture. Sync manuelle disponible en cours de session via bouton.
- `StorageAdapter` interface abstracts the cloud backend (Google Drive MVP, Dropbox V1)
- Requires OAuth credentials setup on every participating device (GCP project + per-platform credentials)
- The defining characteristic is **sharing across devices**, not the specific device types

### Mode 3 — Android only (full local, future)
- `dart:io` / SQLite direct access to `cave.db` stored in the app's local storage on Android
- No StorageAdapter, no sync, no lock — mirrors Mode 1 but on Android
- No cloud dependency, no credentials required
- Out of MVP scope

---

## Storage rules — enforce strictly

- Mode 2 **must** access shared storage via cloud API only — never via `dart:io` on a locally synced folder. This would break Android.
- Mode 1 and Mode 3 use direct local storage only — never involve StorageAdapter or SyncService.
- `StorageAdapter` is the contract between `SyncService` and the cloud backend. Do not bypass this abstraction.
- `DriveStorageAdapter` and `DropboxStorageAdapter` are the concrete implementations — they encapsulate OAuth and API calls. `SyncService` must not know which backend is used.

---

## Data model

Single table `bouteilles`. One row = one physical bottle.

Key fields: `id` (UUID), `domaine`, `appellation`, `millesime`, `couleur`, `cru`, `contenance`, `emplacement`, `date_entree`, `date_sortie`, `prix_achat`, `garde_min`, `garde_max`, `commentaire_entree`, `note_degus`, `commentaire_degus`, `fournisseur_nom`, `fournisseur_infos`, `producteur`, `updated_at`.

**Business rules:**
- `date_sortie` empty → bottle in stock
- `date_sortie` set → bottle consumed / removed
- Moving a bottle = update `emplacement` — it is **not** a removal
- `emplacement` is a validated hierarchy: `Niveau1` or `Niveau1 > Niveau2 > Niveau3`. Each level: letters (including accented), digits, internal spaces; must start with alphanumeric. Separator: ` > ` (space-chevron-space). Validated on input in the Déplacer form.
- Maturity computed at runtime: `millesime + garde_min/max` vs `DateTime.now().year`
- Maturity levels: `tropJeune` (blue) / `optimal` (green) / `aBoireUrgent` (red) / `sansDonnee` (grey)
- Within each maturity level, urgency sort = `age - gardeMax` descending (higher = more overdue)

**Field protection rules — critical for edit forms:**

These fields must **never** be exposed in a generic edit form. They are only writable via dedicated actions:

| Field | Protected via |
|---|---|
| `id` | Never editable (primary key) |
| `updated_at` | Auto-managed by app |
| `date_sortie` | Only via "Consommer" action |
| `note_degus` | Only via "Consommer" action |
| `commentaire_degus` | Only via "Consommer" action |

All other fields are editable in the full bottle edit form (V1 feature, not MVP).

---

## MVP development order

1. ✅ drift model + `cave_clean.csv` import
2. ✅ Stock view + filters (couleur multi-sélect, appellation, millésime, recherche texte, layout adaptatif, table desktop triable)
3. ✅ Maturity integrated into stock view (colonne GARDE colorée + delta, FilterChips maturité multi-sélect, tri urgence secondaire — **pas d'écran séparé "Quoi boire ?"**)
4. ✅ `bottle-actions`: BottomSheet d'actions rapides sur clic bouteille (Déplacer + Consommer + accès fiche complète)
5. ✅ Bulk add (formulaire → N bouteilles identiques, répartition multi-emplacement)
6. ~~Change location~~ → fusionnée dans `bottle-actions` (étape 4)
7. ✅ Sync mechanism (lock / download / upload) — Mode 2 Google Drive : syncOnStartup, crash recovery, lock tiers lecture seule, releaseIfNeeded à la fermeture, indicateurs AppBar, bascule Mode 1→2 dans Settings
8. ✅ Settings — implémenté et testé (T-7.1→T-7.9 OK) : chemin cave.db (Mode 1, file picker), couleur/contenance par défaut, listes de référence couleurs/contenances/crus éditables, listes fusionnées avec valeurs DB dans bulk-add

Do not implement V1 or V2 features before the MVP is complete.

---

## bottle-actions — spec décidée (étape 4 MVP)

Clic sur une ligne du stock → `BottomSheet` modal avec :

1. **Consommer** : date de consommation (défaut = aujourd'hui, modifiable via DatePicker pour déclaration tardive), note /10 optionnelle, commentaire de dégustation optionnel → `UPDATE date_sortie + note_degus + commentaire_degus`
2. **Consulter la fiche** : navigue vers `BottleDetailScreen` (lecture seule) via la route `/bottle/:id` — accessible en mode normal ET en mode lecture seule. Champs `note_degus` / `commentaire_degus` masqués si la bouteille est encore en stock (`date_sortie` vide).
3. **Déplacer** : saisie libre de l'emplacement avec autocomplétion sur les emplacements existants en base → `UPDATE emplacement` uniquement, pas de `date_sortie`
4. **Modifier la fiche** : navigue vers `BottleEditScreen` via la route `/bottle-edit/:id` — implémenté en V1. Champs protégés exclus (voir ci-dessus).
5. **Annuler** : ferme le BottomSheet

**Mode lecture seule** : quand `SyncReadOnly` est actif (lock détenu par un autre appareil), le BottomSheet affiche un message "Mode lecture seule — modifications indisponibles", l'action **Consulter la fiche** (accessible) et un bouton **Fermer**. Les actions Consommer, Déplacer, Modifier la fiche sont cachées.

---

## bulk-add — spec finale (étape 5 MVP ✅)

Formulaire d'ajout en lot : champs communs + quantité totale + section "Répartition" avec groupes dynamiques.

**Champs communs (tous non-protégés)** : `domaine`, `appellation`, `millesime`, `couleur`, `cru`, `contenance` (défaut "75 cl"), `prix_achat`, `garde_min`, `garde_max`, `commentaire_entree`, `fournisseur_nom`, `fournisseur_infos`, `producteur`, `date_entree` (défaut = aujourd'hui).

**Répartition** : liste de groupes `(quantité, emplacement)` avec autocomplétion emplacement. Contrainte : somme des quantités == quantité totale déclarée. Si un seul emplacement = une seule ligne. L'app crée N lignes indépendantes en base (1 ligne = 1 bouteille physique, UUID distinct par ligne).

**Autocomplétion champs texte** : domaine, appellation, cru, contenance, fournisseur_nom proposent les valeurs existantes en base (toutes bouteilles — stock ET consommées) via recherche plein texte contient. Les emplacements de répartition suivent le même principe.

**Validation garde** :
- Si `garde_min` et `garde_max` sont tous les deux renseignés : `garde_min ≤ garde_max` obligatoire (snackbar d'erreur sinon, insertion bloquée).
- Si l'un ou l'autre est vide : dialogue de confirmation avertit que la maturité ne pourra pas être calculée. L'utilisateur choisit "Confirmer sans garde" ou "Retour".

**Champs protégés exclus** : `id`, `updated_at`, `date_sortie`, `note_degus`, `commentaire_degus`.

---

## multi-sélection — spec implémentée (V1 ✅)

Appui long sur une ligne de la vue stock → **mode sélection**.

- Appui long désactivé quand `SyncReadOnly` (les deux actions disponibles — Déplacer, Consommer — sont bloquées en lecture seule, inutile d'entrer dans le mode)
- En mode sélection : tap bascule la coche, leading devient `Checkbox`, fond coloré sur les lignes sélectionnées
- `StockTable` (desktop ≥ 640px) : colonne checkbox en première position
- `BulkActionBar` (barre fixée en bas du Column) : compteur "N bouteille(s) sélectionnée(s)", boutons **Déplacer** / **Consommer** / ✕ Annuler
- **Déplacer** → `DeplacerBatchSheet` (emplacement + autocomplétion → `deplacerBouteilles` en transaction)
- **Consommer** → `ConsommerBatchSheet` (date + note + commentaire → `consommerBouteilles` en transaction)
- Annuler ou après action → `selectionProvider.reset()`, retour au mode normal
- `selectionProvider` est `.autoDispose` → sélection vidée automatiquement à la navigation

Fichiers : `lib/features/stock/selection_controller.dart`, `lib/features/stock/widgets/bulk_action_bar.dart`, `lib/features/stock/widgets/deplacer_batch_sheet.dart`, `lib/features/stock/widgets/consommer_batch_sheet.dart`.

---

## navigation-emplacement — spec implémentée (V1 ✅)

Onglet "Emplacements" (`Icons.shelves`, index 2) ajouté à `_DesktopRail` (Windows) et `_MobileBar` (Android). `_writeOnlyIndices = {1, 3}` (Ajouter=1, Import CSV=3 — Emplacements=2 toujours accessible même en SyncReadOnly).

**Architecture** : `LocationTreeScreen` est un seul `ConsumerStatefulWidget` qui gère toute la navigation en interne (pas de `Navigator.push`). La NavigationRail/BottomBar reste donc toujours visible à tous les niveaux de l'arbre.

**État interne** : `List<String> _path` (labels du chemin depuis la racine), `bool _showingBottleList`, `bool _directOnly`. `_findCurrentNode(tree, _path)` reconstruit le nœud courant à chaque rebuild depuis le stream drift → données toujours fraîches après Déplacer/Consommer.

**Fil d'ariane cliquable** : AppBar title = `_buildBreadcrumb()` — "Emplacements" toujours présent en racine, segments intermédiaires cliquables (sautent directement à ce niveau), dernier segment non-cliquable (niveau courant).

**Statistiques** : agrégation Dart récursive depuis `buildTree(List<LocationLeaf>)` — toujours inclut les sous-emplacements. Format : `"N bouteille(s) (NN €)"` ou `"N bouteille(s) (NN €) dont K sans prix"` quand la somme est partielle.

**Mix nœuds + bouteilles directes** : si un nœud parent contient à la fois des sous-emplacements ET des bouteilles rattachées directement, les deux sont affichés — sous-nœuds d'abord, puis tuile "Directement dans cet emplacement".

**Liste de bouteilles** (`_BottleListBody`) : trailing = badge maturité compact ("Optimal" vert / "Trop jeune" bleu / "À boire !" rouge) — l'emplacement n'est pas affiché (redondant avec le fil d'ariane). Multi-sélection (Déplacer/Consommer en lot) et BottomSheet d'actions, désactivés en SyncReadOnly.

**Back Android** : `PopScope(canPop: !_canGoBack)` intercepte le bouton back système pour naviguer dans l'arbre avant de remonter à la navigation principale.

Fichiers : `lib/features/locations/location_tree_screen.dart`, `location_node.dart`, `location_node_tile.dart`, `location_provider.dart`. DAO : `watchLocationStats()` + `watchBouteillesParEmplacement()` dans `bouteille_dao.dart`.

---

## Mode lecture seule — règles UI (Mode 2)

Quand `SyncService` est en état `SyncReadOnly` (lock Drive détenu par un autre appareil) :

| Élément | Comportement |
|---|---|
| Navigation "Ajouter" | Grisée — tap bloqué avec snackbar "Indisponible en mode lecture seule" |
| Navigation "Import CSV" | Grisée — tap bloqué avec snackbar |
| BottomSheet bouteille | Affiche uniquement "Mode lecture seule" + bouton Fermer |
| Bouton "Synchroniser" | Caché (déjà absent quand `!isWriteMode`) |
| Multi-sélection (appui long) | Désactivé — `onLongPress: null` passé aux widgets |
| Onglet Stock | Entièrement accessible en lecture |
| Onglet Paramètres | Accessible (peut changer de mode) |

---

## Android — barre de navigation

Sur Android, l'app utilise **toujours** `_MobileBar` (barre en bas), quel que soit l'orientation. `_DesktopRail` (NavigationRail) est strictement réservé à Windows. Règle dans `adaptive_layout.dart` : `final useRail = isDesktop(context) && !Platform.isAndroid;`. **Ne pas revenir à la détection par largeur seule** : en paysage un téléphone Android dépasse 600 dp, ce qui déclencherait `_DesktopRail` par erreur.

`_MobileBar` est organisée en 3 zones : gauche (icônes sync contextuelles Mode 2), centre (Stock + Ajouter), droite (Import + Paramètres). Les icônes Ajouter et Import affichent un badge cadenas orange 11px quand `SyncReadOnly` ; le tap déclenche toujours la snackbar "Indisponible".

## Android — layout landscape

En orientation paysage sur mobile, les filtres (couleur, maturité, appellation, millésime) sont collapsibles via un toggle "Filtres / Filtres actifs" affiché sous la SearchBar. La SearchBar reste toujours visible.

Détection dans `stock_screen.dart` : `Platform.isAndroid && MediaQuery.of(context).orientation == Orientation.landscape`. **Ne pas utiliser `!isDesktop(context)`** : en paysage un téléphone Android a une largeur ≥ 600 dp, ce qui fait retourner `true` à `isDesktop()` et empêche la détection.

## Android — libération du lock à la fermeture

L'OS Android tue le process quelques ms après `AppLifecycleState.paused`, avant que les requêtes HTTP (upload + delete lock) aient le temps de terminer. Le lock reste donc toujours présent sur Drive après une fermeture Android.

Comportement retenu : au prochain démarrage, si le lock appartient à notre appareil, on résout silencieusement (upload local → lock conservé) sans dialog "Session interrompue". Le dialog crash recovery reste affiché uniquement sur PC (Windows), où la fermeture est interceptée via `didRequestAppExit()` et les requêtes ont le temps de terminer.

---

## settings — implémenté (étape 8 MVP)

Écran de configuration accessible depuis la navigation principale. Sections dans l'ordre d'affichage :

**1. Emplacement de la cave (Mode 1 uniquement)**
- Affiche le dossier courant contenant `cave.db`
- Bouton "Modifier" → `FilePicker.platform.getDirectoryPath()` → sauvegarde dans ConfigService → snackbar "redémarrez l'application"

**2. Ajout en lot — valeurs par défaut**
- `couleur_defaut` : dropdown depuis `ConfigService.refCouleurs` — pré-sélectionné dans le formulaire si la valeur est présente dans la liste
- `contenance_defaut` : champ texte — pré-rempli dans le formulaire
- Persistés dans SharedPreferences via `ConfigService.saveBulkAddDefaults()`

**3. Listes de référence**
- Trois listes éditables (chips supprimables + champ "Ajouter") : **Couleurs**, **Contenances**, **Crus**
- Valeurs builtin par défaut (si jamais modifiées par l'utilisateur) :
  - Couleurs : Blanc, Blanc effervescent, Blanc liquoreux, Blanc moelleux, Rosé, Rosé effervescent, Rouge
  - Contenances : 37,5 cl, 50 cl, 75 cl, 1,5 L (magnum)
  - Crus : 1ER CRU, CRU BOURGEOIS, CRU CLASSE, GRAND CRU, GRAND CRU CLASSE, SECOND VIN
- Dans le formulaire bulk-add : liste affichée = union(liste de référence, valeurs existantes en base). Les valeurs de référence apparaissent en tête de liste.

**4. Mode de synchronisation**
- Activation/désactivation Google Drive (code existant préservé)
- Support Dropbox prévu en V1 — sélecteur de fournisseur à ajouter quand DropboxStorageAdapter sera implémenté

**5. À propos**
- Version, licence, lien vers les licences des dépendances

---

## V1 features (post-MVP — do not implement before MVP complete)

- ✅ **Édition complète d'une bouteille** : formulaire avec tous les champs non protégés modifiables. Accessible depuis le BottomSheet "Modifier la fiche" via `/bottle-edit/:id`. DropdownMenu filtrable pour couleur/cru/contenance, DatePicker pour date_entree, autocomplétion RawAutocomplete, bouton restore ↩.
- ✅ **Fiche lecture seule** d'une bouteille : `BottleDetailScreen` via route `/bottle/:id`, même présentation que `BottleEditScreen` (OutlineInputBorder, IgnorePointer), badge maturité coloré, section Consommation masquée si bouteille en stock. Accessible depuis le BottomSheet ("Consulter la fiche") en mode normal ET SyncReadOnly. Fix associé : `garde_min=0` désormais valeur légitime (buvable dès le millésime).
- ✅ **Multi-sélection de bouteilles** : appui long → mode sélection → barre d'actions contextuelle → **Déplacer** (même emplacement pour toutes) ou **Consommer** (même date/note/commentaire pour toutes). Désactivé en SyncReadOnly (appui long ignoré). Voir section ci-dessous et ARCHITECTURE.md "Multi-sélection".
- ✅ **Bouton quitter Android (Mode 2, mode écriture)** : quand `_MobileBar` est en mode écriture, bouton "Quitter" qui déclenche `releaseManual()` puis `exit(0)`. Dialogue de confirmation avec option "Sauvegarder et quitter" / "Annuler". Voir ARCHITECTURE.md section "Quitter Android en mode écriture".
- ✅ **Navigation par emplacement** : onglet "Emplacements" (`Icons.shelves`, index 2) dans `_DesktopRail` et `_MobileBar`. Voir ARCHITECTURE.md section "Navigation par emplacement".
- **Internationalisation (i18n)** : `flutter_localizations` + fichiers ARB (`lib/l10n/app_fr.arb`, `lib/l10n/app_en.arb`). Détection automatique langue système + sélection manuelle dans paramètres. Voir ARCHITECTURE.md section "Internationalisation".
- ✅ **Historique des consommations** : liste bouteilles consommées, tri par date, recherche texte, BottomSheet détail + Réhabiliter, badge maturité masqué sur bouteilles consommées
- **Export CSV** : même format que l'import
- **Support Dropbox** : `DropboxStorageAdapter` + sélecteur fournisseur dans Settings
- **Support Linux** : Mode 1 sans changement majeur, Mode 2 via OAuth desktop, packaging AppImage/.deb
- **Mise à jour Flutter** vers la version stable courante au démarrage V1

---

## Out of scope (do not implement)

- Multi-user or concurrent access management
- Backend server or remote database
- Relational normalisation of domains / appellations
- Visual cave map, drag & drop
- Advanced oenology fields (robe, nose, palate)
- Complex ML / AI features
- iOS (Apple Developer cost)
