## MODIFIED Requirements

### Requirement: Wizard de premier lancement
L'application SHALL afficher un wizard guidé lors du premier lancement (ou en l'absence de configuration). Le wizard SHALL permettre de choisir le mode de déploiement, configurer le chemin `cave.db` (Mode 1) ou s'authentifier sur Google Drive (Mode 2), puis créer la base si elle n'existe pas.

#### Scenario: Sélection Mode 1
- **WHEN** l'utilisateur sélectionne "PC seul (local)" dans le wizard
- **THEN** le wizard affiche un champ de saisie du chemin + bouton "Parcourir" pour choisir un dossier

#### Scenario: Sélection Mode 2 sur PC
- **WHEN** l'utilisateur sélectionne "Mode partagé (Google Drive)" dans le wizard sur PC
- **THEN** le wizard affiche le flux OAuth Desktop + saisie du dossier local cache

#### Scenario: Sélection Mode 2 sur Android
- **WHEN** l'utilisateur sélectionne "Mode partagé (Google Drive)" dans le wizard sur Android
- **THEN** le wizard affiche le flux OAuth Android ; le chemin local est automatiquement le stockage privé de l'app

#### Scenario: Confirmation de la configuration Mode 1
- **WHEN** l'utilisateur valide un chemin existant et confirme
- **THEN** la config est persistée dans SharedPreferences, `cave.db` est créé si absent, et l'app navigue vers l'écran principal

#### Scenario: Chemin invalide
- **WHEN** l'utilisateur saisit un chemin vers un dossier inexistant et confirme
- **THEN** le wizard affiche un message d'erreur et reste ouvert
