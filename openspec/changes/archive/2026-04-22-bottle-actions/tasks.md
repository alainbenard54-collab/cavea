## 1. DAO — méthodes ciblées

- [x] 1.1 Ajouter `deplacerBouteille(String id, String emplacement)` dans `bouteille_dao.dart` (UPDATE emplacement uniquement)
- [x] 1.2 Ajouter `consommerBouteille(String id, {required String dateSortie, int? noteDegus, String? commentaireDegus})` dans `bouteille_dao.dart`
- [x] 1.3 Ajouter `getDistinctEmplacements()` dans `bouteille_dao.dart` (emplacements non vides distincts du stock, triés)

## 2. BottomSheet principal

- [x] 2.1 Créer `lib/features/bottle_actions/bottle_actions_sheet.dart` — BottomSheet avec titre (domaine + millésime) et menu 4 actions
- [x] 2.2 Implémenter la logique de routage interne : Déplacer/Consommer remplacent le contenu du sheet, Annuler ferme, Modifier fiche affiche SnackBar

## 3. Formulaire Déplacer

- [x] 3.1 Créer `lib/features/bottle_actions/widgets/deplacer_form.dart` — champ texte emplacement avec `Autocomplete<String>`
- [x] 3.2 Brancher `getDistinctEmplacements()` comme source de suggestions de l'Autocomplete
- [x] 3.3 Bouton Confirmer appelle `deplacerBouteille()` puis ferme le BottomSheet ; bouton Annuler ferme sans modification

## 4. Formulaire Consommer

- [x] 4.1 Créer `lib/features/bottle_actions/widgets/consommer_form.dart` — date pré-remplie aujourd'hui, bouton DatePicker (passé uniquement)
- [x] 4.2 Ajouter switch "Noter" + Slider 0–10 (pas 1) + champ commentaire optionnel
- [x] 4.3 Bouton Confirmer appelle `consommerBouteille()` puis ferme le BottomSheet

## 5. Intégration dans la vue stock

- [x] 5.1 Activer `onTap` sur les lignes du tableau desktop dans `stock_table.dart` (ouvre `bottle_actions_sheet`)
- [x] 5.2 Activer `onTap` sur les `BouteilleListTile` dans la liste mobile (même BottomSheet)
