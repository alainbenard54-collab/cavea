## Context

La vue stock (`lib/features/stock/stock_screen.dart`) gère aujourd'hui un seul état de filtres via `StockFilterController` (StateNotifier). Le tap sur une ligne (`BouteilleListTile`) déclenche directement `showBottleActionsSheet`. Il n'existe aucun concept de sélection multiple ni d'état persistant de sélection.

Le DAO (`lib/data/daos/bouteille_dao.dart`) expose des méthodes unitaires `deplacerBouteille(id, emplacement)` et `consommerBouteille(id, ...)`. Les widgets de formulaire (`consommer_form.dart`, `deplacer_form.dart`) sont réutilisables tels quels pour les actions en lot.

## Goals / Non-Goals

**Goals:**
- Ajouter un état de sélection (mode sélection + Set d'IDs sélectionnés) géré par un StateNotifier dédié
- Déclencher le mode sélection via `onLongPress` sur une ligne
- Afficher une barre d'actions contextuelle fixée en bas en mode sélection
- Ajouter des méthodes batch au DAO (déplacer et consommer N bouteilles en transaction)
- Réutiliser `DeplacerForm` et `ConsommerForm` dans des bottom sheets batch

**Non-Goals:**
- "Tout sélectionner" (hors périmètre V1)
- Persistance de la sélection entre sessions
- Autres actions en lot (suppression, export, modification de fiche)
- Modification du schéma SQLite

## Decisions

### 1. État de sélection : StateNotifier dédié

**Décision :** `SelectionController extends StateNotifier<SelectionState>` dans `lib/features/stock/selection_controller.dart`. `SelectionState` : `{bool isSelectMode, Set<String> selectedIds}`.

**Rationale :** Séparer la sélection des filtres de recherche (`StockFilterController`) pour ne pas coupler deux préoccupations distinctes. Un StateNotifier dédié permet un `ref.watch` ciblé sans re-render des widgets de filtre à chaque clic.

**Alternative rejetée :** Embedder la sélection dans `StockFilterController` → couplage fort, rerendering excessif.

### 2. Entrée en mode sélection : onLongPress uniquement

**Décision :** `BouteilleListTile.onLongPress` entre en mode sélection ET sélectionne la bouteille cliquée. En mode sélection, `onTap` bascule la sélection (coche/décoche). `onLongPress` en mode sélection est ignoré.

**Rationale :** Cohérent avec les conventions Material (Gmail, Google Photos). Simple à implémenter avec les callbacks existants de `BouteilleListTile`.

**Alternative rejetée :** Icône dédiée ou checkbox toujours visible → désordre visuel, incompatible avec le layout table desktop.

### 3. Barre d'actions contextuelle : widget `BulkActionBar`

**Décision :** Nouveau widget `lib/features/stock/widgets/bulk_action_bar.dart` rendu dans `StockScreen` comme `bottomNavigationBar` additionnel (ou empilé via `Stack`), visible uniquement si `isSelectMode == true`.

**Rationale :** Sur Android le `BottomNavigationBar` existant est dans `adaptive_layout.dart` (hors `StockScreen`). La barre contextuelle doit s'afficher au-dessus. Utiliser `SafeArea + Positioned.fill` ou l'overlay dans `Scaffold.bottomSheet` permanent (`persistent: true`). Choix retenu : `Scaffold.bottomSheet` non-modal via `showBottomSheet` persistant — déclenché/masqué par `SelectionController`.

**Alternative rejetée :** Remplacer la barre de navigation — casse la navigation globale.

### 4. Batch DAO : transactions drift

**Décision :** Deux nouvelles méthodes dans `BouteilleDao` :
- `deplacerBouteilles(List<String> ids, String emplacement)` : transaction drift avec `batch()`, UPDATE WHERE id IN (ids)
- `consommerBouteilles(List<String> ids, DateTime date, double? note, String? commentaire)` : même pattern

**Rationale :** Drift expose `database.batch(...)` pour des écritures atomiques. Une seule transaction garantit la cohérence si l'opération est interrompue.

### 5. Réutilisation des formulaires existants

**Décision :** Les bottom sheets batch partagent le code des formulaires unitaires via des widgets extraits (`DeplacerFormContent`, `ConsommerFormContent`) passés à la fois aux sheets unitaires et aux sheets batch. Si l'extraction est trop invasive, créer des widgets `DeplacerBatchSheet` / `ConsommerBatchSheet` autonomes qui copient le formulaire.

**Rationale :** La logique de validation est identique. Évite la duplication de la validation d'emplacement et du DatePicker.

### 6. Mode lecture seule SyncReadOnly

**Décision :** `BulkActionBar` vérifie `syncStateProvider` — si `SyncReadOnly`, les boutons Déplacer et Consommer sont désactivés (grisés), un texte "Mode lecture seule" est affiché. Annuler reste actif.

**Rationale :** Cohérence avec la règle Mode lecture seule déjà appliquée au BottomSheet unitaire.

## Risks / Trade-offs

- **[Risque] Performances sur grand stock avec checkboxes** → Mitigation : `SelectionState` est un `Set<String>` (lookup O(1)), `BouteilleListTile` reçoit uniquement `isSelected` (bool) pour éviter un rebuild global.
- **[Risque] UX incohérente desktop vs mobile** (table desktop vs liste mobile) → Mitigation : `StockTable` et `BouteilleListTile` doivent tous deux supporter `onLongPress` et afficher la checkbox en mode sélection.
- **[Risque] Navigation pendant le mode sélection** → Mitigation : `SelectionController.reset()` appelé dans `onRouteChange` ou dans `dispose()` de `StockScreen`.
- **[Trade-off] Réutilisation vs duplication des formulaires** : extraire `DeplacerFormContent` nécessite un refactor des sheets existants. Si risque de régression, dupliquer puis consolider dans un second commit.
