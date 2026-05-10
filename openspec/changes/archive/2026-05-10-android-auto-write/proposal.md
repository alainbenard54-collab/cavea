## Why

Sur Android en Mode 2, l'app démarre actuellement en lecture seule et exige une action explicite "Prendre la main" pour passer en écriture — comportement inverse de Windows qui acquiert le verrou automatiquement au démarrage. Cette asymétrie est inutile maintenant que le bouton "Quitter" assure une sortie propre (upload + déverrouillage) côté Android.

## What Changes

- **Démarrage Android Mode 2 harmonisé** : si aucun verrou tiers n'est détecté, Android acquiert automatiquement le verrou et passe en mode écriture (identique à Windows).
- **Suppression du bouton "Prendre la main"** : devenu sans objet — Android est directement en écriture au démarrage.
- **Suppression du bouton "Revenir en lecture seule"** (`_AbandonWriteIconBtn`) sur Android : la seule sortie propre en Mode 2 Android est le bouton "Quitter" ; libérer le verrou sans quitter n'a plus de raison d'être.
- **Warning one-time "Pensez à utiliser Quitter"** : au premier passage en mode écriture sur Android, un dialog informe l'utilisateur qu'il doit utiliser le bouton "Quitter" pour sauvegarder et libérer le verrou. Option "Ne plus afficher" persistée dans SharedPreferences.

Les comportements inchangés : crash recovery (lock à nous au démarrage), lock tiers (lecture seule forcée), comportement Windows, bouton "Sauvegarder", bouton "Quitter".

## Capabilities

### New Capabilities

- `android-write-onboarding` : Dialog one-time avertissant l'utilisateur d'utiliser le bouton "Quitter" sur Android Mode 2. Affiché au premier passage en mode écriture, avec case "Ne plus afficher" persistée en SharedPreferences via `ConfigService`.

### Modified Capabilities

- `android-sync-ux` : Démarrage Android Mode 2 en écriture automatique (suppression lecture seule par défaut + suppression "Prendre la main" + suppression "Revenir en lecture seule").

## Impact

- `lib/shared/adaptive_layout.dart` : suppression `_AbandonWriteIconBtn`, suppression `_TakeOverIconBtn`, ajout dialog one-time `_WriteOnboardingDialog`
- `lib/services/sync_service.dart` : `syncOnStartup()` — chemin "lock absent" identique pour Android et Windows (acquiert le verrou, passe en écriture)
- `lib/services/config_service.dart` : nouvelle clé SharedPreferences `android_write_warning_shown`

## Non-goals

- Comportement Windows inchangé (aucune touche)
- Comportement lock tiers inchangé sur Android (lecture seule forcée, dialog existant)
- Crash recovery Android inchangé (dialog "Session précédente non terminée")
- Mode 1 Android non concerné
