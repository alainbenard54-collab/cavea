## MODIFIED Requirements

### Requirement: Wizard de premier lancement
L'application SHALL afficher un wizard guidé lors du premier lancement (ou en l'absence de configuration). Le wizard SHALL permettre de choisir le mode de déploiement, configurer le chemin `cave.db` (Mode 1) ou choisir le fournisseur cloud puis initier la connexion (Mode 2), puis créer ou synchroniser la base.

#### Scenario: Sélection Mode 1
- **WHEN** l'utilisateur sélectionne "PC seul (local)" dans le wizard
- **THEN** le wizard affiche un champ de saisie du chemin + bouton "Parcourir" pour choisir un dossier

#### Scenario: Sélection Mode 2
- **WHEN** l'utilisateur sélectionne "PC + Android (Partagé)" dans le wizard
- **THEN** le wizard affiche une étape de sélection du fournisseur cloud : "Google Drive" ou "Dropbox"

#### Scenario: Sélection Mode 3
- **WHEN** l'utilisateur sélectionne "Mobile seul" dans le wizard
- **THEN** le wizard affiche le message "Non disponible dans cette version" et empêche de continuer

#### Scenario: Confirmation de la configuration Mode 1
- **WHEN** l'utilisateur valide un chemin existant et confirme
- **THEN** la config est persistée dans SharedPreferences, `cave.db` est créé si absent, et l'app navigue vers l'écran principal

#### Scenario: Chemin invalide
- **WHEN** l'utilisateur saisit un chemin vers un dossier inexistant et confirme
- **THEN** le wizard affiche un message d'erreur et reste ouvert

#### Scenario: Confirmation de la configuration Mode 2 — Google Drive
- **WHEN** l'utilisateur a choisi "Google Drive", s'est connecté avec Google, et confirme
- **THEN** la config est persistée (`storageMode = 'drive'`), `syncOnStartup()` est appelé, et l'app navigue vers l'écran principal après la sync

#### Scenario: Confirmation de la configuration Mode 2 — Dropbox
- **WHEN** l'utilisateur a choisi "Dropbox", s'est connecté avec Dropbox, et confirme
- **THEN** la config est persistée (`storageMode = 'dropbox'`), `syncOnStartup()` est appelé, et l'app navigue vers l'écran principal après la sync

---

### Requirement: Persistance de la configuration
L'application SHALL stocker la configuration (mode de déploiement, chemin `cave.db`) dans SharedPreferences. `storageMode` SHALL accepter les valeurs `'local'`, `'drive'`, et `'dropbox'`. La configuration SHALL survivre au redémarrage de l'app.

#### Scenario: Redémarrage après configuration
- **WHEN** l'app a été configurée une première fois et est relancée
- **THEN** l'app ne réaffiche pas le wizard et utilise la config précédemment persistée

#### Scenario: Config Mode 2 Dropbox trouvée
- **WHEN** l'app démarre et que `storageMode = 'dropbox'` est stocké dans SharedPreferences
- **THEN** l'app instancie `DropboxStorageAdapter`, appelle `syncOnStartup()`, et navigue vers l'écran principal
