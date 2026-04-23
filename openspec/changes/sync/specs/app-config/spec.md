## MODIFIED Requirements

### Requirement: Wizard de premier lancement
L'application SHALL afficher un wizard guidé lors du premier lancement (ou en l'absence de configuration). Le wizard SHALL permettre de choisir le mode de déploiement, configurer le chemin `cave.db` (Mode 1) ou déclencher l'authentification Google Drive (Mode 2), puis créer ou télécharger la base si elle n'existe pas localement.

#### Scenario: Sélection Mode 1
- **WHEN** l'utilisateur sélectionne "PC seul (local)" dans le wizard
- **THEN** le wizard affiche un champ de saisie du chemin + bouton "Parcourir" pour choisir un dossier

#### Scenario: Sélection Mode 2 dans le wizard
- **WHEN** l'utilisateur sélectionne "PC + Android (Google Drive)" dans le wizard
- **THEN** le wizard affiche le bouton "Connecter Google Drive" déclenchant le flux OAuth de `DriveStorageAdapter`

#### Scenario: OAuth réussi en wizard Mode 2
- **WHEN** l'utilisateur complète l'authentification Google Drive depuis le wizard
- **THEN** le wizard propose "Créer une nouvelle cave" ou "Télécharger cave.db existante depuis Drive" ; à la confirmation, la config est persistée en Mode 2 et l'app navigue vers l'écran principal

#### Scenario: Confirmation de la configuration Mode 1
- **WHEN** l'utilisateur valide un chemin existant et confirme
- **THEN** la config est persistée dans SharedPreferences, `cave.db` est créé si absent, et l'app navigue vers l'écran principal

#### Scenario: Chemin invalide (Mode 1)
- **WHEN** l'utilisateur saisit un chemin vers un dossier inexistant et confirme
- **THEN** le wizard affiche un message d'erreur et reste ouvert

---

### Requirement: Activation Mode 2 depuis les Settings
L'application SHALL permettre à l'utilisateur de basculer en Mode 2 (Google Drive) depuis les Settings sans passer par le wizard. La bascule SHALL déclencher le flux OAuth puis proposer la migration du `cave.db` local vers Drive.

#### Scenario: Bascule Mode 1 → Mode 2 depuis Settings
- **WHEN** l'utilisateur clique "Activer Google Drive" dans les Settings et qu'il est en Mode 1
- **THEN** le flux OAuth `DriveStorageAdapter` est déclenché ; en cas de succès, un dialogue propose "Envoyer votre cave.db actuel vers Google Drive ?" avec les options "Migrer" et "Annuler"

#### Scenario: Migration one-shot acceptée
- **WHEN** l'utilisateur confirme "Migrer" après l'OAuth
- **THEN** `DriveStorageAdapter.uploadDb()` est appelé avec le `cave.db` local, `SharedPreferences` est mis à jour en Mode 2, et `SyncService` devient actif immédiatement

#### Scenario: Migration annulée
- **WHEN** l'utilisateur clique "Annuler" après l'OAuth
- **THEN** l'application reste en Mode 1, aucun fichier Drive n'est créé, le token OAuth est révoqué

#### Scenario: Bascule Mode 2 → Mode 1 depuis Settings
- **WHEN** l'utilisateur clique "Revenir en Mode 1 (local)" dans les Settings
- **THEN** `SharedPreferences` est mis à jour en Mode 1, `SyncService` devient inactif, le `cave.db` local est conservé tel quel (aucun fichier Drive n'est supprimé)
