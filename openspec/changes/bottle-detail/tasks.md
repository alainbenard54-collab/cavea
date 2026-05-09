## 1. Route et provider

- [x] 1.1 Vérifier si `bottleByIdProvider(String id)` existe dans `lib/providers/` ou `lib/dao/` — créer le provider Riverpod retournant un `Stream<Bouteille?>` depuis `BouteillesDao.watchBottleById(id)` si absent (PC + Android)
- [x] 1.2 Ajouter la route `/bottle/:id` dans le fichier router go_router (`lib/router.dart` ou équivalent) pointant vers `BottleDetailScreen` (PC + Android)

## 2. Écran BottleDetailScreen

- [x] 2.1 Créer `lib/ui/screens/bottle_detail_screen.dart` avec un `ConsumerWidget` lisant `bottleByIdProvider(id)` et affichant un indicateur de chargement / message "Bouteille introuvable" selon l'état du stream (PC + Android)
- [x] 2.2 Implémenter la section **Identité** : domaine, appellation, millésime, couleur, cru — affichage en `ListTile` ou `Text` simples, aucun `TextFormField` (PC + Android)
- [x] 2.3 Implémenter la section **Contenant** : contenance, emplacement (PC + Android)
- [x] 2.4 Implémenter la section **Acquisition** : date_entree, prix_achat, fournisseur_nom, fournisseur_infos, producteur (PC + Android)
- [x] 2.5 Implémenter la section **Garde** : garde_min, garde_max + badge maturité coloré calculé via `MaturityService` (bleu/vert/rouge/gris) — réutiliser le widget de badge déjà utilisé dans la vue stock si disponible (PC + Android)
- [x] 2.6 Implémenter la section **Notes entrée** : commentaire_entree (PC + Android)
- [x] 2.7 Implémenter la section **Consommation** conditionnelle : afficher date_sortie, note_degus, commentaire_degus **uniquement si** `date_sortie != null` (PC + Android)
- [x] 2.8 Vérifier que `id` et `updated_at` n'apparaissent nulle part dans l'écran (PC + Android)

## 3. Mise à jour du BottomSheet

- [x] 3.1 Dans `lib/ui/screens/bottle_actions_bottom_sheet.dart`, réordonner les actions en mode normal : Consommer → Consulter la fiche → Déplacer → Modifier la fiche → Annuler (PC + Android)
- [x] 3.2 Ajouter l'action "Consulter la fiche" en mode normal : fermer le BottomSheet puis naviguer via `context.push('/bottle/${bottle.id}')` (PC + Android)
- [x] 3.3 Mettre à jour le mode `SyncReadOnly` : remplacer le message statique par les deux options "Consulter la fiche" (navigation vers `/bottle/:id`) et "Fermer" (PC + Android)

## 4. Mise à jour de la documentation

- [x] 4.1 Mettre à jour la section `bottle-actions` dans `CLAUDE.md` : nouvel ordre des actions (Consommer, Consulter la fiche, Déplacer, Modifier la fiche, Annuler) + comportement `SyncReadOnly` mis à jour + description de la nouvelle action

## 5. Tests manuels

- [ ] 5.1 Tester l'ouverture de la fiche depuis le BottomSheet en mode normal — vérifier l'affichage de tous les champs d'une bouteille en stock (sections Consommation absentes) (PC)
- [ ] 5.2 Tester la fiche d'une bouteille consommée — vérifier l'apparition de la section Consommation avec date_sortie, note et commentaire (PC)
- [ ] 5.3 Tester le BottomSheet en mode `SyncReadOnly` — vérifier que seules "Consulter la fiche" et "Fermer" sont visibles, et que "Consulter la fiche" ouvre correctement `BottleDetailScreen` (PC + Android)
- [ ] 5.4 Tester avec un `id` invalide dans la route — vérifier l'affichage du message "Bouteille introuvable" et le bouton Retour (PC)
- [ ] 5.5 Tester le badge maturité sur la fiche : bouteille trop jeune (bleu), optimale (vert), à boire (rouge), sans données de garde (gris) (PC)
