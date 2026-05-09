## MODIFIED Requirements

### Requirement: BottomSheet d'actions rapides
L'application SHALL afficher un BottomSheet modal lors d'un clic sur une ligne de la vue stock. Ce BottomSheet SHALL proposer les actions dans l'ordre suivant : Consommer, Consulter la fiche, Déplacer, Modifier la fiche, Annuler.

#### Scenario: Ouverture du BottomSheet
- **WHEN** l'utilisateur clique sur une ligne de la liste ou du tableau stock
- **THEN** un BottomSheet s'ouvre avec le nom de la bouteille en titre et les 5 actions dans l'ordre : Consommer, Consulter la fiche, Déplacer, Modifier la fiche, Annuler

#### Scenario: Fermeture par Annuler ou swipe
- **WHEN** l'utilisateur appuie sur "Annuler" ou fait un swipe vers le bas
- **THEN** le BottomSheet se ferme sans modification

---

## ADDED Requirements

### Requirement: Action Consulter la fiche
L'application SHALL exposer une action "Consulter la fiche" dans le BottomSheet permettant d'accéder à la vue lecture seule `BottleDetailScreen`. Cette action SHALL être disponible en mode normal ET en mode `SyncReadOnly`.

#### Scenario: Clic sur Consulter la fiche (mode normal)
- **WHEN** l'utilisateur appuie sur "Consulter la fiche" depuis le BottomSheet en mode normal
- **THEN** le BottomSheet se ferme et `BottleDetailScreen` s'ouvre via la route `/bottle/:id`

#### Scenario: Clic sur Consulter la fiche (mode SyncReadOnly)
- **WHEN** l'utilisateur appuie sur "Consulter la fiche" depuis le BottomSheet en mode `SyncReadOnly`
- **THEN** le BottomSheet se ferme et `BottleDetailScreen` s'ouvre via la route `/bottle/:id`

---

### Requirement: BottomSheet en mode SyncReadOnly avec accès à la fiche
En mode `SyncReadOnly`, le BottomSheet SHALL afficher uniquement l'action "Consulter la fiche" et le bouton "Fermer". Les actions Consommer, Déplacer et Modifier la fiche SHALL rester cachées.

#### Scenario: BottomSheet SyncReadOnly
- **WHEN** le BottomSheet s'ouvre alors que `SyncService` est en état `SyncReadOnly`
- **THEN** seules les options "Consulter la fiche" et "Fermer" sont visibles ; Consommer, Déplacer et Modifier la fiche sont absentes

#### Scenario: Navigation fiche depuis SyncReadOnly
- **WHEN** l'utilisateur appuie sur "Consulter la fiche" en mode `SyncReadOnly`
- **THEN** `BottleDetailScreen` s'ouvre normalement (la lecture seule ne bloque pas la consultation)
