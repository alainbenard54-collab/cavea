## 1. Données — requête drift

- [x] 1.1 Ajouter la classe `LocationLeaf` dans `bouteille_dao.dart` : `emplacement` (String), `count` (int), `sumPrix` (double?) — résultat brut d'une ligne SQL
- [x] 1.2 Ajouter `watchLocationStats()` dans `BouteilleDao` : `SELECT emplacement, COUNT(*) AS cnt, SUM(prix_achat) AS total FROM bouteilles WHERE date_sortie IS NULL GROUP BY emplacement ORDER BY emplacement` — retourne `Stream<List<LocationLeaf>>`

## 2. Modèle d'arbre et providers

- [x] 2.1 Créer `lib/features/locations/location_node.dart` : classe `LocationNode` (label, fullPath, children, directCount, directSumPrix) + fonction `buildTree(List<LocationLeaf>)` qui split sur ` > ` et construit l'arbre récursivement
- [x] 2.2 Créer `lib/features/locations/location_provider.dart` : `locationLeavesProvider` (StreamProvider basé sur `watchLocationStats()`), `includeSublocationsProvider` (StateProvider<bool>, défaut false)
- [x] 2.3 Ajouter helper `nodeStats(LocationNode, bool includeChildren)` → `(int count, double? sumPrix)` — calcule les stats d'un nœud selon le toggle

## 3. Écran principal de l'arbre (LocationTreeScreen)

- [x] 3.1 Créer `lib/features/locations/location_tree_screen.dart` : `LocationTreeScreen` (ConsumerWidget) — construit l'arbre depuis `locationLeavesProvider`, affiche les nœuds racine triés alphabétiquement
- [x] 3.2 Créer le widget `LocationNodeTile` : affiche `label` + stats `N bouteilles (NN €)` (ou `N bouteilles` si sumPrix null/0), flèche si enfants, icône feuille si feuille
- [x] 3.3 Ajouter le toggle `SwitchListTile` "Inclure les sous-emplacements" en haut de `LocationTreeScreen`, branché sur `includeSublocationsProvider`
- [x] 3.4 Gérer l'état de chargement (`AsyncLoading`) et l'état d'erreur (`AsyncError`) dans `LocationTreeScreen`

## 4. Navigation dans l'arbre (LocationNodeScreen)

- [x] 4.1 Créer `lib/features/locations/location_node_screen.dart` : `LocationNodeScreen(LocationNode node)` — affiche les enfants directs du nœud avec leurs stats, même toggle
- [x] 4.2 Brancher le tap sur `LocationNodeTile` : si nœud a des enfants → `Navigator.push` vers `LocationNodeScreen` ; si feuille → `Navigator.push` vers `LocationBottleListScreen`

## 5. Liste de bouteilles au nœud feuille (LocationBottleListScreen)

- [x] 5.1 Ajouter `watchBouteillesParEmplacement(String emplacement, {bool includeSublocations})` dans `BouteilleDao` : filtre `WHERE date_sortie IS NULL AND emplacement = ?` (exact) ou `LIKE ? || ' > %' OR emplacement = ?` (avec sous-emplacements)
- [x] 5.2 Créer `lib/features/locations/location_bottle_list_screen.dart` : `LocationBottleListScreen(LocationNode node, bool includeSublocations)` — affiche la liste des bouteilles via le stream filtré, réutilise le widget de liste du stock
- [x] 5.3 Brancher le tap bouteille sur `showBottleActions()` (BottomSheet d'actions existant) — lecture seule automatique si `SyncReadOnly`
- [x] 5.4 Brancher appui long sur `selectionProvider` (selection_controller.dart) + afficher `BulkActionBar` — désactivé si `SyncReadOnly`

## 6. Intégration navigation principale

- [x] 6.1 Ajouter la route `/locations` dans `router.dart` → `LocationTreeScreen`
- [x] 6.2 Ajouter l'entrée "Emplacements" (`Icons.shelves` ou `Icons.inventory_2`) dans `_DesktopRail` (Windows) dans `adaptive_layout.dart`, à la 3e position (après Stock, Ajouter)
- [x] 6.3 Ajouter l'icône Emplacements dans `_MobileBar` (Android) dans `adaptive_layout.dart`, zone centrale (entre Ajouter et Import)
- [x] 6.4 Réinitialiser `includeSublocationsProvider` à false quand l'utilisateur quitte l'onglet Emplacements (via `ref.invalidate` dans `onDestinationSelected` ou un AutoDispose)

## 7. Tests manuels

- [ ] 7.1 Windows : vérifier que l'onglet Emplacements apparaît dans le rail et affiche l'arbre des nœuds Niveau 1 avec stats correctes
- [ ] 7.2 Windows : naviguer Niveau1 → Niveau2 → bouteilles — vérifier que le fil d'Ariane (AppBar title) indique le chemin et que le retour fonctionne
- [ ] 7.3 Windows + Android : activer le toggle "Inclure sous-emplacements" — vérifier que les stats des nœuds parents augmentent pour inclure les enfants
- [ ] 7.4 Windows : vérifier la liste bouteilles d'un nœud feuille — tap ouvre le BottomSheet d'actions (Consommer, Déplacer, etc.)
- [ ] 7.5 Android : vérifier que l'onglet Emplacements est accessible dans la barre du bas et fonctionne identiquement
- [ ] 7.6 Mode 2 SyncReadOnly : vérifier que le BottomSheet dans la liste bouteilles affiche "Mode lecture seule" uniquement
- [ ] 7.7 Mode écriture : effectuer une action "Déplacer" depuis la liste bouteilles d'un emplacement — vérifier que les stats de l'arbre se mettent à jour en temps réel (stream drift)
- [ ] 7.8 Vérifier l'affichage quand certaines bouteilles n'ont pas de prix_achat : le format doit être `N bouteilles (NN €)` avec la somme partielle, pas d'erreur
