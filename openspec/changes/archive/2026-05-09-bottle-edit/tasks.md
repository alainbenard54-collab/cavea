## 1. Route et structure

- [x] 1.1 Créer le dossier `lib/features/bottle_edit/` (PC + Android)
- [x] 1.2 Ajouter la route `/bottle-edit/:id` dans `lib/app/router.dart` hors du ShellRoute — builder instancie `BottleEditScreen(id: state.pathParameters['id']!)`

## 2. BottleEditScreen — squelette et chargement

- [x] 2.1 Créer `lib/features/bottle_edit/bottle_edit_screen.dart` : `ConsumerStatefulWidget` avec `AppBar` ("Modifier la fiche", bouton retour) et un `SingleChildScrollView` vide
- [x] 2.2 Implémenter le chargement de la bouteille dans `initState` via `BouteilleDao.getBouteilleById(id)` — afficher un loader pendant le chargement, un message d'erreur si la bouteille n'est pas trouvée
- [x] 2.3 Initialiser les `TextEditingController` pour chaque champ éditable à partir de la bouteille chargée — les disposer dans `dispose()`

## 3. Formulaire — champs simples

- [x] 3.1 Ajouter les champs `domaine`, `appellation`, `producteur` (TextFormField, PC + Android)
- [x] 3.2 Ajouter le champ `millesime` (TextFormField numérique, requis, PC + Android)
- [x] 3.3 Ajouter le champ `couleur` : DropdownMenu filtrable (`enableFilter: true`, saisie libre) — si la couleur actuelle est absente de la liste, l'ajouter comme option supplémentaire (PC + Android)
- [x] 3.4 Ajouter les champs `garde_min` et `garde_max` (TextFormField numériques optionnels, PC + Android)
- [x] 3.5 Ajouter les champs `prix_achat` (TextFormField décimal optionnel), `date_entree` (DatePicker, bouton OutlinedButton, PC + Android)
- [x] 3.6 Ajouter les champs `commentaire_entree`, `fournisseur_infos` (TextFormField multi-lignes optionnels, PC + Android)

## 4. Formulaire — champs avec autocomplétion

- [x] 4.1 Ajouter le champ `domaine` avec autocomplétion via `BouteilleDao.getDistinctDomaines()` (PC + Android)
- [x] 4.2 Ajouter le champ `appellation` avec autocomplétion via `BouteilleDao.getAllDistinctAppellations()` (PC + Android)
- [x] 4.3 Ajouter le champ `cru` avec DropdownMenu filtrable (`enableFilter: true`, saisie libre) via `BouteilleDao.getAllDistinctCrus()` (PC + Android)
- [x] 4.4 Ajouter le champ `contenance` avec DropdownMenu filtrable (`enableFilter: true`, saisie libre) via `BouteilleDao.getAllDistinctContenances()` (PC + Android)
- [x] 4.5 Ajouter le champ `fournisseur_nom` avec autocomplétion via `BouteilleDao.getDistinctFournisseurs()` (PC + Android)
- [x] 4.6 Ajouter le champ `emplacement` avec autocomplétion via `BouteilleDao.getDistinctEmplacements()` et validation du format hiérarchique (même regex que DeplacerForm) (PC + Android)

## 5. Validation et sauvegarde

- [x] 5.1 Implémenter la validation garde : si garde_min > garde_max → message d'erreur inline, sauvegarde bloquée (PC + Android)
- [x] 5.2 Implémenter le dialogue de confirmation pour garde partielle (un seul champ renseigné) : "Confirmer sans garde" ou "Retour" (PC + Android)
- [x] 5.3 Implémenter le bouton "Enregistrer" : assemble le `BouteillesCompanion` avec tous les champs + `updated_at = DateTime.now().toIso8601String()`, appelle `BouteilleDao.updateBouteille()`, puis `context.pop()` (PC + Android)
- [x] 5.4 Implémenter le bouton "Annuler" / retour arrière : `FocusScope.of(context).unfocus()` + `context.pop()` sans persistance (PC + Android)

## 6. Intégration BottomSheet

- [x] 6.1 Dans `bottle_actions_sheet.dart`, remplacer le callback `onModifierFiche` (SnackBar stub) par `Navigator.of(context).pop()` suivi de `context.push('/bottle-edit/${bouteille.id}')` (PC + Android)
- [x] 6.2 Vérifier que le mode lecture seule (`SyncReadOnly`) masque toujours "Modifier la fiche" — aucun changement requis si le BottomSheet readonly est déjà en place

## 7. Tests et validation

- [x] 7.1 Lancer `flutter test` → 0 regression sur les tests existants (PC)
- [x] 7.2 Test manuel PC : ouvrir le BottomSheet → "Modifier la fiche" → formulaire pré-rempli → modifier un champ → "Enregistrer" → vérifier la mise à jour dans la vue stock
- [x] 7.3 Test manuel PC : ouvrir l'éditeur → "Annuler" → vérifier qu'aucune modification n'est persistée
- [x] 7.4 Test manuel PC : tester la validation garde_min > garde_max (message d'erreur) et garde partielle (dialogue)
- [x] 7.5 Test manuel PC : tester l'autocomplétion sur au moins 3 champs (domaine, emplacement, cru) + bouton restore (↩)
- [x] 7.6 Test manuel Android : navigation, clavier, scroll, sauvegarde — OK. Défauts UX Android à traiter séparément.
