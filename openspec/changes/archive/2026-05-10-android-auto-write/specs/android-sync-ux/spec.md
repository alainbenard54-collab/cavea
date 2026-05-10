## REMOVED Requirements

### Requirement: Démarrage Android Mode 2 en lecture seule
**Reason**: Remplacé par un démarrage en mode écriture automatique (harmonisation avec Windows). Le bouton "Quitter" assure désormais la sortie propre sur Android.
**Migration**: Le scénario "lock absent" sur Android suit maintenant le chemin PC (acquisition lock + SyncIdle). Les scénarios "lock à nous" et "lock tiers" sont inchangés.

### Requirement: Prise de main explicite sur Android
**Reason**: Devenu sans objet — Android arrive directement en mode écriture au démarrage. Le bouton `_AcquireLockIconBtn` est supprimé.
**Migration**: Aucune. L'acquisition de lock est automatique.

---

## MODIFIED Requirements

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
- **THEN** l'app affiche le dialog "Session précédente non terminée" (comportement inchangé)

#### Scenario: Démarrage Android lock tiers
- **WHEN** l'app Android démarre en Mode 2 et que le lock appartient à un autre appareil
- **THEN** l'app affiche le dialog "Cave utilisée sur un autre appareil" (comportement inchangé)

---

### Requirement: Libération manuelle sur Android
En mode écriture sur Android (Mode 2), l'application SHALL afficher un bouton "Sauvegarder" (upload sans libérer le lock) et un bouton "Quitter" (upload + unlock + exit). Le bouton "Retour lecture seule" (`_AbandonWriteIconBtn`) est supprimé.

#### Scenario: Tap sur "Sauvegarder" en mode écriture Android
- **WHEN** l'utilisateur tape "Sauvegarder" en mode écriture sur Android
- **THEN** l'app uploade `cave.db` sur Drive, conserve le lock, reste en SyncIdle, et affiche une snackbar "Cave sauvegardée sur Drive"

#### Scenario: Tap sur "Quitter" en mode écriture Android
- **WHEN** l'utilisateur tape "Quitter" en mode écriture sur Android
- **THEN** l'app affiche le dialog de confirmation "Sauvegarder et quitter ?" (comportement inchangé)

#### Scenario: Échec de la sauvegarde
- **WHEN** l'upload échoue (perte réseau) lors d'un "Sauvegarder"
- **THEN** l'app affiche un message d'erreur et reste en mode écriture (lock toujours détenu, SyncError)

---

## REMOVED Requirements (crash recovery Android)

### Requirement: Crash recovery Android — retour en lecture seule après résolution
**Reason**: Après résolution du crash recovery, Android passe désormais en SyncIdle (mode écriture, lock conservé) comme Windows, pas en SyncReadOnly.
**Migration**: `resolveOwnLockWithUpload()` et `resolveOwnLockWithDownload()` suppriment leurs branches `Platform.isAndroid` qui unlockaient et allaient en SyncReadOnly.
