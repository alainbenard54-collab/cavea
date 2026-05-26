## 1. Settings Android — "Revenir en local" et "Changer de fournisseur"

- [ ] 1.1 Dans `lib/features/settings/settings_screen.dart`, `_CloudActiveTile.build()` : remplacer `trailing: Platform.isAndroid ? null : OutlinedButton(onPressed: _deactivate, ...)` par `trailing: null` et ajouter un `ListTile` dédié (icon `Icons.logout`, title `settingsRevenirLocal`) visible sur toutes plateformes, avec `onTap: () => _deactivate(context)`
- [ ] 1.2 Supprimer le garde `if (!Platform.isAndroid)` devant le `ListTile` "Changer de fournisseur" — le rendre visible sur Android

## 2. Google Drive Android — message d'erreur explicite

- [ ] 2.1 Dans `lib/services/drive_storage_adapter.dart`, `_authenticateAndroid()` : après `account ??= await GoogleSignIn.instance.authenticate(...)`, ajouter `if (account == null) throw Exception('Connexion Google annulée ou impossible. Vérifiez que le SHA-1 de votre certificat APK est enregistré dans Google Cloud Console.')` 

## 3. Documentation SHA-1

- [ ] 3.1 Dans `ARCHITECTURE.md`, section Android, ajouter une note sur le prérequis SHA-1 : commande `keytool` pour obtenir le SHA-1 du debug keystore, lien vers GCP Console → Credentials → OAuth Android

## 4. Validation

- [ ] 4.1 `flutter analyze` — 0 issue
- [ ] 4.2 `flutter test` — 0 régression
- [ ] 4.3 Test Android : vérifier que "Revenir en local" et "Changer de fournisseur" apparaissent dans les Paramètres en Mode 2
- [ ] 4.4 Test Android : enregistrer le SHA-1 du debug keystore dans GCP, vérifier que Google Drive s'authentifie correctement
