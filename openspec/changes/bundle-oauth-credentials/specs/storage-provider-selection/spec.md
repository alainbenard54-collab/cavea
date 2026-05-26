## MODIFIED Requirements

### Requirement: Sélection Dropbox dans le wizard — Android
Sur Android, le wizard Mode 2 SHALL déclencher le flow Dropbox PKCE sans demander d'App Key à l'utilisateur. L'App Key SHALL être lue depuis l'asset Flutter `assets/secrets/dropbox_app_key.txt` bundlé dans l'APK.

#### Scenario: Sélection Dropbox sur Android — App Key bundlée
- **WHEN** l'utilisateur sélectionne "Dropbox" dans le wizard sur Android
- **THEN** l'app lit l'App Key depuis `assets/secrets/dropbox_app_key.txt` via `rootBundle`, appelle `saveAndroidAppKey()`, et déclenche le flow PKCE sans aucun champ de saisie

#### Scenario: App Key absente au build Android
- **WHEN** l'APK est buildé sans `assets/secrets/dropbox_app_key.txt` et que l'utilisateur sélectionne Dropbox
- **THEN** l'app affiche une erreur explicite ("Dropbox non disponible dans cette version") sans crash

## REMOVED Requirements

### Requirement: Saisie de l'App Key Dropbox par l'utilisateur Android
**Reason**: L'App Key est un credential de l'application, pas de l'utilisateur. Demander à l'utilisateur de la saisir est une expérience inacceptable pour un utilisateur final.
**Migration**: L'App Key est désormais bundlée dans l'APK via `assets/secrets/dropbox_app_key.txt`. Le champ `setupDropboxAppKey` dans `SetupScreen` et le dialog `dropboxAppKeyLabel` dans `SettingsScreen` sont supprimés. Les clés ARB correspondantes sont retirées des fichiers de localisation.
