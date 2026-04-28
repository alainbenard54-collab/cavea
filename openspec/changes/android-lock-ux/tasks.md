## 1. SyncService — démarrage Android en lecture seule

- [x] 1.1 Dans `syncOnStartup()` (`lib/services/sync_service.dart`), ajouter la branche Android lock absent : download Drive → `_lockHeldByUs = false` → `state = SyncReadOnly()` au lieu de `SyncIdle` — Android uniquement
- [x] 1.2 Vérifier que les branches "lock à nous" (crash recovery) et "lock tiers" restent inchangées sur Android — Android uniquement
- [x] 1.3 Vérifier que le comportement PC (lock absent → download → SyncIdle) est inchangé — PC uniquement

## 2. SyncService — nouvelles méthodes

- [x] 2.1 Implémenter `acquireLock()` dans `SyncService` : vérifie le lock (getLockStatus), acquiert si libre → `_lockHeldByUs = true` → `SyncIdle` ; si lock tiers → `SyncError` avec message — Android uniquement
- [x] 2.2 Implémenter `releaseManual()` dans `SyncService` : upload `cave.db` → unlock → `_lockHeldByUs = false` → `SyncReadOnly` — Android uniquement

## 3. UI — boutons Android dans `_MobileBar`

- [x] 3.1 Dans `_AppShellState.build()` (`lib/shared/adaptive_layout.dart`), calculer `final isAndroid = Platform.isAndroid` et le passer à `_MobileBar` — Android uniquement
- [x] 3.2 Dans `_MobileBar`, ajouter le bouton "Prendre la main" visible si `isAndroid && isReadOnly` — Android uniquement
- [x] 3.3 Le bouton "Prendre la main" affiche un `AlertDialog` de confirmation avec le texte : "Passe en mode écriture. Vos modifications seront sauvegardées sur Drive et le verrou libéré uniquement en appuyant sur 'Sauvegarder et libérer' avant de quitter. En cas d'oubli, la session suivante proposera de récupérer vos données." — Android uniquement
- [x] 3.4 À la confirmation, appeler `syncService.acquireLock()` — Android uniquement
- [x] 3.5 Dans `_MobileBar`, ajouter le bouton "Sauvegarder et libérer" visible si `isAndroid && showSyncButton` (isWriteMode) — remplace visuellement le bouton "Synchroniser" sur Android — Android uniquement
- [x] 3.6 Le bouton "Sauvegarder et libérer" appelle `syncService.releaseManual()` puis affiche la snackbar "Cave sauvegardée et verrou libéré" sur succès — Android uniquement
- [x] 3.7 Masquer le bouton "Synchroniser" existant sur Android (visible uniquement si `!Platform.isAndroid && showSyncButton`) — Android + PC

## 4. Tests manuels

- [x] 4.1 Android — démarrage Mode 2 lock absent : vérifier ouverture en lecture seule, cadenas ambre, bouton "Passer en écriture" visible [TEST MANUEL]
- [x] 4.2 Android — "Passer en écriture" : taper le bouton, lire le dialog de confirmation, confirmer, vérifier passage en écriture (cadenas vert, bouton "Sauvegarder et libérer" visible) [TEST MANUEL]
- [x] 4.3 Android — "Sauvegarder et libérer" : taper le bouton, vérifier snackbar, vérifier retour en lecture seule (cadenas ambre), vérifier lock absent sur Drive [TEST MANUEL]
- [x] 4.4 Android — exit sans libérer : passer en écriture, quitter l'app (swipe), relancer → vérifier dialog "Session précédente" avec confirmation avant exécution [TEST MANUEL]
- [x] 4.5 PC — vérifier comportement inchangé : lock automatique au démarrage, bouton "Synchroniser" présent, pas de "Passer en écriture" [TEST MANUEL]
- [x] 4.6 PC + Android simultanés — lock tiers : PC démarre (lock acquis), Android démarre → dialog "Cave utilisée", Fermer → retour lecture seule [TEST MANUEL]
- [x] 4.7 Android — crash recovery confirmations : vérifier dialog de confirmation avant "Envoyer mes données locales" et avant "Repartir depuis Drive" [TEST MANUEL]
- [x] 4.8 Android — "Retour lecture seule" : en mode écriture, taper "Retour lecture seule", lire confirmation, confirmer → snackbar, retour lecture seule, lock absent sur Drive [TEST MANUEL]
