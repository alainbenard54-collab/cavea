### Requirement: Mode 1 fonctionnel sur Linux
L'app SHALL démarrer en Mode 1 sur Linux : accès direct `dart:io` à `cave.db`, file picker dossier via `file_picker`, layout desktop (`_DesktopRail`), cycle de vie identique à Windows (`didRequestAppExit` intercepte la fermeture propre).

#### Scenario: Démarrage Mode 1 Linux — wizard premier lancement
- **WHEN** l'app démarre sur Linux sans configuration existante
- **THEN** le wizard affiche les options Mode 1 (local) et Mode 2 (partagé), identiques à Windows

#### Scenario: Démarrage Mode 1 Linux — fichier .env
- **WHEN** un fichier `.env` contenant `STORAGE_MODE=local` et `LOCAL_DB_PATH` est présent à côté de l'exécutable Linux
- **THEN** l'app charge cette configuration sans afficher le wizard

#### Scenario: Sélection dossier cave.db sur Linux
- **WHEN** l'utilisateur appuie sur "Parcourir" dans le wizard ou Settings
- **THEN** un file picker natif Linux s'ouvre pour sélectionner un dossier, et le chemin choisi est persisté dans SharedPreferences

#### Scenario: Layout desktop sur Linux
- **WHEN** l'app est ouverte sur Linux en fenêtre ≥ 600 dp de large
- **THEN** `_DesktopRail` (NavigationRail) est utilisé — identique à Windows, jamais `_MobileBar`

### Requirement: Mode 2 fonctionnel sur Linux (Drive et Dropbox)
L'app SHALL prendre en charge le Mode 2 sur Linux via OAuth loopback. Les secrets OAuth SHALL être chargés depuis un fichier JSON à côté de l'exécutable (même convention que Windows). Les tokens SHALL être persistés dans `flutter_secure_storage` via le backend libsecret (GNOME Keyring / KDE Wallet).

#### Scenario: Authentification Drive sur Linux — premier lancement
- **WHEN** l'utilisateur sélectionne Google Drive dans le wizard sur Linux et que `google_desktop_secrets.json` est présent à côté de l'exécutable
- **THEN** le navigateur s'ouvre sur la page Google OAuth, `clientViaUserConsent` écoute la réponse sur un port loopback libre, et le refresh token est sauvegardé dans libsecret

#### Scenario: Authentification Dropbox sur Linux — premier lancement
- **WHEN** l'utilisateur sélectionne Dropbox dans le wizard sur Linux et que `dropbox_desktop_secrets.json` est présent à côté de l'exécutable
- **THEN** le navigateur s'ouvre sur la page Dropbox OAuth PKCE, `HttpServer` écoute la réponse sur un port loopback libre, et le refresh token est sauvegardé dans libsecret

#### Scenario: Reprise d'une session Linux — token existant
- **WHEN** l'app démarre en Mode 2 sur Linux et qu'un refresh token est déjà présent dans libsecret
- **THEN** la ré-authentification s'effectue silencieusement sans ouvrir de navigateur

#### Scenario: Secret JSON manquant sur Linux
- **WHEN** l'app tente de s'authentifier en Mode 2 sur Linux et qu'aucun fichier JSON de secrets n'est trouvé
- **THEN** une Exception est levée et le wizard affiche un message d'erreur explicite

### Requirement: flutter_secure_storage opérationnel sur Linux
`FlutterSecureStorage` SHALL utiliser `LinuxOptions()` sur Linux, stockant les tokens dans GNOME Keyring ou KDE Wallet via `libsecret`. La dépendance native `libsecret-1-dev` SHALL figurer dans `linux/CMakeLists.txt`.

#### Scenario: Stockage d'un token sur Linux
- **WHEN** un refresh token est écrit via `_secureStorage.write(key: ..., value: ...)` sur Linux
- **THEN** le token est persisté dans le keyring système Linux (libsecret), pas dans un fichier texte

#### Scenario: Lecture d'un token Linux absent
- **WHEN** `_secureStorage.read(key: ...)` est appelé sur Linux et qu'aucun token n'a été enregistré
- **THEN** la valeur retournée est `null` — comportement identique à Windows
