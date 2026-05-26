## Why

Les credentials OAuth de l'application (App Key Dropbox, Client ID Google Drive) ne sont pas bundlés dans les packages de distribution (Windows installer, Linux .deb, AppImage, Android APK). L'utilisateur final obtient une app qui ne peut pas s'authentifier en Mode 2 sans manipulation manuelle — voire, sur Android, doit saisir lui-même l'App Key Dropbox dans un champ texte du wizard. Un app distribuée doit fonctionner directement à l'installation, sans aucune intervention post-install.

## What Changes

- **Linux .deb** : `build_linux.sh` copie `google_desktop_secrets.json` et `dropbox_desktop_secrets.json` depuis la racine projet dans `/usr/local/lib/cavea/` (à côté de l'exécutable réel)
- **Linux AppImage** : même script copie les deux fichiers à la racine de l'AppDir (à côté de l'AppRun, là où `Platform.resolvedExecutable` les trouvera)
- **Windows installer** : `cavea.iss` ajoute une entrée `[Files]` explicite pour les deux fichiers JSON secrets, les copiant dans `{app}\`
- **Android Dropbox** : suppression du champ "App Key" dans le wizard — l'App Key est bundlée comme Flutter asset (`assets/secrets/dropbox_app_key.txt`) et lue au démarrage ; `saveAndroidAppKey` alimentée automatiquement sans saisie utilisateur
- **Android Google Drive** : aucun changement — `google-services.json` est déjà géré par le build system Android à la compilation

## Capabilities

### New Capabilities
- `oauth-credentials-bundling` : règles de bundling des credentials OAuth desktop (Windows + Linux) et Android dans les packages de distribution

### Modified Capabilities
- `linux-packaging` : le script de build doit inclure les fichiers secrets dans le paquet
- `windows-installer` : l'installateur Inno Setup doit inclure les fichiers secrets
- `storage-provider-selection` : sur Android, l'App Key Dropbox n'est plus saisie par l'utilisateur — elle est fournie par l'app

## Impact

- `scripts/build_linux.sh` : ajout de copies conditionnelles (si le fichier existe à la racine du projet)
- `windows/packaging/cavea.iss` : nouvelles entrées `[Files]`
- `assets/secrets/dropbox_app_key.txt` : nouveau fichier asset (gitignored)
- `pubspec.yaml` : déclaration de l'asset `assets/secrets/`
- `lib/features/setup/setup_screen.dart` : retrait du champ App Key Android
- `lib/features/setup/setup_controller.dart` : lecture de l'asset au lieu de la saisie
- `lib/features/settings/settings_screen.dart` : retrait du champ App Key Android éventuel
- `.gitignore` : ajout de `assets/secrets/`

## Non-goals

- Chiffrement des credentials dans les packages (les App Keys OAuth desktop sont semi-publiques par nature — tout client OAuth embarque son client_id)
- Rotation automatique des credentials
- Mécanisme de mise à jour des credentials sans re-livrer l'app
- Gestion de `google-services.json` Android (déjà correctement géré par le build system)
