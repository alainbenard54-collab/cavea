## ADDED Requirements

### Requirement: Script de build AppImage
Un script `scripts/build_linux.sh` SHALL produire un AppImage auto-contenu à partir du build Flutter Linux Release. L'AppImage SHALL inclure l'exécutable, les bibliothèques Flutter et les données (icône, `.desktop`).

#### Scenario: Exécution du script de build AppImage
- **WHEN** `scripts/build_linux.sh appimage` est exécuté après `flutter build linux --release`
- **THEN** un fichier `build/linux/Cavea-x86_64.AppImage` est produit, exécutable sans installation sur toute distribution Linux x86_64

#### Scenario: AppImage inclut le fichier secrets
- **WHEN** `google_desktop_secrets.json` ou `dropbox_desktop_secrets.json` est copié à côté de l'AppImage
- **THEN** l'app le trouve via `File(Platform.resolvedExecutable).parent.path` (ou fallback `Directory.current`) et charge les credentials Mode 2

### Requirement: Script de build paquet .deb
Le script `scripts/build_linux.sh` SHALL également produire un paquet `.deb` installable via `dpkg -i` sur Debian/Ubuntu. Le paquet SHALL installer l'app dans `/usr/local/bin/cavea` et créer une entrée dans le menu applications.

#### Scenario: Exécution du script de build .deb
- **WHEN** `scripts/build_linux.sh deb` est exécuté après `flutter build linux --release`
- **THEN** un fichier `build/linux/cavea_1.0.0_amd64.deb` est produit

#### Scenario: Installation et lancement depuis le menu
- **WHEN** `sudo dpkg -i cavea_1.0.0_amd64.deb` est exécuté puis que l'app est lancée depuis le menu applications
- **THEN** l'app démarre normalement en Mode 1 ou avec le wizard selon la configuration

### Requirement: Fichier .desktop et icône
L'AppImage et le paquet .deb SHALL inclure un fichier `.desktop` conforme à la spécification freedesktop.org, avec le nom "Cavea", la catégorie "Utility", et une icône PNG 512×512.

#### Scenario: Entrée menu applications après installation .deb
- **WHEN** le paquet .deb est installé sur Ubuntu 22.04+
- **THEN** "Cavea" apparaît dans le menu Applications avec l'icône correcte
