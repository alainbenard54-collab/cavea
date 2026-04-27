## Context

L'implémentation actuelle de `syncOnStartup()` acquiert le lock automatiquement au démarrage en Mode 2, quelle que soit la plateforme. Sur Android, l'OS tue le process immédiatement après `AppLifecycleState.paused` (swipe, redémarrage appareil), avant que les requêtes HTTP Drive (upload + delete lock) puissent terminer. Le lock reste sur Drive indéfiniment. Le dialog "Session précédente interrompue" s'affiche à chaque lancement — systématiquement, pas exceptionnellement.

Fichiers concernés : `lib/services/sync_service.dart`, `lib/shared/adaptive_layout.dart`.

## Goals / Non-Goals

**Goals:**
- Éliminer le dialog "Session précédente" systématique sur Android
- Donner à l'utilisateur Android un contrôle explicite sur l'acquisition et la libération du lock
- Conserver le comportement PC inchangé (lock automatique, didRequestAppExit, crash recovery)
- Le crash recovery dialog reste utilisé sur Android mais devient exceptionnel (utilisateur a explicitement pris la main et oublié de libérer)

**Non-Goals:**
- WorkManager ou background tasks Android natifs
- Résolution automatique du lock sans interaction utilisateur
- Modification du comportement PC Windows
- Modification de StorageAdapter ou DriveStorageAdapter

## Decisions

### D1 — Lecture seule par défaut au démarrage Android

Sur Android, lock absent → download Drive → `SyncReadOnly` (au lieu de `SyncIdle`). Le lock n'est PAS acquis automatiquement.

Alternative écartée : garder l'acquisition automatique + WorkManager pour la release. WorkManager ne garantit pas le timing (Doze mode = minutes à heures) et nécessite un canal Kotlin natif pour accéder aux tokens OAuth chiffrés dans FlutterSecureStorage.

Alternative écartée : lock automatique + timeout court (1h au lieu de 24h). Réduirait la gêne mais ne résout pas le problème structurel. Un utilisateur absent 1h bloquerait quand même l'autre appareil.

La détection de plateforme se fait dans `syncOnStartup()` avec `Platform.isAndroid`.

### D2 — Deux nouveaux boutons dans `_MobileBar` (Android Mode 2)

**"Prendre la main"** — visible quand `SyncReadOnly` sur Android :
- Tape → dialog de confirmation : "Passe en mode écriture. Vos modifications seront sauvegardées sur Drive uniquement en appuyant sur 'Sauvegarder et libérer' avant de quitter. Si vous oubliez, la session suivante proposera de récupérer vos données."
- Confirme → appel `syncService.acquireLock()` → `SyncIdle`

**"Sauvegarder et libérer"** — visible quand `isWriteMode` sur Android (remplace "Synchroniser") :
- Tap direct (pas de confirmation) → appel `syncService.releaseManual()` → upload + unlock → `SyncReadOnly`
- Snackbar "Cave sauvegardée et verrou libéré"

Le bouton "Synchroniser" existant est masqué sur Android (sa fonction est absorbée par "Sauvegarder et libérer").

### D3 — Nouvelle méthode `acquireLock()` dans SyncService

```dart
Future<void> acquireLock() async {
  // Vérifie le lock, l'acquiert, passe en SyncIdle
}
```

Nouvelle méthode `releaseManual()` distincte de `releaseIfNeeded()` :
- `releaseIfNeeded()` : best-effort silencieux sur paused/détach — inchangé
- `releaseManual()` : action utilisateur explicite, upload + unlock + SyncReadOnly

### D4 — Détection Android dans `_MobileBar`

`_MobileBar` reçoit un paramètre `isAndroid` (calculé depuis `Platform.isAndroid` dans `_AppShellState.build`). Les boutons "Prendre la main" / "Sauvegarder et libérer" sont conditionnés à `isAndroid && syncService.isActive`.

Alternative écartée : passer `Platform.isAndroid` directement dans `_MobileBar`. Préféré : le calculer une fois dans `build()` pour lisibilité.

## Risks / Trade-offs

**[Lock non libéré si oubli]** → Le crash recovery dialog s'affiche au prochain lancement. C'est acceptable car l'utilisateur a explicitement choisi de prendre la main — il sait qu'il doit libérer. Le dialog n'est plus perçu comme un bug système mais comme un rappel logique.

**[Download au démarrage sans lock]** → En lecture seule, l'app télécharge Drive sans acquérir le lock. Si PC et Android démarrent simultanément, les deux peuvent lire Drive simultanément — correct, la lecture simultanée est sans danger. Seule l'écriture est serialisée par le lock.

**[Données locales non uploadées si sortie sans libérer]** → Assumé. Le crash recovery dialog permettra de récupérer au prochain lancement. L'utilisateur avait été prévenu lors de la confirmation "Prendre la main".
