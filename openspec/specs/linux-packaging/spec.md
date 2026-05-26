### Requirement: Script de build AppImage
Un script `scripts/build_linux.sh` SHALL produire un AppImage auto-contenu à partir du build Flutter Linux Release. L'AppImage SHALL inclure l'exécutable, les bibliothèques Flutter, les données (icône, `.desktop`), et les fichiers credentials OAuth s'ils sont présents à la racine du projet.

#### Scenario: Exécution du script de build AppImage
- **WHEN** `scripts/build_linux.sh appimage` est exécuté après `flutter build linux --release`
- **THEN** un fichier `build/linux/Cavea-x86_64.AppImage` est produit, exécutable sans installation sur toute distribution Linux x86_64

#### Scenario: AppImage inclut les credentials OAuth
- **WHEN** `google_desktop_secrets.json` et/ou `dropbox_desktop_secrets.json` sont présents à la racine du projet au moment du build
- **THEN** le script les copie à la racine de l'AppDir et l'app les trouve via `File(Platform.resolvedExecutable).parent.path` au démarrage

#### Scenario: AppImage buildée sans credentials
- **WHEN** les fichiers JSON secrets sont absents à la racine du projet
- **THEN** le script affiche un warning et produit quand même l'AppImage (Mode 1 fonctionnel, Mode 2 non disponible)

### Requirement: Script de build paquet .deb
Le script `scripts/build_linux.sh` SHALL également produire un paquet `.deb` installable via `dpkg -i` sur Debian/Ubuntu. Le paquet SHALL installer l'app dans `/usr/local/lib/cavea/` avec les credentials OAuth, et créer un wrapper dans `/usr/local/bin/cavea`.

#### Scenario: Exécution du script de build .deb
- **WHEN** `scripts/build_linux.sh deb` est exécuté après `flutter build linux --release`
- **THEN** un fichier `build/linux/cavea_*.deb` est produit

#### Scenario: .deb inclut les credentials OAuth
- **WHEN** `google_desktop_secrets.json` et/ou `dropbox_desktop_secrets.json` sont présents à la racine du projet au moment du build
- **THEN** le script les copie dans `/usr/local/lib/cavea/` dans le paquet et l'app les trouve via `File(Platform.resolvedExecutable).parent.path` après installation

#### Scenario: Installation et lancement depuis le menu
- **WHEN** `sudo dpkg -i cavea_*.deb` est exécuté puis que l'app est lancée depuis le menu applications
- **THEN** l'app démarre normalement en Mode 1 ou avec le wizard selon la configuration

### Requirement: Fichier .desktop et icône
L'AppImage et le paquet .deb SHALL inclure un fichier `.desktop` conforme à la spécification freedesktop.org, avec le nom "Cavea", la catégorie "Utility", et une icône PNG 512×512.

#### Scenario: Entrée menu applications après installation .deb
- **WHEN** le paquet .deb est installé sur Ubuntu 22.04+
- **THEN** "Cavea" apparaît dans le menu Applications avec l'icône correcte
