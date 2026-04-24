## 1. DriveStorageAdapter — scope et dossier Cavea

- [x] 1.1 Remplacer `driveAppdataScope` par `driveFileScope` dans la constante `_driveScope` (PC + Android)
- [x] 1.2 Mettre à jour `GoogleSignIn(scopes: [...])` Android pour utiliser `DriveApi.driveFileScope`
- [x] 1.3 Ajouter champ `String? _folderId` et méthode `_ensureFolder()` : trouve ou crée le dossier `Cavea` à la racine Drive, met en cache `_folderId`
- [x] 1.4 Mettre à jour `_findFileId()` : `spaces: 'drive'`, filtre `'<folderId>' in parents` (appel `_ensureFolder()` en amont)
- [x] 1.5 Mettre à jour `_uploadBytes()` : `parents: [folderId]` au lieu de `['appDataFolder']`
- [x] 1.6 Vérifier que `_deleteFile()` fonctionne toujours (utilise l'id retourné par `_findFileId` — pas de changement de logique)
- [ ] 1.7 Tester manuellement (PC) : premier lancement crée le dossier `Cavea` visible dans Drive UI, `cave.db` y apparaît après un upload

## 2. SyncService — nouveaux états et syncOnStartup()

- [x] 2.1 Ajouter les états `SyncStarting` et `SyncReadOnly` dans le sealed class `SyncState`
- [x] 2.2 Ajouter les getters `isReadOnly` et `isWriteMode` sur `SyncService` (calculés depuis l'état courant)
- [x] 2.3 Ajouter champ `bool _lockHeldByUs = false` (indique si cet appareil détient le lock en session)
- [x] 2.4 Implémenter `syncOnStartup()` : lock libre → lock + download/upload → `_lockHeldByUs = true` → `SyncIdle` ; lock à nous → retourner `LockStatus.lockedByUs` pour dialog ; lock tiers → retourner status pour dialog
- [x] 2.5 Modifier `sync()` (bouton) : ne s'exécute qu'en mode écriture (`isWriteMode`), upload uniquement, lock conservé, snackbar "Cave sauvegardée sur Drive" géré en dehors du service
- [x] 2.6 Adapter `releaseIfNeeded()` : upload + unlock si `_lockHeldByUs` (à la fermeture)
- [x] 2.7 Réinitialiser `_lockHeldByUs = false` dans `dispose()`

## 3. AppWrapper — dialogs de démarrage et interception fermeture

- [x] 3.1 Dans `_AppWrapperState.initState()`, après chargement config Mode 2, appeler `syncOnStartup()` et passer en état `SyncStarting` pendant l'opération (afficher un écran de chargement ou spinner)
- [x] 3.2 Implémenter le dialog crash recovery ("Session précédente interrompue") : boutons "Envoyer mes données locales" et "Repartir depuis Google Drive (perte de modifications locales possible)" — déclencher upload ou download selon choix, puis passer en mode écriture
- [x] 3.3 Implémenter le dialog lock tiers ("Cave utilisée sur un autre appareil") : boutons "Consulter en lecture seule" (download sans lock → `SyncReadOnly`) et "Annuler" (quitte l'app via `SystemNavigator.pop()`)
- [x] 3.4 Afficher les dialogs via `WidgetsBinding.instance.addPostFrameCallback` (contexte `_AppWrapperState`, pas Navigator)
- [x] 3.5 Implémenter `didRequestAppExit()` dans `_AppWrapperState` (PC/Windows) : si mode écriture → afficher dialog progression → appeler `releaseIfNeeded()` → `ServicesBinding.instance.exitApplication(AppExitType.required)` ; si lecture seule ou Mode 1 → `AppExitResponse.exit` direct
- [x] 3.6 Implémenter `didChangeAppLifecycleState(AppLifecycleState.detach)` pour Android (best-effort) : appel `releaseIfNeeded()` sans dialog

## 4. UI — indicateur visuel AppBar

- [x] 4.1 Dans le widget AppBar de `AdaptiveLayout`, ajouter l'icône de mode : `Icons.computer` gris (Mode 1) / `Icons.cloud` bleu (Mode 2), avec tooltip
- [x] 4.2 En Mode 2, ajouter l'icône de verrou à côté : `Icons.lock_open` vert (écriture) / `Icons.lock` ambre (lecture seule), avec tooltip ; absente pendant `SyncStarting`
- [x] 4.3 Connecter les icônes au provider `syncServiceProvider` (watch état courant)
- [ ] 4.4 Vérifier rendu PC (NavigationRail) et Android (BottomNavigationBar) — icônes bien positionnées dans les deux layouts (test manuel)

## 5. UI — bouton Sync et snackbar

- [x] 5.1 Dans `SettingsScreen` (ou AppBar selon placement actuel), masquer le bouton "Synchroniser" si `isReadOnly`
- [x] 5.2 Modifier l'action du bouton Sync : appeler `sync()` (upload uniquement) puis afficher snackbar "Cave sauvegardée sur Drive"
- [x] 5.3 Supprimer la logique lock/download du bouton Sync (c'est maintenant `syncOnStartup()` qui s'en charge)

## 6. Tests manuels

- [ ] 6.1 PC — démarrage nominal : dossier `Cavea` créé, `cave.db` uploadé, icône nuage + cadenas vert visibles
- [ ] 6.2 PC — bouton Sync : `cave.db` mis à jour dans Drive, snackbar affiché, lock conservé
- [ ] 6.3 PC — fermeture Alt+F4 : dialog progression affiché, `cave.db` uploadé, lock supprimé, app fermée
- [ ] 6.4 PC — simulation crash (kill process) puis redémarrage : dialog crash recovery affiché, choix "Envoyer local" fonctionne, choix "Drive" fonctionne
- [ ] 6.5 PC — vérifier dans Drive UI : dossier `Cavea` visible, `cave.db` présent, `cave.db.lock` absent après fermeture propre
- [ ] 6.6 Android — démarrage en Mode 2 : connexion Google, dossier `Cavea` accessible, téléchargement, icônes AppBar correctes
- [ ] 6.7 Deux appareils — lock tiers : démarrer sur PC (lock acquis), démarrer sur Android → dialog "Consulter en lecture seule" affiché, icône cadenas ambre visible
