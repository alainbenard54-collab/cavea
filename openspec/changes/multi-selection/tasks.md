## 1. DAO — méthodes batch

- [x] 1.1 Ajouter `deplacerBouteilles(List<String> ids, String emplacement)` dans `lib/data/daos/bouteille_dao.dart` — UPDATE batch en transaction drift (PC + Android)
- [x] 1.2 Ajouter `consommerBouteilles(List<String> ids, DateTime date, double? note, String? commentaire)` dans `lib/data/daos/bouteille_dao.dart` — UPDATE batch en transaction drift (PC + Android)

## 2. État de sélection — SelectionController

- [x] 2.1 Créer `lib/features/stock/selection_controller.dart` : `SelectionState` (isSelectMode, Set<String> selectedIds) + `SelectionController extends StateNotifier<SelectionState>` avec méthodes `enterSelectMode(String id)`, `toggleId(String id)`, `reset()` (PC + Android)
- [x] 2.2 Exposer `selectionProvider` (StateNotifierProvider) dans `selection_controller.dart` (PC + Android)

## 3. UI — Checkboxes sur les lignes

- [x] 3.1 Modifier `lib/features/stock/bouteille_list_tile.dart` : ajouter paramètre `isSelectMode`, `isSelected`, `onLongPress` — afficher leading Checkbox si `isSelectMode`, changer `onTap` en bascule de sélection si `isSelectMode` (PC + Android)
- [x] 3.2 Modifier `lib/features/stock/stock_table.dart` : ajouter colonne checkbox de sélection en première position si `isSelectMode`, `DataRow.onSelectChanged` en mode sélection, `onLongPress` sur chaque ligne (PC uniquement)

## 4. UI — Barre d'actions contextuelle

- [x] 4.1 Créer `lib/features/stock/widgets/bulk_action_bar.dart` : widget affichant compteur "N bouteille(s) sélectionnée(s)", boutons Déplacer / Consommer / Annuler, gestion SyncReadOnly (boutons grisés + texte "Mode lecture seule") (PC + Android)
- [x] 4.2 Intégrer `BulkActionBar` dans `lib/features/stock/stock_screen.dart` via `Scaffold.bottomSheet` persistant, visible uniquement si `isSelectMode == true` (PC + Android)

## 5. UI — Câblage du mode sélection dans StockScreen

- [x] 5.1 Modifier `stock_screen.dart` : passer `isSelectMode`, `isSelected`, `onLongPress` et callbacks tap aux `BouteilleListTile` et `StockTable` depuis `selectionProvider` (PC + Android)
- [x] 5.2 Modifier `stock_screen.dart` : désactiver l'ouverture du BottomSheet unitaire si `isSelectMode == true` (PC + Android)
- [x] 5.3 Appeler `selectionController.reset()` lors de la navigation hors de StockScreen (dispose ou listener go_router) (PC + Android)

## 6. Formulaires batch — Déplacer en lot

- [x] 6.1 Créer `lib/features/stock/widgets/deplacer_batch_sheet.dart` : BottomSheet avec champ emplacement + autocomplétion (réutiliser la logique de `deplacer_form.dart`), appelle `bouteilleDaoProvider.deplacerBouteilles(...)` à la confirmation (PC + Android)
- [x] 6.2 Brancher le bouton "Déplacer" de `BulkActionBar` sur `showDeplacerBatchSheet(context, selectedIds)` (PC + Android)

## 7. Formulaires batch — Consommer en lot

- [x] 7.1 Créer `lib/features/stock/widgets/consommer_batch_sheet.dart` : BottomSheet avec DatePicker (défaut aujourd'hui), champ note /10 optionnel, champ commentaire optionnel (réutiliser la logique de `consommer_form.dart`), appelle `bouteilleDaoProvider.consommerBouteilles(...)` à la confirmation (PC + Android)
- [x] 7.2 Brancher le bouton "Consommer" de `BulkActionBar` sur `showConsommerBatchSheet(context, selectedIds)` (PC + Android)

## 8. Tests manuels

- [ ] 8.1 Tester appui long → entrée en mode sélection, checkbox cochée sur la bouteille cible (PC + Android)
- [ ] 8.2 Tester tap en mode sélection → bascule coche/décoche, compteur mis à jour (PC + Android)
- [ ] 8.3 Tester Annuler → sortie mode sélection, disparition checkboxes, retour au comportement tap normal (PC + Android)
- [ ] 8.4 Tester Déplacer en lot : formulaire s'ouvre, validation emplacement, toutes les bouteilles déplacées, mode sélection désactivé après confirmation (PC + Android)
- [ ] 8.5 Tester Consommer en lot : formulaire s'ouvre, date modifiable, bouteilles consommées disparaissent du stock, mode sélection désactivé (PC + Android)
- [ ] 8.6 Tester mode lecture seule (SyncReadOnly) : boutons Déplacer et Consommer grisés, Annuler fonctionnel (Mode 2 uniquement)

<!-- Tests manuels à effectuer après lancement de l'application -->
