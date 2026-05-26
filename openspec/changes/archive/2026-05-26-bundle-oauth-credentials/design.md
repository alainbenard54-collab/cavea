## Context

Cavea distribue son app en trois packages : Windows installer (Inno Setup), Linux .deb / AppImage, Android APK. Le Mode 2 (sync cloud) requiert des credentials OAuth propres à l'application — un Client ID Google Drive et un App Key Dropbox. Ces credentials identifient l'*application* auprès des fournisseurs cloud, pas l'utilisateur. Ils doivent voyager avec l'app dans chaque package.

État actuel :
- **Windows** : Inno Setup copie `build\windows\x64\runner\Release\*` récursivement — les JSON secrets ne s'y trouvent que si le développeur les a copiés manuellement dans le dossier de build avant packaging. Non garanti.
- **Linux .deb / AppImage** : `build_linux.sh` ne copie pas les JSON secrets. L'utilisateur devait les placer manuellement dans `/usr/local/lib/cavea/`.
- **Android Dropbox** : le wizard affiche un champ texte `setupDropboxAppKey` pour que l'utilisateur tape l'App Key. Inacceptable pour un utilisateur final.
- **Android Google Drive** : `google-services.json` est consommé par le build system Gradle à la compilation. Aucun changement nécessaire.

## Goals / Non-Goals

**Goals:**
- Tout utilisateur ayant installé Cavea peut activer le Mode 2 (Drive ou Dropbox) sans aucune manipulation post-install
- Les scripts de build Linux incluent les secrets JSON si présents dans le projet
- L'installateur Windows inclut les secrets JSON explicitement
- Sur Android, l'App Key Dropbox est lue depuis un Flutter asset (bundlé à la compilation), pas saisie par l'utilisateur

**Non-Goals:**
- Chiffrement des credentials dans les packages (les App Keys OAuth sont semi-publiques — extrayables de tout binaire)
- Mise à jour des credentials sans nouvelle release
- Gestion de `google-services.json` Android (déjà correct)
- Automatisation du provisioning GCP / Dropbox App Console

## Decisions

### D1 — Mécanisme Android : Flutter asset plutôt que `flutter_dotenv` ou code en dur

**Choix** : `assets/secrets/dropbox_app_key.txt` (asset texte simple, gitignored).

**Pourquoi** : L'App Key est déjà lue depuis un fichier JSON sur desktop (`dropbox_desktop_secrets.json`) — le même principe s'applique sur Android via `rootBundle.loadString()`. Gitignored comme les JSON desktop. Alternative "code en dur" rejetée car elle force un commit du secret (même si semi-public, bonne hygiène). Alternative `flutter_dotenv` rejetée car dépendance supplémentaire non nécessaire.

**Lecture** : dans `DropboxStorageAdapter`, au `authenticate()` Android, avant tout : `rootBundle.loadString('assets/secrets/dropbox_app_key.txt')` → trim → `saveAndroidAppKey()`. Si l'asset est absent (build dev sans le fichier), lever une exception claire.

### D2 — Linux : copie conditionnelle dans `build_linux.sh`

**Choix** : dans `build_appimage()` et `build_deb()`, après la copie du binaire, vérifier la présence de chaque fichier secrets à `$PROJECT_ROOT/` et le copier si présent. Un warning est affiché si absent.

**Destination AppImage** : à la racine de l'AppDir (à côté de `AppRun` / de l'exe Flutter). `Platform.resolvedExecutable` dans une AppImage pointe vers l'exe à l'intérieur — le parent est la racine de l'AppDir montée, donc les secrets y sont trouvés.

**Destination .deb** : dans `/usr/local/lib/cavea/` (à côté de l'exe réel) — identique à ce que le code Dart attend via `File(Platform.resolvedExecutable).parent.path`.

### D3 — Windows : entrée `[Files]` explicite dans `cavea.iss`

**Choix** : ajouter deux entrées `Source` dans la section `[Files]` de `cavea.iss`, avec flag `Flags: skipifsourcedoesntexist` pour ne pas bloquer le build si les fichiers sont absents (cas CI sans credentials).

**Destination** : `{app}\` (racine du dossier d'installation) — cohérent avec `File(Platform.resolvedExecutable).parent.path` sur Windows.

### D4 — Suppression du champ App Key dans le wizard et Settings Android

Le champ `setupDropboxAppKey` dans `SetupScreen` (étape Dropbox, Android uniquement) et le dialog `dropboxAppKeyLabel` dans `SettingsScreen` sont supprimés. `setup_controller.dart` lit l'asset à la place de `_appKeyController.text`.

## Risks / Trade-offs

- **[Risque] Build CI sans les fichiers secrets** → `skipifsourcedoesntexist` sur Windows, warning non-bloquant sur Linux : le package est produit mais ne fonctionnera pas en Mode 2. Acceptable pour CI de PR ; les builds de release doivent avoir les fichiers.
- **[Risque] Asset Android absent au build** → exception explicite à l'authentification Dropbox, pas de crash silencieux. Le développeur voit l'erreur immédiatement.
- **[Trade-off] Les credentials sont extractibles du binaire** → inhérent à toute app OAuth desktop/mobile. La sécurité réelle repose sur la configuration OAuth (URIs de redirection autorisées, restrictions d'usage dans la console Google/Dropbox), pas sur l'obfuscation des credentials.

## Migration Plan

1. Créer `assets/secrets/dropbox_app_key.txt` localement (gitignored) — ne contient que l'App Key, sans JSON
2. Déclarer `assets/secrets/` dans `pubspec.yaml`
3. Modifier `DropboxStorageAdapter.authenticate()` Android pour lire l'asset
4. Supprimer champ App Key dans `SetupScreen` et `SettingsScreen`
5. Mettre à jour `build_linux.sh` (copie conditionnelle)
6. Mettre à jour `cavea.iss` (entrées `[Files]` explicites)
7. Mettre à jour `.gitignore` pour `assets/secrets/`
8. Test Windows : rebuild installer, vérifier que les JSON sont dans `{app}\`
9. Test Linux : rebuild .deb, vérifier que les JSON sont dans `/usr/local/lib/cavea/`
10. Test Android : rebuild APK, vérifier que Mode 2 Dropbox s'authentifie sans saisie

## Open Questions

- Aucune — toutes les décisions techniques sont prises.
