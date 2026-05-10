## MODIFIED Requirements

### Requirement: Libération manuelle sur Android
En mode écriture sur Android (Mode 2), l'application SHALL afficher un bouton "Sauvegarder" permettant d'uploader `cave.db` sur Drive **sans** relâcher le lock ni quitter le mode écriture. L'utilisateur reste en SyncIdle et peut continuer à modifier la cave.

#### Scenario: Tap sur "Sauvegarder"
- **WHEN** l'utilisateur tape "Sauvegarder" en mode écriture sur Android
- **THEN** l'app uploade `cave.db` sur Drive, conserve le lock, reste en SyncIdle, et affiche une snackbar "Cave sauvegardée sur Drive"

#### Scenario: Échec de la sauvegarde
- **WHEN** l'upload échoue (perte réseau)
- **THEN** l'app affiche un message d'erreur et reste en mode écriture (lock toujours détenu, SyncError puis retour SyncIdle)
