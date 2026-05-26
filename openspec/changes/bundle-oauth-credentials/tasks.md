## 1. Asset Android — App Key Dropbox

- [x] 1.1 Créer `assets/secrets/dropbox_app_key.txt` à la racine du projet contenant uniquement l'App Key Dropbox (sans JSON, juste la valeur brute)
- [x] 1.2 Dans `pubspec.yaml`, ajouter `assets/secrets/` à la section `flutter.assets`
- [x] 1.3 Ajouter `assets/secrets/` dans `.gitignore`

## 2. Dart — DropboxStorageAdapter Android

- [x] 2.1 Dans `lib/services/dropbox_storage_adapter.dart`, méthode `authenticate()` branche Android : lire `assets/secrets/dropbox_app_key.txt` via `rootBundle.loadString()`, trimmer la valeur, appeler `saveAndroidAppKey()` avant le flow PKCE
- [x] 2.2 Gérer le cas asset absent : catch `FlutterError` / exception → lever une `Exception('Dropbox App Key manquante — build de développement')` avec message lisible

## 3. UI — Suppression saisie App Key Android

- [x] 3.1 Dans `lib/features/setup/setup_screen.dart` : supprimer le bloc `if (Platform.isAndroid)` qui affiche le champ `setupDropboxAppKey` et le `_appKeyController`
- [x] 3.2 Dans `lib/features/setup/setup_controller.dart` : supprimer le paramètre `androidAppKey` et l'appel conditionnel à `saveAndroidAppKey()` (déplacé dans l'adapter)
- [x] 3.3 Dans `lib/features/settings/settings_screen.dart` : supprimer le dialog `dropboxAppKeyLabel` et le code associé (`appKeyCtrl`, `showDialog`, `saveAndroidAppKey`)
- [x] 3.4 Dans `lib/l10n/app_fr.arb` et `app_en.arb` : supprimer les clés `setupDropboxAppKey` et `dropboxAppKeyLabel`

## 4. Script Linux — bundling credentials

- [x] 4.1 Dans `scripts/build_linux.sh`, fonction `build_appimage()` : après la copie du binaire, copier conditionnellement `google_desktop_secrets.json` et `dropbox_desktop_secrets.json` depuis `$PROJECT_ROOT` vers la racine de l'AppDir ; afficher un warning si absents
- [x] 4.2 Dans `scripts/build_linux.sh`, fonction `build_deb()` : même copie conditionnelle vers `$deb_dir/usr/local/lib/cavea/` ; warning si absents

## 5. Windows installer — bundling credentials

- [x] 5.1 Dans `windows/packaging/cavea.iss`, section `[Files]` : ajouter deux entrées `Source` pour `..\..\google_desktop_secrets.json` et `..\..\dropbox_desktop_secrets.json` avec `DestDir: "{app}"` et `Flags: ignoreversion skipifsourcedoesntexist`

## 6. Validation

- [x] 6.1 `flutter analyze` — 0 issue
- [x] 6.2 `flutter test` — 0 régression (122/122 passés)
- [ ] 6.3 Test Android : builder l'APK avec `assets/secrets/dropbox_app_key.txt` présent, vérifier que le wizard Dropbox ne demande plus l'App Key et que l'auth PKCE fonctionne
- [ ] 6.4 Test Linux : relancer `build_linux.sh deb` avec les JSON à la racine, installer le .deb, vérifier que les JSON sont dans `/usr/local/lib/cavea/` et que le Mode 2 fonctionne directement
- [x] 6.5 Test Windows : recompiler l'installateur avec les JSON à la racine du projet, installer, vérifier que les JSON sont dans `{app}\` et que le Mode 2 fonctionne directement — Validé 2026-05-26
