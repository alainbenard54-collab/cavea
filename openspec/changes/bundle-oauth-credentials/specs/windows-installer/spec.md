## MODIFIED Requirements

### Requirement: Script Inno Setup produisant un installateur Windows autonome
Le projet SHALL contenir un script Inno Setup à `windows/packaging/cavea.iss` produisant un fichier `Cavea-{version}-windows-setup.exe` incluant l'intégralité du dossier `build\windows\x64\runner\Release\` ainsi que les fichiers credentials OAuth (`google_desktop_secrets.json`, `dropbox_desktop_secrets.json`) avec le flag `skipifsourcedoesntexist`.

L'installateur SHALL :
- Requérir Windows 10 version 1809 (Build 17763) minimum via `MinVersion`
- Installer dans `{autopf}\Cavea` (Program Files)
- Créer un raccourci dans le menu Démarrer et sur le Bureau
- Afficher la licence Apache 2.0 pendant l'installation
- Supporter la mise à jour silencieuse via un AppId GUID stable (`{6F3C2A1B-D4E5-4F8A-9B0C-1D2E3F4A5B6C}`)
- Inclure une entrée de désinstallation dans "Ajout/Suppression de programmes"
- Proposer (décoché par défaut) de lancer Cavea à la fin de l'installation

#### Scenario: Installation standard avec credentials
- **WHEN** l'utilisateur exécute `Cavea-v*-windows-setup.exe` sur Windows 10 ou 11 et que les JSON secrets étaient présents au build
- **THEN** l'installateur copie les fichiers dans Program Files incluant les JSON secrets, et l'app peut activer le Mode 2 directement

#### Scenario: Build sans credentials — installateur quand même produit
- **WHEN** Inno Setup compile `cavea.iss` sans `google_desktop_secrets.json` ni `dropbox_desktop_secrets.json` présents
- **THEN** le flag `skipifsourcedoesntexist` permet à la compilation de réussir — le Mode 2 ne fonctionnera pas mais l'app démarre

#### Scenario: Mise à jour depuis une version précédente
- **WHEN** l'utilisateur exécute un nouvel installateur alors que Cavea est déjà installé
- **THEN** Windows reconnaît la mise à jour via l'AppId GUID et remplace l'installation existante sans laisser de résidus

#### Scenario: Désinstallation
- **WHEN** l'utilisateur désinstalle Cavea depuis "Ajout/Suppression de programmes"
- **THEN** tous les fichiers de l'installation sont supprimés (cave.db non touché — il est stocké dans un dossier choisi par l'utilisateur)
