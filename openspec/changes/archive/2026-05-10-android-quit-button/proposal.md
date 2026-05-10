## Why

En Mode 2 sur Android, le bouton "Sauvegarder et libérer" force l'utilisateur à relâcher le lock à chaque sauvegarde, ce qui l'oblige à reprendre la main (et donc déclencher une sync Drive) s'il veut continuer à modifier la cave. Il manque deux actions distinctes : sauvegarder en cours de session sans perdre le lock, et quitter proprement en libérant le lock.

## What Changes

- **RENOMMAGE** : le bouton `_SaveReleaseIconBtn` ("Sauvegarder et libérer" — `cloud_done`) est renommé "Sauvegarder" (`save`) et son comportement change : il uploade la cave sur Drive **sans** relâcher le lock ni quitter le mode écriture (utilise `syncService.sync()` au lieu de `syncService.releaseManual()`).
- **AJOUT** : un nouveau bouton "Quitter" (`exit_to_app`) est ajouté dans la zone sync de `_MobileBar`. Il uploade la cave, relâche le lock puis ferme le process Android (`syncService.releaseAndExit()`). Il s'affiche uniquement en mode écriture Android (`!isReadOnly && isAndroid && syncService.isActive`).
- Le bouton "Retour lecture seule" (`_AbandonWriteIconBtn`, `lock_reset`) reste inchangé : il abandonne les modifications locales sans sauvegarder et revient en SyncReadOnly.

## Capabilities

### New Capabilities

- `android-write-exit` : bouton "Quitter" Android en mode écriture — sauvegarde et libère le lock avant de fermer le process.

### Modified Capabilities

- `android-sync-ux` : le requirement "Libération manuelle sur Android" change de comportement — "Sauvegarder" conserve désormais le lock au lieu de le libérer.

## Impact

- `lib/shared/adaptive_layout.dart` : `_SaveReleaseIconBtn` renommé `_SaveIconBtn`, appel changé de `releaseManual()` à `sync()` ; ajout de `_QuitIconBtn` (appelle `releaseAndExit()`)
- `lib/services/sync_service.dart` : aucune modification — `sync()` et `releaseAndExit()` existent déjà avec le comportement requis
- Mode 2 Android uniquement — Mode 1, Mode 3 (futur) et Windows non concernés

## Non-goals

- Pas de nouveau bouton sur Windows (la fermeture fenêtre déclenche déjà `releaseAndExit()` via `didRequestAppExit`)
- Pas de modification de la logique de sync automatique au démarrage
- Pas de changement du comportement en Mode 1 ni en lecture seule
