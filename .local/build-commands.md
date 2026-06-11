# Cavea — Commandes de build de référence

Fichier local, non versionné. Mettre à jour à chaque changement de procédure.

---

## Prérequis avant tout build

1. `dart-defines.json` présent à la racine (copier depuis `dart-defines.json.template` et renseigner)
2. `google_desktop_secrets.json` présent à la racine (Mode 2 Drive Windows/Linux)
3. `dropbox_desktop_secrets.json` présent à la racine (Mode 2 Dropbox Windows/Linux)
4. Pour APK/AAB : `assets/secrets/dropbox_desktop_secrets.json` doit être une copie du fichier racine
   (gitignored — à copier manuellement avant chaque build Android)
5. Pour APK signé : `android/key.properties` configuré avec le keystore `cavea-release.jks`

---

## Windows

### 1. Nettoyage du cache (obligatoire avant tout build de release)
```powershell
flutter clean
```
> Sans `flutter clean`, les dart-defines (`SAMPLE_DATA_URL_*`, etc.) peuvent ne pas être
> pris en compte si le cache date d'un build antérieur à leur ajout. Toujours faire
> `flutter clean` en début de cycle de release.

### 2. Build Flutter
```powershell
flutter build windows --release --dart-define-from-file=dart-defines.json
```

### 2. Installateur Inno Setup
Si `iscc` est dans le PATH :
```powershell
iscc windows\packaging\cavea.iss
```

Si `iscc` n'est pas dans le PATH (chemin complet) :
```powershell
& "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" windows\packaging\cavea.iss
```

Output : `windows\packaging\output\Cavea-{version}-windows-setup.exe`

> L'installateur propose à la désinstallation de supprimer les données de config
> (%APPDATA%\Cavea\Cavea — SharedPreferences). cave.db n'est jamais touché.

---

## Android

### APK (3 ABI — pour distribution directe / GitHub Release)
```powershell
flutter build apk --split-per-abi --release --dart-define-from-file=dart-defines.json
```
Output dans `build\app\outputs\flutter-apk\` :
- `app-arm64-v8a-release.apk` — téléphones récents 64 bits (prioritaire)
- `app-armeabi-v7a-release.apk` — appareils anciens
- `app-x86_64-release.apk` — émulateurs

### AAB (pour Google Play Store)
```powershell
flutter build appbundle --release --dart-define-from-file=dart-defines.json
```
Output : `build\app\outputs\bundle\release\app-release.aab`

> L'AAB est le seul format accepté par Google Play Console.
> Uploader dans Play Console → Track test fermé (ou prod) → Nouvelle release.

---

## Linux (depuis la VM Ubuntu)

### 1. Build Flutter
```bash
flutter build linux --release
```

### 2. Paquet .deb
```bash
./scripts/build_linux.sh deb
```
Output : `build/linux/cavea_{version}_amd64.deb`

> La version dans build_linux.sh doit correspondre à pubspec.yaml.
> Mettre à jour la ligne `VERSION=` dans `scripts/build_linux.sh` à chaque release.

---

## Vérifications avant build

```powershell
flutter analyze
flutter test
```
Les deux doivent retourner 0 erreur / 0 failure avant tout build de release.

---

## Bump de version — 4 fichiers obligatoires (Claude les met à jour systématiquement)

| Fichier | Champ | Exemple |
|---|---|---|
| `pubspec.yaml` | `version: X.Y.Z+N` | `1.2.0+5` |
| `windows/packaging/cavea.iss` | `#define MyAppVersion "X.Y.Z"` | `"1.2.0"` |
| `installer/cavea.iss` | `#define MyAppVersion "X.Y.Z"` | `"1.2.0"` |
| `scripts/build_linux.sh` | `VERSION="X.Y.Z"` | `"1.2.0"` |

Le `versionCode` (`+N` dans pubspec) est incrémenté à chaque build Play Store.
`X.Y.Z` seul (sans `+N`) dans les 3 autres fichiers.

---

## Checklist release complète

- [ ] Bump version dans les 4 fichiers ci-dessus (Claude fait les 4 en même temps)
- [ ] `flutter clean` (obligatoire — évite les problèmes de cache dart-defines)
- [ ] `flutter clean` (obligatoire — évite les problèmes de cache dart-defines)
- [ ] `flutter analyze` → 0 issue
- [ ] `flutter test` → 0 failure
- [ ] Build Windows : `flutter build windows` + `iscc`
- [ ] Build Android APK : `flutter build apk --split-per-abi`
- [ ] Build Android AAB : `flutter build appbundle`
- [ ] Build Linux .deb : `flutter build linux` + `./scripts/build_linux.sh deb`
- [ ] `git tag v{version}` + `git push --tags`
- [ ] GitHub Release créée avec les artefacts + notes de release
- [ ] AAB uploadé sur Play Console → track correspondant

---

## Historique des versions

| Version | versionCode | Date       | Notes                               |
|---------|-------------|------------|-------------------------------------|
| 1.0.0   | +1          | 2026-05-24 | Première release publique           |
| 1.1.0   | +4          | 2026-05-28 | Fixes Android, Linux, Dropbox       |
| 1.2.0   | +5          | 2026-06-xx | Mode local Android, données exemple |
