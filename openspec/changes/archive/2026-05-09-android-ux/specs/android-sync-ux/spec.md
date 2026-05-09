## MODIFIED Requirements

### Requirement: Prise de main explicite sur Android
En mode lecture seule sur Android (Mode 2), l'application SHALL afficher un bouton "Prendre la main" permettant à l'utilisateur d'acquérir le lock et de passer en mode écriture. En cas d'échec de l'acquisition, l'application SHALL revenir immédiatement à l'état `SyncReadOnly` et proposer un dialog de récupération.

#### Scenario: Tap sur "Prendre la main" Android
- **WHEN** l'utilisateur tape "Prendre la main" en mode lecture seule sur Android
- **THEN** l'app affiche un dialog de confirmation indiquant que la sauvegarde et la libération manuelle sont requises avant de quitter

#### Scenario: Confirmation prise de main
- **WHEN** l'utilisateur confirme dans le dialog de prise de main
- **THEN** l'app tente d'acquérir le lock sur Drive, passe en mode écriture (SyncIdle) si succès, et affiche l'indicateur cadenas vert

#### Scenario: Échec de la prise de main (réseau ou lock tiers)
- **WHEN** `acquireLock()` échoue (SyncStarting→SyncError)
- **THEN** l'app appelle `resetToReadOnly()` immédiatement, revient à `SyncReadOnly`, le bouton "Prendre la main" reste visible, et affiche le dialog "Impossible de prendre la main" avec les options Réessayer et Rester en lecture seule

#### Scenario: Lock tiers détecté à la prise de main
- **WHEN** l'utilisateur tente de prendre la main mais un autre appareil détient le lock
- **THEN** l'app reste en lecture seule et affiche un message d'erreur "Cave utilisée par un autre appareil"

---

### Requirement: Bouton "Prendre la main" sur Windows
En mode lecture seule sur Windows (Mode 2), `_DesktopRail` SHALL afficher un bouton `TextButton.icon("Prendre la main")` vert permettant d'acquérir le lock. Le dialog affiché SHALL mentionner la fermeture automatique (libération du lock à la fermeture) et le bouton Synchroniser.

#### Scenario: Bouton "Prendre la main" visible sur Windows
- **WHEN** l'état sync est `SyncReadOnly` sur Windows
- **THEN** `_DesktopRail` affiche un bouton "Prendre la main" vert en plus de l'indicateur cadenas

#### Scenario: Dialog "Prendre la main" adapté Windows
- **WHEN** l'utilisateur tape "Prendre la main" sur Windows
- **THEN** le dialog mentionne que le lock sera libéré automatiquement à la fermeture de l'application et que le bouton Synchroniser permet une sync manuelle

#### Scenario: Dialog "Prendre la main" adapté Android
- **WHEN** l'utilisateur tape "Prendre la main" sur Android
- **THEN** le dialog mentionne que la libération manuelle est requise avant de quitter (bouton "Sauvegarder et libérer")

#### Scenario: Échec "Prendre la main" sur Windows
- **WHEN** `acquireLock()` échoue sur Windows
- **THEN** l'app revient à `SyncReadOnly`, le bouton "Prendre la main" reste visible, le dialog "Impossible de prendre la main" s'affiche avec Réessayer / Rester en lecture seule
