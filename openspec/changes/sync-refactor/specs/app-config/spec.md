## MODIFIED Requirements

### Requirement: Wizard de premier lancement
L'application SHALL afficher un wizard guidé lors du premier lancement (ou en l'absence de configuration). Le wizard SHALL permettre de choisir le mode de déploiement, configurer le chemin `cave.db` (Mode 1) ou initier la connexion Google Drive (Mode 2), puis créer ou synchroniser la base.

#### Scenario: Sélection Mode 1
- **WHEN** l'utilisateur sélectionne "PC seul (local)" dans le wizard
- **THEN** le wizard affiche un champ de saisie du chemin + bouton "Parcourir" pour choisir un dossier

#### Scenario: Sélection Mode 2
- **WHEN** l'utilisateur sélectionne "PC + Android (Google Drive)" dans le wizard
- **THEN** le wizard affiche les instructions de connexion Google et un bouton "Se connecter avec Google"

#### Scenario: Sélection Mode 3
- **WHEN** l'utilisateur sélectionne "Mobile seul" dans le wizard
- **THEN** le wizard affiche le message "Non disponible dans cette version" et empêche de continuer

#### Scenario: Confirmation de la configuration Mode 1
- **WHEN** l'utilisateur valide un chemin existant et confirme
- **THEN** la config est persistée dans SharedPreferences, `cave.db` est créé si absent, et l'app navigue vers l'écran principal

#### Scenario: Chemin invalide
- **WHEN** l'utilisateur saisit un chemin vers un dossier inexistant et confirme
- **THEN** le wizard affiche un message d'erreur et reste ouvert

#### Scenario: Confirmation de la configuration Mode 2
- **WHEN** l'utilisateur s'est connecté avec Google et confirme
- **THEN** la config est persistée (mode = 'drive'), `syncOnStartup()` est appelé, et l'app navigue vers l'écran principal après la sync

---

### Requirement: Lecture de la configuration au démarrage
L'application SHALL détecter la configuration existante à chaque démarrage en consultant deux sources dans l'ordre : (1) fichier `.env` à côté de l'exécutable (Windows uniquement), (2) SharedPreferences. Si une configuration valide est trouvée, l'application SHALL l'utiliser directement sans afficher le wizard. En Mode 2, l'app SHALL appeler `syncOnStartup()` après chargement de la config.

#### Scenario: Config trouvée en Mode 1
- **WHEN** l'app démarre et qu'une config valide Mode 1 est stockée dans SharedPreferences
- **THEN** l'app charge la config silencieusement et navigue vers l'écran principal

#### Scenario: Config trouvée en Mode 2
- **WHEN** l'app démarre et qu'une config valide Mode 2 (drive) est stockée dans SharedPreferences
- **THEN** l'app charge la config, appelle `syncOnStartup()` (qui peut afficher un dialog), puis navigue vers l'écran principal

#### Scenario: Fichier .env présent sur Windows
- **WHEN** l'app démarre sur Windows et qu'un fichier `.env` valide existe à côté de l'exécutable
- **THEN** l'app lit `STORAGE_MODE` et `LOCAL_DB_PATH`, persiste dans SharedPreferences, et navigue vers l'écran principal

#### Scenario: Aucune configuration trouvée
- **WHEN** l'app démarre et qu'aucune config valide n'existe (ni `.env`, ni SharedPreferences)
- **THEN** l'app affiche le wizard de premier lancement
