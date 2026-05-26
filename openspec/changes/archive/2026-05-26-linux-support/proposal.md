## Why

L'app fonctionne sur Windows et Android ; Linux desktop est la prochaine cible V1. Flutter supporte Linux nativement, et la quasi-totalité du code est déjà cross-platform — il reste à activer la plateforme, adapter quelques gardes `Platform.isWindows`, et produire des paquets AppImage/.deb distribuables.

## What Changes

- Activer la cible Flutter Linux (`linux/` scaffold généré par `flutter create --platforms=linux .`)
- Étendre les gardes `Platform.isWindows` à Linux là où le comportement desktop s'applique aussi à Linux : chargement `.env`, `desktopSecretsPath` (Drive + Dropbox), `FlutterSecureStorage` avec `LinuxOptions`
- Ajouter la dépendance native `libsecret-1-dev` dans `linux/CMakeLists.txt` pour `flutter_secure_storage`
- Scripts / workflow de packaging AppImage et .deb (post-build)
- Mise à jour CLAUDE.md et ARCHITECTURE.md : Linux = Mode 1 ✅, Mode 2 ✅

## Capabilities

### New Capabilities

- `linux-platform`: activation Flutter Linux + adaptations gardes platform (Mode 1 et Mode 2 fonctionnels, layout desktop via `_DesktopRail`, cycle de vie identique à Windows)
- `linux-packaging`: scripts de build AppImage et .deb à partir du build Flutter Linux Release

### Modified Capabilities

- `storage-provider-selection` : `desktopSecretsPath` étendu à Linux dans les deux adapters

## Impact

**Fichiers modifiés :**
- `linux/` — nouveau répertoire scaffold (généré par Flutter toolchain, à committer)
- `linux/CMakeLists.txt` — ajouter `pkg_check_modules(LIBSECRET libsecret-1)` et link pour `flutter_secure_storage`
- `lib/services/drive_storage_adapter.dart` — `desktopSecretsPath` : `!Platform.isWindows` → `(!Platform.isWindows && !Platform.isLinux)` ; `FlutterSecureStorage` : ajouter `lOptions: LinuxOptions()`
- `lib/services/dropbox_storage_adapter.dart` — idem
- `lib/core/config_service.dart` — `.env` loading : `Platform.isWindows` → `Platform.isWindows || Platform.isLinux`
- `scripts/build_linux.sh` — nouveau script AppImage + .deb
- `CLAUDE.md`, `ARCHITECTURE.md` — Linux marqué opérationnel

**Dépendances systèmes (VM utilisateur) :**
- `libsecret-1-dev`, `clang`, `cmake`, `ninja-build`, `libgtk-3-dev`, `pkg-config`

**Aucun changement sur Windows ni Android.**

## Non-goals

- Support macOS ou iOS
- Mode 3 (Android seul) sur Linux
- CI/CD automatisée (GitHub Actions) pour la livraison des paquets — hors scope V1
- Distribution via Snap / Flatpak
