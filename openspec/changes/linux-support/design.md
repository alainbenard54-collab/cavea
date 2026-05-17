## Context

L'app Cavea compile déjà pour Windows (desktop) et Android (mobile) depuis un unique codebase Flutter. Linux desktop est nativement supporté par Flutter — le scaffold `linux/` s'obtient via `flutter create --platforms=linux .`. La quasi-totalité du code Dart est cross-platform ; les ajustements sont chirurgicaux et localisés dans les couches platform-detection et secrets-loading.

**État actuel des gardes platform :**
- `Platform.isAndroid` → chemin mobile (Google Sign-In, Dropbox App Key depuis secure storage)
- `else` / `!Platform.isAndroid` → chemin desktop (OAuth loopback, lecture secrets JSON)
- `Platform.isWindows` (2 occurrences dans `desktopSecretsPath`, 1 dans `.env`) → **exclut Linux par erreur**

Linux n'est pas Android, donc il suit déjà le bon chemin dans l'authentification Drive et Dropbox (loopback PKCE). Seul le chargement des secrets et du `.env` est bloqué.

## Goals / Non-Goals

**Goals:**
- Mode 1 sur Linux : `dart:io` direct sur `cave.db`, file picker, navigation desktop (`_DesktopRail`), cycle de vie identique à Windows
- Mode 2 sur Linux : OAuth Drive (`googleapis_auth clientViaUserConsent`) + Dropbox PKCE, les deux via loopback HTTP — secrets chargés depuis JSON à côté de l'exécutable
- `flutter_secure_storage` fonctionnel sur Linux via libsecret/kwallet
- Scripts de packaging AppImage et .deb

**Non-Goals:**
- Aucune modification du comportement Windows ou Android
- CI/CD automatisée, Snap/Flatpak, macOS/iOS

## Decisions

### 1 — Stratégie de plateforme : `isDesktop()` + `!Platform.isAndroid` suffit

**Décision** : ne pas introduire de helper `isLinux()` ou `isDesktopPlatform()`. Les gardes existantes `!Platform.isAndroid` couvrent déjà Linux correctement dans 95% des cas. Seules les deux gardes `Platform.isWindows` explicites nécessitent une correction.

**Alternatif écarté** : refactoriser toutes les gardes vers un helper centralisé `isNativeDesktop()` = `Platform.isWindows || Platform.isLinux`. Trop invasif pour un changement minimal.

### 2 — Chargement des secrets sur Linux

**Décision** : étendre `desktopSecretsPath` dans `DriveStorageAdapter` et `DropboxStorageAdapter` : remplacer `!Platform.isWindows` par `(!Platform.isWindows && !Platform.isLinux)`. Le fichier JSON est cherché dans le même ordre : à côté de l'exécutable, puis à la racine du répertoire de travail (build de dev).

Sur Linux le chemin de l'exécutable est `/usr/local/bin/cavea` (paquet .deb) ou `Cavea.AppDir/usr/bin/cavea` (AppImage) — la logique `File(Platform.resolvedExecutable).parent.path` fonctionne dans les deux cas.

### 3 — `FlutterSecureStorage` sur Linux

**Décision** : ajouter `lOptions: LinuxOptions()` aux deux `const _secureStorage`. Le backend Linux de `flutter_secure_storage` utilise `libsecret` (GNOME Keyring) ou `kwallet` (KDE). La dépendance native `libsecret-1-dev` doit figurer dans `linux/CMakeLists.txt`.

**Alternatif écarté** : stocker les tokens dans `SharedPreferences` sur Linux (moins sécurisé, casse la parité Windows).

### 4 — `.env` sur Linux

**Décision** : étendre la garde `Platform.isWindows` dans `config_service.dart` à `Platform.isWindows || Platform.isLinux`. Les utilisateurs Linux avancés peuvent pré-configurer le `.env` comme sur Windows.

### 5 — OAuth Drive sur Linux

**Décision** : `clientViaUserConsent` (`googleapis_auth`) est déjà cross-platform. Il ouvre le navigateur via `launchUrl` et écoute la réponse sur un port loopback libre. Sur Linux, `url_launcher` utilise `xdg-open`. Aucune modification nécessaire.

**Condition** : le package `googleapis_auth` gère lui-même le serveur HTTP de callback — pas de `HttpServer` à écrire dans le code applicatif.

### 6 — Packaging

**Décision** : script shell `scripts/build_linux.sh` qui orchestre :
- `flutter build linux --release`
- AppImage : via `appimagetool` (téléchargé si absent) + `.desktop` + icône
- .deb : structure manuelle `DEBIAN/control` + `dpkg-deb --build`

**Alternatif écarté** : `flutter_distributor` (sur-ingénierie pour V1, requiert Ruby + configuration yaml complexe).

## Risks / Trade-offs

| Risque | Mitigation |
|---|---|
| `libsecret` absent sur la VM de test (Ubuntu minimal) | Documenter les dépendances dans CLAUDE.md ; le build échoue proprement si absent |
| `url_launcher` échoue si aucun navigateur par défaut configuré sur Linux | L'erreur OAuth remonte en Exception visible dans le wizard — afficher le lien manuellement en fallback (V2) |
| AppImage non signé → avertissement sécurité Ubuntu | Accepté en V1 ; signature GPG hors scope |
| `Platform.resolvedExecutable` dans AppImage pointe vers le runtime, pas l'AppDir | Tester en VM ; si problème : fallback sur `Directory.current` (déjà dans le code) |

## Migration Plan

1. Générer `linux/` avec `flutter create --platforms=linux .` (à faire par l'utilisateur dans la VM ou sur Windows avec Flutter installé)
2. Appliquer les 3 corrections Dart (desktopSecretsPath ×2, config_service, FlutterSecureStorage ×2)
3. Ajouter `libsecret` dans `linux/CMakeLists.txt`
4. `flutter build linux --release` → vérifier Mode 1 en VM
5. Configurer secrets JSON Drive/Dropbox dans la VM → vérifier Mode 2
6. Lancer `scripts/build_linux.sh` → vérifier AppImage et .deb

Rollback : toutes les modifications sont dans des fichiers Dart existants ; un `git revert` suffit. Le répertoire `linux/` peut être supprimé sans impact Windows/Android.
