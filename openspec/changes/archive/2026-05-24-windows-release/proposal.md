## Why

Cavea V1 est complète (features, tests, documentation) mais n'est pas encore distribuable aux utilisateurs Windows — il n'existe pas d'installateur ni de pipeline de release automatisé. Cette étape finalise la chaîne de livraison pour Windows desktop (Mode 1 et Mode 2) en produisant un `.exe` d'installation via Inno Setup et en automatisant la publication via GitHub Actions.

## What Changes

- **Version bump** : `pubspec.yaml` 0.1.0+1 → 1.0.0+1 ; clé `aboutVersion` mise à jour dans les ARB fr et en
- **Script Inno Setup** : `windows/packaging/cavea.iss` — produit `Cavea-{version}-windows-setup.exe` à partir du build Flutter Release
- **Workflow GitHub Actions** : `.github/workflows/release-windows.yml` — déclenché sur push de tag `v*`, build Flutter + Inno Setup + upload Release asset
- **Texte de release** : `.github/RELEASE_TEMPLATE_WINDOWS.md` — template bilingue fr/en à coller dans la release GitHub v1.0.0

## Capabilities

### New Capabilities

- `windows-installer` : script Inno Setup produisant un installateur Windows signable, avec raccourcis bureau/menu démarrer, support désinstallation, MinVersion Windows 10 1809
- `windows-ci-release` : workflow GitHub Actions publiant automatiquement l'installateur Windows sur GitHub Releases à chaque tag `v*`

### Modified Capabilities

*(aucune — les specs existantes ne changent pas de comportement)*

## Non-goals

- Signature de code (code signing avec certificat EV) — hors V1, nécessite un certificat payant
- Distribution via Microsoft Store — hors V1
- Build Linux ou Android dans ce workflow — traités séparément
- Auto-update intégré dans l'app (Squirrel, WinSparkle) — hors V1

## Impact

- `pubspec.yaml` : bump version
- `lib/l10n/app_fr.arb`, `lib/l10n/app_en.arb` : clé `aboutVersion`
- `windows/packaging/cavea.iss` : nouveau fichier (Inno Setup)
- `.github/workflows/release-windows.yml` : nouveau fichier (GitHub Actions)
- `.github/RELEASE_TEMPLATE_WINDOWS.md` : nouveau fichier (release notes template)
- Concerne Mode 1 (PC seul) et Mode 2 (partage Drive/Dropbox) — les deux compilés dans le même exe
