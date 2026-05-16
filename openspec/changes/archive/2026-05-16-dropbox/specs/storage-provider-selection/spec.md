## ADDED Requirements

### Requirement: Sélection du fournisseur dans le wizard Mode 2
Le wizard de premier lancement SHALL proposer une étape de sélection du fournisseur cloud (Google Drive / Dropbox) quand l'utilisateur choisit le mode "Partagé (Mode 2)". Cette étape SHALL s'afficher avant l'étape d'authentification. Le fournisseur sélectionné SHALL déterminer le flow d'authentification suivant.

#### Scenario: Sélection Google Drive dans le wizard
- **WHEN** l'utilisateur sélectionne "Google Drive" dans l'étape de sélection du fournisseur
- **THEN** le wizard affiche l'étape d'authentification Google (bouton "Se connecter avec Google") et persiste `storageMode = 'drive'` à la confirmation

#### Scenario: Sélection Dropbox dans le wizard
- **WHEN** l'utilisateur sélectionne "Dropbox" dans l'étape de sélection du fournisseur
- **THEN** le wizard affiche l'étape d'authentification Dropbox (bouton "Se connecter avec Dropbox") et persiste `storageMode = 'dropbox'` à la confirmation

---

### Requirement: Sélection / changement de fournisseur dans Settings
L'écran Settings SHALL afficher le fournisseur cloud actif dans la section "Mode de synchronisation" quand Mode 2 est activé. Un bouton "Changer de fournisseur" SHALL permettre de déconnecter le fournisseur courant (effacer les tokens) et relancer le wizard pour en choisir un nouveau.

#### Scenario: Affichage du fournisseur actif
- **WHEN** l'écran Settings est ouvert et que `storageMode == 'drive'` ou `'dropbox'`
- **THEN** le fournisseur actif est affiché (ex. "Google Drive" ou "Dropbox") dans la section Mode de synchronisation

#### Scenario: Changement de fournisseur depuis Settings
- **WHEN** l'utilisateur appuie sur "Changer de fournisseur"
- **THEN** les tokens du fournisseur courant sont effacés de `flutter_secure_storage`, `storageMode` est réinitialisé à `'local'`, et le wizard de premier lancement s'affiche

#### Scenario: Fournisseur affiché côté Mode 1
- **WHEN** l'écran Settings est ouvert et que `storageMode == 'local'`
- **THEN** aucun fournisseur cloud n'est affiché et le bouton "Changer de fournisseur" est absent

---

### Requirement: Comportement Mode 2 identique quel que soit le fournisseur
`SyncService` SHALL se comporter de façon identique pour Google Drive et Dropbox : même cycle lock/download/upload au démarrage, même gestion du lock tiers (lecture seule), même bouton "Synchroniser", même indicateurs AppBar, même bouton "Quitter" Android.

#### Scenario: Démarrage Mode 2 Dropbox — lock absent, cave.db présent
- **WHEN** l'app démarre en Mode 2 Dropbox, aucun lock n'est présent sur Dropbox, et `cave.db` existe sur Dropbox
- **THEN** l'app pose le verrou, télécharge `cave.db`, passe en SyncIdle mode écriture — identique au comportement Drive

#### Scenario: Démarrage Mode 2 Dropbox — lock tiers
- **WHEN** l'app démarre en Mode 2 Dropbox et qu'un lock appartenant à un autre appareil est présent
- **THEN** l'app passe en SyncReadOnly — identique au comportement Drive
