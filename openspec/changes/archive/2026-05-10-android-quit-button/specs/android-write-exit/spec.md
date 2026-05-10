## ADDED Requirements

### Requirement: Bouton Quitter en mode écriture Android
En mode écriture sur Android (Mode 2), l'application SHALL afficher un bouton "Quitter" (`exit_to_app`) dans la zone sync de `_MobileBar`. Ce bouton SHALL d'abord demander confirmation, puis uploader `cave.db` sur Drive, libérer le lock et fermer le process Android. Il SHALL être visible uniquement quand `!isReadOnly && isAndroid && syncService.isActive`.

#### Scenario: Tap sur "Quitter" en mode écriture
- **WHEN** l'utilisateur tape le bouton "Quitter" en mode écriture Android (Mode 2)
- **THEN** un dialog de confirmation s'ouvre : "Sauvegarder et quitter ? Vos modifications seront envoyées sur Drive et le verrou libéré." avec les boutons "Annuler" et "Quitter"

#### Scenario: Confirmation de la fermeture
- **WHEN** l'utilisateur confirme dans le dialog de fermeture
- **THEN** l'app affiche l'overlay "Sauvegarde en cours…" (état SyncExiting), uploade `cave.db` sur Drive, supprime le lock, puis ferme le process Android

#### Scenario: Annulation de la fermeture
- **WHEN** l'utilisateur appuie sur "Annuler" dans le dialog de fermeture
- **THEN** le dialog se ferme, l'app reste en mode écriture, aucune modification n'est effectuée

#### Scenario: Échec de l'upload lors du Quitter
- **WHEN** l'upload ou la suppression du lock échoue pendant la fermeture (perte réseau)
- **THEN** l'app affiche une erreur et reste ouverte en mode écriture (le process ne se ferme pas)

#### Scenario: Bouton absent hors mode écriture
- **WHEN** l'app Android est en lecture seule (SyncReadOnly) ou en Mode 1 (local)
- **THEN** le bouton "Quitter" n'est pas affiché
