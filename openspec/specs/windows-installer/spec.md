## ADDED Requirements

### Requirement: Script Inno Setup produisant un installateur Windows autonome
Le projet SHALL contenir un script Inno Setup à `windows/packaging/cavea.iss` produisant un fichier `Cavea-{version}-windows-setup.exe` incluant l'intégralité du dossier `build\windows\x64\runner\Release\`.

L'installateur SHALL :
- Requérir Windows 10 version 1809 (Build 17763) minimum via `MinVersion`
- Installer dans `{autopf}\Cavea` (Program Files)
- Créer un raccourci dans le menu Démarrer et sur le Bureau
- Afficher la licence Apache 2.0 pendant l'installation
- Supporter la mise à jour silencieuse via un AppId GUID stable (`{6F3C2A1B-D4E5-4F8A-9B0C-1D2E3F4A5B6C}`)
- Inclure une entrée de désinstallation dans "Ajout/Suppression de programmes"
- Proposer (décoché par défaut) de lancer Cavea à la fin de l'installation

#### Scenario: Installation standard
- **WHEN** l'utilisateur exécute `Cavea-v1.0.0-windows-setup.exe` sur Windows 10 ou 11
- **THEN** l'installateur copie les fichiers dans Program Files, crée les raccourcis, et l'app est disponible dans le menu Démarrer

#### Scenario: Mise à jour depuis une version précédente
- **WHEN** l'utilisateur exécute un nouvel installateur alors que Cavea est déjà installé
- **THEN** Windows reconnaît la mise à jour via l'AppId GUID et propose de remplacer l'installation existante sans laisser de résidus

#### Scenario: Désinstallation
- **WHEN** l'utilisateur désinstalle Cavea depuis "Ajout/Suppression de programmes"
- **THEN** tous les fichiers de l'installation sont supprimés (cave.db non touché — il est stocké dans un dossier choisi par l'utilisateur)

#### Scenario: Windows trop ancien
- **WHEN** l'utilisateur tente d'installer sur Windows 7, 8, ou 10 avant 1809
- **THEN** l'installateur affiche un message d'erreur et refuse de s'installer

### Requirement: Bump de version à 1.0.0
`pubspec.yaml` SHALL indiquer `version: 1.0.0+1`. La clé `aboutVersion` dans `app_fr.arb` et `app_en.arb` SHALL afficher "Version 1.0.0".

#### Scenario: Version affichée dans l'app
- **WHEN** l'utilisateur ouvre le dialog "À propos" dans les Paramètres
- **THEN** la version affichée est "Version 1.0.0"
