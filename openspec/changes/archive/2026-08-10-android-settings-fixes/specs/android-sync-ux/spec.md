## ADDED Requirements

### Requirement: Message d'erreur explicite si Google Drive échoue sur Android
Quand l'authentification Google Drive échoue sur Android (ex. SHA-1 non enregistré dans GCP), l'app SHALL afficher un message d'erreur explicite et actionnable plutôt que rester silencieuse.

#### Scenario: SHA-1 non enregistré — message d'erreur affiché
- **WHEN** l'utilisateur tente de s'authentifier avec Google Drive sur Android et que le SHA-1 de la clé de signature APK n'est pas enregistré dans GCP Console
- **THEN** l'app affiche un message d'erreur indiquant que la configuration Google Cloud est incomplète et que le SHA-1 du certificat de signature doit être enregistré dans GCP Console

#### Scenario: Échec générique Google Sign-In — message d'erreur affiché
- **WHEN** `GoogleSignIn.instance.authenticate()` retourne `null` ou lève une exception
- **THEN** l'app affiche le message d'erreur dans le wizard ou dans Settings (selon le contexte) et l'utilisateur peut réessayer
