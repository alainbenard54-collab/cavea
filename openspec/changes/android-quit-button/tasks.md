## 1. Renommage _SaveReleaseIconBtn → _SaveIconBtn

- [ ] 1.1 Dans `lib/shared/adaptive_layout.dart`, renommer la classe `_SaveReleaseIconBtn` en `_SaveIconBtn`, changer l'icône de `Icons.cloud_done` en `Icons.save`, le tooltip de "Sauvegarder et libérer" en "Sauvegarder", et l'appel de `syncService.releaseManual()` en `syncService.sync()` (Android Mode 2 uniquement)
- [ ] 1.2 Mettre à jour toutes les références à `_SaveReleaseIconBtn` dans `_MobileBar.build()` (Android uniquement)

## 2. Nouveau bouton _QuitIconBtn

- [ ] 2.1 Créer la classe `_QuitIconBtn` dans `adaptive_layout.dart` : icône `Icons.exit_to_app`, tooltip "Quitter", appel `syncService.releaseAndExit()` après dialog de confirmation (Android Mode 2 uniquement)
- [ ] 2.2 Implémenter le dialog de confirmation dans `_QuitIconBtn` : titre "Sauvegarder et quitter ?", message "Vos modifications seront envoyées sur Drive et le verrou libéré.", boutons "Annuler" (TextButton) et "Quitter" (FilledButton)

## 3. Intégration dans _MobileBar

- [ ] 3.1 Dans `_MobileBar.build()`, ajouter `_QuitIconBtn` dans la zone sync, aux côtés de `_AbandonWriteIconBtn` et `_SaveIconBtn` — visible uniquement quand `!isReadOnly && isAndroid && syncService.isActive`

## 4. Gestion d'erreur SyncError après sync()

- [ ] 4.1 Vérifier que la snackbar d'erreur s'affiche correctement après un `SyncError` déclenché par `sync()` (déjà géré par le listener `ref.listen<SyncState>` dans `_AppShellState` — confirmer que le cas `SyncError` après `sync()` est bien couvert)

## 5. Tests manuels

- [ ] 5.1 Tester "Sauvegarder" : upload effectif sur Drive, lock conservé, snackbar "Cave sauvegardée sur Drive", app reste en mode écriture (Android Mode 2)
- [ ] 5.2 Tester "Quitter" : dialog de confirmation s'ouvre, annuler → rien, confirmer → overlay "Sauvegarde en cours…", upload Drive, lock libéré, app fermée (Android Mode 2)
- [ ] 5.3 Tester que "Quitter" est absent en mode lecture seule et en Mode 1 (Android)
- [ ] 5.4 Vérifier visuellement que les 3 boutons (Retour lecture seule + Sauvegarder + Quitter) tiennent correctement dans la zone sync sur petit écran Android
