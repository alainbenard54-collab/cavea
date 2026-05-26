## Why

Les tests APK Android (task 6.3 de bundle-oauth-credentials) ont révélé deux problèmes dans l'écran Paramètres en Mode 2 : les actions "Revenir en local" et "Changer de fournisseur" sont invisibles sur Android (gardes `Platform.isAndroid` résiduelles d'avant le bundling de l'App Key), et Google Drive reste muet en cas d'échec d'authentification (le bouton ne réagit pas sans message d'erreur). Ces deux problèmes bloquent un utilisateur Android qui veut changer de configuration Mode 2.

## What Changes

- **"Revenir en local" sur Android** : le bouton `OutlinedButton` dans le trailing du `ListTile` actif est remplacé par un `ListTile` dédié avec icône — cohérent avec le layout Android (trailing `null` → action explicite dans la liste)
- **"Changer de fournisseur" sur Android** : suppression du garde `!Platform.isAndroid` — l'action est désormais visible et fonctionnelle sur Android
- **Google Drive muet sur Android** : `_authenticateAndroid()` catchait déjà les exceptions mais `GoogleSignIn.instance.authenticate()` peut retourner `null` sans exception quand le SHA-1 n'est pas enregistré — ajout d'un check explicite + message d'erreur actionnable mentionnant le SHA-1
- **Documentation SHA-1** : ajout d'une note dans `DEPLOY_ANDROID.md` (ou `ARCHITECTURE.md`) sur le prérequis SHA-1 pour Google Drive

## Capabilities

### New Capabilities
- *(aucune)*

### Modified Capabilities
- `storage-provider-selection` : les actions de changement/désactivation de fournisseur sont accessibles sur Android
- `android-sync-ux` : message d'erreur explicite quand Google Drive échoue silencieusement sur Android

## Impact

- `lib/features/settings/settings_screen.dart` : `_CloudActiveTile` — retrait gardes `Platform.isAndroid` sur "Revenir en local" et "Changer de fournisseur", adaptation layout Android
- `lib/services/drive_storage_adapter.dart` : `_authenticateAndroid()` — check `account == null` avec exception explicite
- `ARCHITECTURE.md` ou nouveau `DEPLOY_ANDROID.md` : note sur SHA-1 debug/release keystore pour GCP

## Non-goals

- Configuration automatique du SHA-1 dans GCP
- Gestion du keystore de production (hors périmètre — traité dans la release v1.1.0)
- Résoudre les WARNING Kotlin Gradle Plugin (cosmétique, non bloquant pour l'instant)
