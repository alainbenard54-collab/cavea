## 1. Données — DAO

- [x] 1.1 Ajouter `watchHistorique()` dans `BouteilleDao` : `SELECT * FROM bouteilles WHERE date_sortie IS NOT NULL AND date_sortie != '' ORDER BY date_sortie DESC` — retourne `Stream<List<Bouteille>>`
- [x] 1.2 Ajouter `rehabiliterBouteille(String id)` dans `BouteilleDao` : UPDATE `date_sortie=NULL`, `note_degus=NULL`, `commentaire_degus=NULL`, `updated_at=now()`

## 2. Provider

- [x] 2.1 Créer `lib/features/history/history_provider.dart` : `historyProvider` (StreamProvider basé sur `watchHistorique()`), `historySearchProvider` (StateProvider<String> pour la recherche texte)

## 3. Écran Historique

- [x] 3.1 Créer `lib/features/history/history_screen.dart` : `HistoryScreen` (ConsumerStatefulWidget) avec SearchBar, liste bouteilles consommées, état vide "Aucune bouteille consommée."
- [x] 3.2 Filtrer la liste côté Dart selon `historySearchProvider` (contient dans domaine ou appellation, insensible à la casse)
- [x] 3.3 Chaque ligne de la liste : domaine (titre), appellation + millésime (sous-titre), date de consommation formatée `dd/MM/yyyy` (trailing), note /10 si renseignée

## 4. BottomSheet détail + Réhabiliter

- [x] 4.1 Créer `lib/features/history/history_actions_sheet.dart` : `showHistoryActionsSheet(context, bouteille)` — BottomSheet affichant domaine, appellation, millésime, couleur, emplacement, date sortie, note /10, commentaire dégustation
- [x] 4.2 Ajouter bouton "Consulter la fiche" dans le BottomSheet → route `/bottle/:id` (réutilise `BottleDetailScreen`)
- [x] 4.3 Ajouter bouton "Réhabiliter" dans le BottomSheet (masqué si SyncReadOnly) → AlertDialog de confirmation précisant la perte de note/commentaire et la remise en stock
- [x] 4.4 Sur confirmation : appeler `rehabiliterBouteille(id)`, fermer le BottomSheet — la liste se met à jour automatiquement via stream drift

## 5. Intégration navigation principale

- [x] 5.1 Ajouter la route `/history` dans `router.dart` → `HistoryScreen`
- [x] 5.2 Ajouter "Historique" (`Icons.history`, index 3) et décaler Import CSV (4) et Paramètres (5) dans `_DesktopRail` (Windows) dans `adaptive_layout.dart`
- [x] 5.3 `_MobileBar` Android — remplacer l'onglet Import CSV et Paramètres par un onglet "Plus" (`Icons.more_horiz`, index 4) ; ajouter les 4 onglets primaires (Stock=0, Ajouter=1, Emplacements=2, Historique=3) ; mettre à jour `_writeOnlyIndices = {1}` (Ajouter uniquement)
- [x] 5.4 Créer `_MoreMenuSheet` : `ModalBottomSheet` listant Import CSV et Paramètres comme `ListTile` ; affiché au tap sur l'onglet Plus ; le bouton Plus est coloré `colorScheme.primary` quand `selectedIndex >= 4`
- [x] 5.5 Mettre à jour `onDestinationSelected` dans `adaptive_layout.dart` pour les nouveaux index globaux (0→5)

## 6. Tests manuels

- [x] 6.1 Windows : vérifier que l'onglet Historique apparaît dans le rail à l'index 3 et affiche la liste des bouteilles consommées triées par date décroissante
- [x] 6.2 Windows : recherche texte — saisir un domaine → liste filtrée ; effacer → liste complète
- [x] 6.3 Windows : tap sur une bouteille → BottomSheet avec les informations complètes
- [x] 6.4 Windows : cliquer "Réhabiliter" → AlertDialog de confirmation → confirmer → bouteille disparaît de l'historique et réapparaît dans le stock
- [x] 6.5 Windows : cliquer "Réhabiliter" → AlertDialog → annuler → aucune modification
- [x] 6.6 Windows : vérifier que Import CSV (index 4) et Paramètres (index 5) fonctionnent toujours correctement dans le rail
- [x] 6.7 Mode SyncReadOnly : ouvrir le BottomSheet historique → bouton Réhabiliter absent, message lecture seule affiché
- [x] 6.8 Android : vérifier que l'onglet Historique est accessible dans la barre du bas sans overflow
- [x] 6.9 Consommer une bouteille depuis la vue Stock → elle apparaît immédiatement en tête de l'historique (réactivité drift)
- [x] 6.10 Android : tap sur ⋯ Plus → BottomSheet avec Import CSV et Paramètres accessibles ; vérifier que l'icône Plus est colorée quand Import CSV ou Paramètres est l'écran actif
