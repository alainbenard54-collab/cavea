### Requirement: Credentials OAuth bundlés dans tout package de distribution
Les credentials OAuth de l'application (`google_desktop_secrets.json`, `dropbox_desktop_secrets.json` sur desktop ; `assets/secrets/dropbox_desktop_secrets.json` sur Android) SHALL être inclus dans chaque package de distribution. Un utilisateur ayant installé Cavea SHALL pouvoir activer le Mode 2 sans aucune manipulation post-install.

#### Scenario: Installation Windows — credentials présents
- **WHEN** l'utilisateur installe Cavea via le setup Windows et tente d'activer le Mode 2
- **THEN** l'app trouve les fichiers JSON secrets dans `{app}\` et l'authentification OAuth fonctionne sans message d'erreur

#### Scenario: Installation Linux .deb — credentials présents
- **WHEN** l'utilisateur installe `cavea_*.deb` et tente d'activer le Mode 2
- **THEN** l'app trouve les fichiers JSON secrets dans `/usr/local/lib/cavea/` et l'authentification OAuth fonctionne sans message d'erreur

#### Scenario: Installation Linux AppImage — credentials présents
- **WHEN** l'utilisateur lance le `.AppImage` et tente d'activer le Mode 2
- **THEN** l'app trouve les fichiers JSON secrets à côté du `.AppImage` et l'authentification OAuth fonctionne sans message d'erreur

#### Scenario: Android APK — App Key Dropbox bundlée
- **WHEN** l'utilisateur installe l'APK et sélectionne Dropbox dans le wizard Mode 2
- **THEN** l'app lit l'App Key depuis l'asset `assets/secrets/dropbox_desktop_secrets.json` et déclenche le flow PKCE sans demander de saisie à l'utilisateur

### Requirement: Build sans credentials — comportement non bloquant
Si les fichiers credentials sont absents au moment du build (ex. CI de PR), le script de packaging SHALL produire le package sans erreur fatale, en affichant un warning. L'app résultante ne pourra pas s'authentifier en Mode 2 mais démarrera normalement en Mode 1.

#### Scenario: Build Linux sans fichiers secrets
- **WHEN** `build_linux.sh` est exécuté sans `google_desktop_secrets.json` ni `dropbox_desktop_secrets.json` à la racine
- **THEN** le script affiche un warning `[WARN] credentials absent` et produit quand même le package

#### Scenario: Build Windows sans fichiers secrets
- **WHEN** Inno Setup compile `cavea.iss` sans les fichiers JSON secrets présents
- **THEN** le flag `skipifsourcedoesntexist` permet à l'installateur d'être produit sans erreur

#### Scenario: Android sans asset dropbox secrets
- **WHEN** l'APK est buildé sans `assets/secrets/dropbox_desktop_secrets.json` et que l'utilisateur tente d'activer Dropbox Mode 2
- **THEN** l'app affiche un message d'erreur clair ("App Key Dropbox manquante — build de développement") plutôt qu'un crash
