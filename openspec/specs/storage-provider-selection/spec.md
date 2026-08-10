## ADDED Requirements

### Requirement: Sélection du fournisseur dans le wizard Mode 2
Le wizard de premier lancement SHALL proposer une étape de sélection du fournisseur cloud (Google Drive / Dropbox) quand l'utilisateur choisit le mode "Partagé (Mode 2)". Cette étape SHALL s'afficher avant l'étape d'authentification. Le fournisseur sélectionné SHALL déterminer le flow d'authentification suivant.

#### Scenario: Sélection Google Drive dans le wizard
- **WHEN** l'utilisateur sélectionne "Google Drive" dans l'étape de sélection du fournisseur
- **THEN** le wizard affiche l'étape d'authentification Google (bouton "Se connecter avec Google") et persiste `storageMode = 'drive'` à la confirmation

#### Scenario: Sélection Dropbox dans le wizard
- **WHEN** l'utilisateur sélectionne "Dropbox" dans l'étape de sélection du fournisseur
- **THEN** le wizard affiche l'étape d'authentification Dropbox (bouton "Se connecter avec Dropbox") et persiste `storageMode = 'dropbox'` à la confirmation

### Requirement: Sélection Dropbox dans le wizard — Android
Sur Android, le wizard Mode 2 SHALL déclencher le flow Dropbox PKCE sans demander d'App Key à l'utilisateur. L'App Key SHALL être lue depuis l'asset Flutter `assets/secrets/dropbox_desktop_secrets.json` bundlé dans l'APK.

#### Scenario: Sélection Dropbox sur Android — App Key bundlée
- **WHEN** l'utilisateur sélectionne "Dropbox" dans le wizard sur Android
- **THEN** l'app lit l'App Key depuis `assets/secrets/dropbox_desktop_secrets.json` via `rootBundle`, appelle `saveAndroidAppKey()`, et déclenche le flow PKCE sans aucun champ de saisie

#### Scenario: App Key absente au build Android
- **WHEN** l'APK est buildé sans `assets/secrets/dropbox_desktop_secrets.json` et que l'utilisateur sélectionne Dropbox
- **THEN** l'app affiche une erreur explicite ("Dropbox non disponible dans cette version") sans crash

---

### Requirement: Sélection / changement de fournisseur dans Settings
L'écran Settings SHALL afficher le fournisseur cloud actif dans la section "Mode de synchronisation" quand Mode 2 est activé. Les actions "Revenir en local" et "Changer de fournisseur" SHALL être accessibles sur toutes les plateformes, y compris Android.

#### Scenario: Affichage du fournisseur actif
- **WHEN** l'écran Settings est ouvert et que `storageMode == 'drive'` ou `'dropbox'`
- **THEN** le fournisseur actif est affiché (ex. "Google Drive" ou "Dropbox") dans la section Mode de synchronisation

#### Scenario: Revenir en local depuis Android
- **WHEN** l'utilisateur Android appuie sur "Revenir en local" dans les Paramètres
- **THEN** un dialog de confirmation s'affiche, et après confirmation les tokens sont effacés, le lock est relâché et l'app passe en Mode 1

#### Scenario: Changer de fournisseur depuis Android
- **WHEN** l'utilisateur Android appuie sur "Changer de fournisseur" dans les Paramètres
- **THEN** un dialog de confirmation s'affiche, les tokens du fournisseur courant sont effacés, et le wizard de premier lancement s'affiche pour choisir un nouveau fournisseur

#### Scenario: Changer de fournisseur depuis Settings (desktop)
- **WHEN** l'utilisateur desktop appuie sur "Changer de fournisseur"
- **THEN** les tokens du fournisseur courant sont effacés de `flutter_secure_storage`, `storageMode` est réinitialisé à `'local'`, et le wizard de premier lancement s'affiche

#### Scenario: Fournisseur affiché côté Mode 1
- **WHEN** l'écran Settings est ouvert et que `storageMode == 'local'`
- **THEN** aucun fournisseur cloud n'est affiché et les boutons "Revenir en local" / "Changer de fournisseur" sont absents

---

### Requirement: Comportement Mode 2 identique quel que soit le fournisseur
`SyncService` SHALL se comporter de façon identique pour Google Drive et Dropbox : même cycle lock/download/upload au démarrage, même gestion du lock tiers (lecture seule), même bouton "Synchroniser", même indicateurs AppBar, même bouton "Quitter" Android.

#### Scenario: Démarrage Mode 2 Dropbox — lock absent, cave.db présent
- **WHEN** l'app démarre en Mode 2 Dropbox, aucun lock n'est présent sur Dropbox, et `cave.db` existe sur Dropbox
- **THEN** l'app pose le verrou, télécharge `cave.db`, passe en SyncIdle mode écriture — identique au comportement Drive

#### Scenario: Démarrage Mode 2 Dropbox — lock tiers
- **WHEN** l'app démarre en Mode 2 Dropbox et qu'un lock appartenant à un autre appareil est présent
- **THEN** l'app passe en SyncReadOnly — identique au comportement Drive

---

### Requirement: Chargement des secrets desktop sur Linux
`desktopSecretsPath` dans `DriveStorageAdapter` et `DropboxStorageAdapter` SHALL retourner un chemin valide sur Linux, en plus de Windows. La recherche SHALL s'effectuer dans le même ordre : à côté de l'exécutable (`Platform.resolvedExecutable`), puis répertoire de travail courant.

#### Scenario: Secret JSON trouvé à côté de l'exécutable Linux
- **WHEN** `google_desktop_secrets.json` est placé dans le même dossier que l'exécutable Linux
- **THEN** `DriveStorageAdapter.desktopSecretsPath` retourne ce chemin (non vide)

#### Scenario: Secret JSON trouvé à côté de l'exécutable Linux — Dropbox
- **WHEN** `dropbox_desktop_secrets.json` est placé dans le même dossier que l'exécutable Linux
- **THEN** `DropboxStorageAdapter.desktopSecretsPath` retourne ce chemin (non vide)

#### Scenario: Comportement Windows inchangé
- **WHEN** l'app tourne sur Windows
- **THEN** `desktopSecretsPath` se comporte exactement comme avant — aucune régression
