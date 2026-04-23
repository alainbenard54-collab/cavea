## 1. DAO — insertion en lot

- [x] 1.1 Ajouter `insertBouteilles(List<BouteillesCompanion>)` dans `bouteille_dao.dart` (transaction drift)

## 2. Navigation

- [x] 2.1 Ajouter destination "Ajouter" (icône `add_circle_outline`) dans `adaptive_layout.dart`
- [x] 2.2 Ajouter route `/bulk-add` dans `router.dart`

## 3. Contrôleur Riverpod

- [x] 3.1 Créer `lib/features/bulk_add/bulk_add_controller.dart` — `BulkAddState` + `StateNotifier` (champs communs + quantité + groupes répartition)
- [x] 3.2 Implémenter `isValid` : champs obligatoires remplis + somme répartition == total

## 4. Widget RepartitionRow

- [x] 4.1 Créer `lib/features/bulk_add/widgets/repartition_row.dart` — ligne `(quantité, emplacement)` avec autocomplétion (réutilise la logique de `deplacer_form.dart`) et validation format emplacement
- [x] 4.2 Bouton suppression ; quantité ≥ 1 contrainte dans le champ

## 5. Écran principal

- [x] 5.1 Créer `lib/features/bulk_add/bulk_add_screen.dart` — `ListView` scrollable avec les groupes de champs (Identité, Garde & Prix, Fournisseur, Commentaire, Date)
- [x] 5.2 Intégrer la section Répartition : liste de `RepartitionRow` + bouton "+ Ajouter un emplacement" + indicateur "Assignées X / Y"
- [x] 5.3 Couleur : `DropdownButtonFormField` alimenté par `getAllDistinctCouleurs()` (toutes bouteilles) + champ texte libre si nouvelle couleur
- [x] 5.4 Date d'entrée : `OutlinedButton` DatePicker pré-rempli à aujourd'hui (dates passées uniquement)
- [x] 5.5 Bouton "Confirmer" : désactivé si `!isValid` ; appelle `insertBouteilles()` puis navigue vers `/`

## 6. Autocomplétion et valeurs par défaut (ajouts session)

- [x] 6.1 Widget `_AutocompleteField` — suggestions inline plein texte, controller stable, validator compatible `Form`
- [x] 6.2 Domaine, appellation, cru, contenance, fournisseur_nom utilisent `_AutocompleteField`
- [x] 6.3 DAO : `getAllDistinctCouleurs`, `getDistinctDomaines`, `getAllDistinctAppellations`, `getAllDistinctCrus`, `getAllDistinctContenances`, `getDistinctFournisseurs` (toutes bouteilles, sans filtre `date_sortie`)
- [x] 6.4 Contenance : valeur par défaut "75 cl" dans `BulkAddState`

## 7. Validation garde (ajouts session)

- [x] 7.1 `garde_min > garde_max` → snackbar d'erreur, insertion bloquée
- [x] 7.2 Garde absente → `AlertDialog` d'avertissement avec "Confirmer sans garde" / "Retour"

## 8. Corrections techniques (ajouts session)

- [x] 8.1 Champ quantité totale : `TextEditingController` stable (`_qtCtrl`) → corrige `setState during build`
- [x] 8.2 Champ quantité `RepartitionRow` : `TextFormField` → `TextField` → corrige `setState during build` via `didUpdateWidget`
- [x] 8.3 Champ emplacement `RepartitionRow` : `TextEditingController` stable (`_emplacementCtrl`) → supprime fuite mémoire et saut de curseur
- [x] 8.4 `initialValue: state.XXX` sur tous les champs `_field` → restaure affichage après recycle `ListView`
