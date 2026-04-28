## 1. ConfigService — defaults bulk-add + listes de référence

- [x] 1.1 Dans `lib/core/config_service.dart`, ajouter les constantes `builtinCouleurs`, `builtinContenances`, `builtinCrus` avec les valeurs métier — PC + Android
- [x] 1.2 Ajouter `_couleurDefaut?`, `_contenanceDefaut?`, `_refCouleurs?`, `_refContenances?`, `_refCrus?` comme champs cachés — PC + Android
- [x] 1.3 Charger les 5 valeurs dans `load()` via `prefs.getString` / `prefs.getStringList` — PC + Android
- [x] 1.4 Ajouter les getters `couleurDefaut`, `contenanceDefaut`, `refCouleurs`, `refContenances`, `refCrus` avec fallbacks — PC + Android
- [x] 1.5 Ajouter `saveBulkAddDefaults()`, `saveRefCouleurs()`, `saveRefContenances()`, `saveRefCrus()` — PC + Android

## 2. BulkAddController — contenance par défaut depuis ConfigService

- [x] 2.1 Dans `lib/features/bulk_add/bulk_add_controller.dart`, `BulkAddNotifier()` initialise `contenance: configService.contenanceDefaut` au lieu de `'75 cl'` hardcodé — PC + Android

## 3. BulkAddScreen — listes de référence + couleur par défaut

- [x] 3.1 Importer `config_service.dart` dans `bulk_add_screen.dart` — PC + Android
- [x] 3.2 Dans `initState()`, initialiser `_couleurs`, `_contenances`, `_crus` depuis `configService.refXxx` (synchrone, non vide dès le départ) — PC + Android
- [x] 3.3 Ajouter `_mergeWithRef(dbValues, refValues)` : ref en tête, puis valeurs DB inédites — PC + Android
- [x] 3.4 Dans `_loadLists()`, utiliser `_mergeWithRef` pour les 3 listes — PC + Android
- [x] 3.5 Dans `_CouleurFieldState`, ajouter `initState()` qui appelle `_applyInitialSelection()` — PC + Android
- [x] 3.6 `_applyInitialSelection()` lit `configService.couleurDefaut` (suppression du TODO + constante 'Rouge' hardcodée) — PC + Android
- [x] 3.7 `didUpdateWidget` simplifié : synchronise `_selected` si la valeur disparaît de la liste — PC + Android

## 4. SettingsScreen — section chemin cave.db (Mode 1)

- [x] 4.1 Ajouter `_DbPathSection extends StatefulWidget` avec affichage du dossier courant + bouton "Modifier" — PC uniquement
- [x] 4.2 Brancher "Modifier" sur `FilePicker.platform.getDirectoryPath()` ; sauvegarder + snackbar "redémarrez" — PC uniquement
- [x] 4.3 Section visible uniquement si `!isMode2` — PC uniquement

## 5. SettingsScreen — section valeurs par défaut bulk-add

- [x] 5.1 Ajouter `_BulkAddDefaultsSection extends StatefulWidget` avec dropdown couleur (depuis `configService.refCouleurs`) et TextField contenance — PC + Android
- [x] 5.2 Brancher sur `configService.saveBulkAddDefaults()` — PC + Android
- [x] 5.3 Insérer la section après "Emplacement" et avant "Listes de référence" — PC + Android

## 6. SettingsScreen — section listes de référence

- [x] 6.1 Créer `_RefListEditor extends StatefulWidget` avec `ExpansionTile`, chips `InputChip` avec `onDeleted`, et champ + bouton "Ajouter" — PC + Android
- [x] 6.2 Auto-save sur chaque modification (delete ou add) via `onSave` callback — PC + Android
- [x] 6.3 Insérer 3 `_RefListEditor` (Couleurs, Contenances, Crus) dans `SettingsScreen` — PC + Android

## 7. Tests manuels

- [ ] 7.1 Cave vide — ouvrir "Ajouter" : vérifier dropdown Couleur pré-rempli (builtins), liste Contenance et Cru non vides [TEST MANUEL]
- [ ] 7.2 Vérifier que `couleurDefaut` ("Rouge") est pré-sélectionné dans le dropdown Couleur [TEST MANUEL]
- [ ] 7.3 Mode 1 — Paramètres → "Emplacement" : affichage du dossier courant, modifier via file picker, snackbar affiché [TEST MANUEL]
- [ ] 7.4 Paramètres → "Ajout en lot" : changer couleur par défaut → ouvrir "Ajouter" → vérifier pré-sélection [TEST MANUEL]
- [ ] 7.5 Paramètres → "Listes de référence" → Couleurs : ajouter "Pétillant" → ouvrir "Ajouter" → vérifier présence [TEST MANUEL]
- [ ] 7.6 Paramètres → Couleurs : supprimer "Rosé effervescent" (chip X) → ouvrir "Ajouter" → vérifier absence (si non en base) [TEST MANUEL]
- [ ] 7.7 Cave avec données — vérifier que les couleurs/contenances/crus déjà en base apparaissent en bas de liste même si absents des listes de référence [TEST MANUEL]
- [ ] 7.8 Mode 2 — vérifier que la section "Emplacement" est absente en Mode 2, listes de référence et defaults toujours visibles [TEST MANUEL]
- [ ] 7.9 Bulk-add — Cru et Contenance sont des dropdowns : "(aucun)" sélectionnable, "Autre…" bascule vers saisie libre ; contenance défaut pré-sélectionné ; type-ahead clavier fonctionne quand le dropdown est ouvert [TEST MANUEL]
