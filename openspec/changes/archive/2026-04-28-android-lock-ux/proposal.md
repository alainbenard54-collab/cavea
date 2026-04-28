## Why

Sur Android (Mode 2), l'OS tue le process immédiatement après `AppLifecycleState.paused`, avant que les requêtes HTTP (upload + delete lock) aient le temps de terminer. Le lock reste donc indéfiniment sur Drive et le dialog "Session précédente interrompue" s'affiche à chaque démarrage — comportement systématique et inacceptable. WorkManager a été évalué et écarté : il ne garantit pas le timing (Doze mode = délai de minutes à heures) et nécessite un canal natif Kotlin pour accéder aux tokens OAuth chiffrés.

## What Changes

- **Démarrage Android Mode 2** : lock absent → téléchargement Drive → ouverture en **lecture seule** (SyncReadOnly) au lieu de SyncIdle ; le lock n'est plus acquis automatiquement
- **"Prendre la main"** : nouveau bouton visible en lecture seule sur Android — acquiert le lock et passe en mode écriture ; affiche un dialog de confirmation expliquant que sauvegarde + libération manuelle sont requises avant de quitter
- **"Sauvegarder et libérer"** : nouveau bouton proéminent visible dès que le lock est détenu sur Android — upload + unlock + retour en lecture seule ; remplace le bouton "Synchroniser" sur Android
- Le crash recovery dialog existant est conservé sur Android (lock à nous = session précédente non libérée) — mais il devient exceptionnel car l'utilisateur sait qu'il doit libérer manuellement
- Le comportement PC Windows est **inchangé** (lock automatique, didRequestAppExit, crash recovery)

## Capabilities

### New Capabilities
- `android-sync-ux` : comportement de session Mode 2 sur Android — lecture seule par défaut, acquisition et libération explicites du lock par l'utilisateur

### Modified Capabilities
- `app-config` : le comportement de démarrage Mode 2 change selon la plateforme (Android = lecture seule par défaut vs PC = écriture automatique)

## Impact

- `lib/services/sync_service.dart` : `syncOnStartup()` — sur Android, lock absent → SyncReadOnly après download ; nouvelle méthode `acquireLock()` publique
- `lib/shared/adaptive_layout.dart` : `_MobileBar` — boutons "Prendre la main" et "Sauvegarder et libérer" ; retrait du bouton "Synchroniser" sur Android
- `CLAUDE.md` : mise à jour spec Android Mode 2

## Non-goals

- WorkManager ou tout mécanisme de release en arrière-plan Android
- Modification du comportement PC (Windows)
- Résolution de conflits (last-write-wins inchangé)
- Mode 3 (mobile seul, hors MVP)
