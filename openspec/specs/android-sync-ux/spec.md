## ADDED Requirements

### Requirement: Démarrage Android Mode 2 en lecture seule
Sur Android en Mode 2, si aucun lock tiers n'est détecté et que le lock ne nous appartient pas, l'application SHALL télécharger `cave.db` depuis Drive et ouvrir en mode lecture seule (SyncReadOnly) sans acquérir le lock.

#### Scenario: Démarrage Android lock absent
- **WHEN** l'app Android démarre en Mode 2 et qu'aucun lock n'est présent sur Drive
- **THEN** l'app télécharge `cave.db`, ouvre la base en lecture seule, et affiche l'indicateur cadenas ambre

#### Scenario: Démarrage Android lock à nous (crash recovery)
- **WHEN** l'app Android démarre en Mode 2 et que le lock appartient à cet appareil
- **THEN** l'app affiche le dialog "Session précédente non terminée" avec les choix "Reprendre et envoyer mes données" et "Récupérer depuis Drive"

#### Scenario: Démarrage Android lock tiers
- **WHEN** l'app Android démarre en Mode 2 et que le lock appartient à un autre appareil
- **THEN** l'app affiche le dialog existant "Cave utilisée sur un autre appareil" (lecture seule ou quitter)

---

### Requirement: Prise de main explicite sur Android
En mode lecture seule sur Android (Mode 2), l'application SHALL afficher un bouton "Prendre la main" permettant à l'utilisateur d'acquérir le lock et de passer en mode écriture.

#### Scenario: Tap sur "Prendre la main"
- **WHEN** l'utilisateur tape "Prendre la main" en mode lecture seule sur Android
- **THEN** l'app affiche un dialog de confirmation indiquant que la sauvegarde et la libération manuelle sont requises avant de quitter

#### Scenario: Confirmation prise de main
- **WHEN** l'utilisateur confirme dans le dialog de prise de main
- **THEN** l'app acquiert le lock sur Drive, passe en mode écriture (SyncIdle), et affiche l'indicateur cadenas vert

#### Scenario: Lock tiers détecté à la prise de main
- **WHEN** l'utilisateur tente de prendre la main mais un autre appareil a acquis le lock entre-temps
- **THEN** l'app affiche un message d'erreur "Cave utilisée par un autre appareil" et reste en lecture seule

---

### Requirement: Libération manuelle sur Android
En mode écriture sur Android (Mode 2), l'application SHALL afficher un bouton proéminent "Sauvegarder et libérer" permettant d'uploader `cave.db` sur Drive, de supprimer le lock, et de revenir en lecture seule.

#### Scenario: Tap sur "Sauvegarder et libérer"
- **WHEN** l'utilisateur tape "Sauvegarder et libérer" en mode écriture sur Android
- **THEN** l'app uploade `cave.db` sur Drive, supprime le lock, repasse en SyncReadOnly, et affiche une snackbar "Cave sauvegardée et verrou libéré"

#### Scenario: Échec de la libération
- **WHEN** l'upload ou la suppression du lock échoue (perte réseau)
- **THEN** l'app affiche un message d'erreur et conserve le mode écriture (lock toujours détenu)
