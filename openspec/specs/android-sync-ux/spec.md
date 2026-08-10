## Purpose
Comportement de synchronisation Mode 2 spécifique à Android : démarrage direct en mode écriture, libération manuelle du verrou, et message d'erreur explicite en cas d'échec d'authentification Google Drive.

## Requirements

### Requirement: Démarrage Android Mode 2 en mode écriture
En Mode 2, si aucun verrou tiers n'est détecté et que le verrou ne nous appartient pas, l'application Android SHALL acquérir le verrou et passer en mode écriture (SyncIdle), identiquement au comportement Windows.

#### Scenario: Démarrage Android lock absent — Drive contient cave.db
- **WHEN** l'app Android démarre en Mode 2, aucun lock n'est présent sur Drive, et `cave.db` existe sur Drive
- **THEN** l'app pose le verrou, télécharge `cave.db` depuis Drive, passe en SyncIdle et affiche l'écran principal en mode écriture

#### Scenario: Démarrage Android lock absent — Drive vide (premier lancement)
- **WHEN** l'app Android démarre en Mode 2, aucun lock n'est présent sur Drive, et `cave.db` n'existe pas encore sur Drive
- **THEN** l'app pose le verrou, uploade la base locale vers Drive, passe en SyncIdle et affiche l'écran principal en mode écriture

#### Scenario: Démarrage Android lock à nous (crash recovery)
- **WHEN** l'app Android démarre en Mode 2 et que le lock appartient à cet appareil
- **THEN** l'app affiche le dialog "Session précédente non terminée", puis passe en SyncIdle (mode écriture, lock conservé) après résolution

#### Scenario: Démarrage Android lock tiers
- **WHEN** l'app Android démarre en Mode 2 et que le lock appartient à un autre appareil
- **THEN** l'app affiche le dialog existant "Cave utilisée sur un autre appareil" (lecture seule ou quitter)

---

### Requirement: Libération manuelle sur Android
En mode écriture sur Android (Mode 2), l'application SHALL afficher un bouton "Sauvegarder" (upload sans libérer le lock) et un bouton "Quitter" (upload + unlock + exit).

#### Scenario: Tap sur "Sauvegarder" en mode écriture Android
- **WHEN** l'utilisateur tape "Sauvegarder" en mode écriture sur Android
- **THEN** l'app uploade `cave.db` sur Drive, conserve le lock, reste en SyncIdle, et affiche une snackbar "Cave sauvegardée sur Drive"

#### Scenario: Tap sur "Quitter" en mode écriture Android
- **WHEN** l'utilisateur tape "Quitter" en mode écriture sur Android
- **THEN** l'app affiche le dialog de confirmation "Sauvegarder et quitter ?"

#### Scenario: Échec de la sauvegarde
- **WHEN** l'upload échoue (perte réseau) lors d'un "Sauvegarder"
- **THEN** l'app affiche un message d'erreur et reste en mode écriture (lock toujours détenu, SyncError)

---

### Requirement: Message d'erreur explicite si Google Drive échoue sur Android
Quand l'authentification Google Drive échoue sur Android (ex. SHA-1 non enregistré dans GCP), l'app SHALL afficher un message d'erreur explicite et actionnable plutôt que rester silencieuse.

#### Scenario: SHA-1 non enregistré — message d'erreur affiché
- **WHEN** l'utilisateur tente de s'authentifier avec Google Drive sur Android et que le SHA-1 de la clé de signature APK n'est pas enregistré dans GCP Console
- **THEN** l'app affiche un message d'erreur indiquant que la configuration Google Cloud est incomplète et que le SHA-1 du certificat de signature doit être enregistré dans GCP Console

#### Scenario: Échec générique Google Sign-In — message d'erreur affiché
- **WHEN** `GoogleSignIn.instance.authenticate()` retourne `null` ou lève une exception
- **THEN** l'app affiche le message d'erreur dans le wizard ou dans Settings (selon le contexte) et l'utilisateur peut réessayer
