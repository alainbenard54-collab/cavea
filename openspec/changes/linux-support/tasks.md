## 1. Activation plateforme Linux (à faire sur machine avec Flutter installé)

- [x] 1.1 Exécuter `flutter create --platforms=linux .` à la racine du projet pour générer le répertoire `linux/` (CMakeLists.txt, runner, flutter/)
- [x] 1.2 Vérifier que `flutter build linux --release` compile sans erreur sur la VM Linux ou via cross-compilation

## 2. Dépendance native libsecret (Linux uniquement)

- [x] 2.1 Dans `linux/CMakeLists.txt`, ajouter `pkg_check_modules(LIBSECRET REQUIRED libsecret-1)` et les directives `target_include_directories` / `target_link_libraries` pour `flutter_secure_storage` — Non nécessaire : `flutter_secure_storage_linux` gère libsecret via son propre CMakeLists.txt ; le build 1.2 a réussi sans modification manuelle
- [x] 2.2 Vérifier que `flutter build linux --release` réussit après l'ajout (libsecret-1-dev installé sur la VM) — Validé par 1.2

## 3. Corrections gardes Platform dans le code Dart

- [x] 3.1 `lib/services/drive_storage_adapter.dart` — `desktopSecretsPath` : remplacer `!Platform.isWindows` par `(!Platform.isWindows && !Platform.isLinux)`, et ajouter `lOptions: LinuxOptions()` dans `_secureStorage`
- [x] 3.2 `lib/services/dropbox_storage_adapter.dart` — même correction `desktopSecretsPath` + `lOptions: LinuxOptions()` dans `_secureStorage`
- [x] 3.3 `lib/core/config_service.dart` — chargement `.env` : remplacer `Platform.isWindows` par `Platform.isWindows || Platform.isLinux`

## 4. Vérification tests Mode 1 sur Linux

- [x] 4.1 Lancer l'app en VM Ubuntu 26.04 en Mode 1 : vérifier wizard → sélection dossier (file picker) → cave.db créé → vue stock chargée
- [x] 4.2 Vérifier que `_DesktopRail` (NavigationRail) s'affiche bien sur Linux (pas `_MobileBar`)
- [x] 4.3 Vérifier que la fermeture de la fenêtre Linux déclenche `didRequestAppExit` (comportement identique à Windows en Mode 1)

## 5. Vérification tests Mode 2 sur Linux

- [x] 5.1 Placer `google_desktop_secrets.json` à côté de l'exécutable et tester l'authentification Drive (navigateur → loopback → token persisté dans libsecret) — Validé sur VM Ubuntu 26.04 (2026-05-26)
- [ ] 5.2 Placer `dropbox_desktop_secrets.json` à côté de l'exécutable et tester l'authentification Dropbox PKCE (navigateur → loopback → token persisté dans libsecret)
- [x] 5.3 Vérifier le cycle complet Mode 2 Drive sur Linux : lock → download → sync manuelle → unlock à la fermeture — Lock OK, token persisté (2026-05-26)
- [ ] 5.4 Vérifier le cycle complet Mode 2 Dropbox sur Linux : même séquence

## 6. Script de packaging

- [x] 6.1 Créer `scripts/build_linux.sh` avec la cible `appimage` : structure AppDir, copie des libs Flutter, icône 512×512, fichier `.desktop`, appel `appimagetool` (téléchargé si absent), sortie `build/linux/Cavea-x86_64.AppImage`
- [x] 6.2 Ajouter la cible `deb` dans le même script : structure `DEBIAN/control` (Package, Version, Architecture, Depends, Description), installation dans `/usr/local/bin/cavea`, entrée `.desktop` dans `/usr/share/applications/`, appel `dpkg-deb --build`, sortie `build/linux/cavea_1.0.0_amd64.deb`
- [x] 6.3 Tester l'AppImage en VM : l'app démarre, Mode 1 fonctionnel, secret JSON trouvé à côté de l'AppImage — Validé sur Ubuntu 26.04 (2026-05-26)
- [x] 6.4 Tester le .deb en VM : `sudo dpkg -i cavea_1.0.0_amd64.deb` → entrée menu → app démarre — Validé sur Ubuntu 26.04 (2026-05-26)

## 7. Documentation

- [x] 7.1 Mettre à jour `ARCHITECTURE.md` : Linux → statut "V1 ✅", documenter les dépendances systèmes, mentionner scripts de packaging
- [x] 7.2 Mettre à jour `CLAUDE.md` : Linux ajouté aux plateformes supportées, commandes build Linux, emplacement attendu des secrets JSON sur Linux
- [x] 7.3 Corriger `scripts/build_linux.sh` : `Depends` .deb avec noms t64 pour Ubuntu 24.04+ / 26.04 (`libgtk-3-0t64 | libgtk-3-0`, `libsecret-1-0t64 | libsecret-1-0`)
- [x] 7.4 Créer `DEPLOY_LINUX.md` : guide utilisateur final (installation .deb / AppImage, configuration Mode 1 et Mode 2, placement secrets JSON, dépannage Wayland / trousseau)
