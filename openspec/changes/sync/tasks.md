## 1. Dépendances et configuration GCP

- [x] 1.1 Ajouter `googleapis`, `googleapis_auth`, `flutter_secure_storage`, `url_launcher` dans `pubspec.yaml` ; vérifier compatibilité Windows desktop + Android
- [x] 1.2 Créer un projet GCP, activer l'API Google Drive, générer un `client_id` Desktop (OAuth) et un `client_id` Android ; stocker les identifiants dans un fichier de config non commité (ex. `assets/google_client_secrets.json` ignoré par git)
- [x] 1.3 Configurer le schéma d'URL de retour OAuth Android dans `AndroidManifest.xml` pour le flux `google_sign_in`

## 2. Interface StorageAdapter

- [x] 2.1 Créer `lib/services/storage_adapter.dart` avec la classe abstraite `StorageAdapter` (méthodes : `isLocked`, `lock`, `unlock`, `downloadDb`, `uploadDb`) — PC + Android

## 3. DriveStorageAdapter — OAuth

- [x] 3.1 Créer `lib/services/drive_storage_adapter.dart` : classe `DriveStorageAdapter implements StorageAdapter` avec champ `DriveApi` et `AuthClient` — squelette vide — PC + Android
- [x] 3.2 Implémenter le flux OAuth Desktop (serveur localhost:8080 + `url_launcher`) dans `DriveStorageAdapter._authenticateDesktop()` — PC uniquement
- [x] 3.3 Implémenter le flux OAuth Android via `google_sign_in` dans `DriveStorageAdapter._authenticateAndroid()` — Android uniquement
- [x] 3.4 Ajouter `DriveStorageAdapter.authenticate()` qui dispatch selon la plateforme (`Platform.isAndroid`) et persiste le `refresh_token` dans `flutter_secure_storage`
- [x] 3.5 Ajouter le rafraîchissement automatique du token (vérifier expiry avant chaque opération, utiliser `googleapis_auth` pour le refresh) — PC + Android

## 4. DriveStorageAdapter — opérations Drive

- [x] 4.1 Implémenter `uploadDb(File localDb)` : upload du fichier `cave.db` dans `appDataFolder` (créer ou remplacer) — PC + Android
- [x] 4.2 Implémenter `downloadDb(String localPath)` : télécharger `cave.db` depuis `appDataFolder` et écrire à `localPath` — PC + Android
- [x] 4.3 Implémenter `isLocked()` : chercher `cave.db.lock` dans `appDataFolder`, parser le JSON, retourner `false` si absent ou > 24h — PC + Android
- [x] 4.4 Implémenter `lock()` : créer/remplacer `cave.db.lock` avec `{"locked_by": "<device_id>", "locked_at": "<iso8601>"}` — PC + Android
- [x] 4.5 Implémenter `unlock()` : supprimer `cave.db.lock` de `appDataFolder` — PC + Android
- [x] 4.6 Implémenter la génération de `device_id` stable (ex. hash du nom de machine ou UUID persisté dans `flutter_secure_storage`) — PC + Android

## 5. SyncService

- [x] 5.1 Créer `lib/services/sync_service.dart` : `SyncState` (sealed class ou enum : `idle`, `syncing`, `locked`, `error`) — PC + Android
- [x] 5.2 Implémenter `SyncService extends StateNotifier<SyncState>` avec injection de `StorageAdapter` via constructor — PC + Android
- [x] 5.3 Implémenter `SyncService.sync()` : séquence complète (vérifier lock → lock → download → fermer drift → remplacer fichier → invalider provider → `idle`) — PC + Android
- [x] 5.4 Implémenter la détection du lock existant détenu par cet appareil (upload avant download lors d'une deuxième sync) — PC + Android
- [x] 5.5 Ajouter la gestion d'erreur dans `sync()` : `try/catch` sur chaque étape, `unlock()` si le lock avait été acquis, passage en état `error` — PC + Android
- [x] 5.6 Créer `syncServiceProvider` Riverpod : retourne un `SyncService` inactif (no-op) en Mode 1, et une instance avec `DriveStorageAdapter` en Mode 2 — PC + Android

## 6. Réouverture drift après download

- [x] 6.1 Exposer une méthode `close()` sur le provider drift existant (ou utiliser `ref.invalidate`) pour permettre la fermeture propre avant remplacement du fichier — PC + Android
- [x] 6.2 Vérifier que `ref.invalidate(driftDatabaseProvider)` reconstruit correctement la base et que les streams drift actifs se rétablissent sans erreur — PC + Android

## 7. UI — Indicateur sync et bouton Synchroniser

- [x] 7.1 Créer `lib/widgets/sync_status_indicator.dart` : widget consommant `syncServiceProvider`, affichant icône selon l'état (gris=idle, animé=syncing, orange=locked, rouge=error) avec tooltip — PC + Android
- [x] 7.2 Intégrer `SyncStatusIndicator` dans la `NavigationRail` (Desktop ≥600px) et dans la `BottomNavigationBar` (Mobile <600px) — visible uniquement en Mode 2 — PC + Android
- [x] 7.3 Ajouter un bouton "Synchroniser" accessible depuis la NavigationRail/BottomBar en Mode 2, désactivé pendant l'état `syncing` — PC + Android
- [x] 7.4 Implémenter l'overlay de blocage UI pendant l'état `syncing` (Stack + IgnorePointer + CircularProgressIndicator) au niveau du shell de navigation — PC + Android
- [x] 7.5 Ajouter les snackbars de feedback : "Synchronisation réussie" (idle après sync ok), "Cave verrouillée par <device_id>" (état locked) — PC + Android
- [x] 7.6 Ajouter le dialogue d'erreur post-sync (état error) avec boutons "Réessayer" et "Fermer" — PC + Android

## 8. Settings — activation Mode 2

- [x] 8.1 Modifier `lib/screens/settings_screen.dart` : remplacer le placeholder "Non disponible" par le bouton "Activer Google Drive" (Mode 1 → Mode 2) — PC + Android
- [x] 8.2 Implémenter le flux bascule Mode 1 → Mode 2 dans Settings : OAuth → dialogue migration → `uploadDb()` → mise à jour `SharedPreferences` → activation `SyncService` — PC + Android
- [x] 8.3 Implémenter la bascule Mode 2 → Mode 1 dans Settings : désactivation `SyncService`, mise à jour `SharedPreferences`, conservation du `cave.db` local — PC + Android

## 9. Wizard de premier lancement — Mode 2

- [x] 9.1 Modifier le wizard (`lib/screens/setup_wizard.dart` ou équivalent) : remplacer le placeholder Mode 2 "Non disponible" par le flux OAuth + choix "Nouvelle cave" / "Télécharger depuis Drive" — PC + Android
- [x] 9.2 Implémenter "Télécharger depuis Drive" dans le wizard : `downloadDb()` → ouvrir drift sur le fichier téléchargé → naviguer vers l'écran principal — PC + Android

## 10. Tests manuels

- [ ] 10.1 Test PC uniquement (Mode 1) : vérifier qu'aucun `StorageAdapter` n'est instancié, que le bouton "Synchroniser" est absent — PC [TEST MANUEL]
- [ ] 10.2 Test bascule Mode 1 → Mode 2 sur PC : OAuth, migration one-shot, apparition de l'indicateur sync — PC [TEST MANUEL]
- [ ] 10.3 Test sync PC → Android : modifier une bouteille sur PC, synchroniser, vérifier la modification visible sur Android — PC + Android [TEST MANUEL]
- [ ] 10.4 Test sync Android → PC : modifier une bouteille sur Android, synchroniser, vérifier sur PC — PC + Android [TEST MANUEL]
- [ ] 10.5 Test lock concurrent : lancer une sync sur PC, tenter une sync sur Android pendant que le lock est actif → vérifier l'état `locked` sur Android — PC + Android [TEST MANUEL]
- [ ] 10.6 Test stale lock : créer manuellement un `cave.db.lock` avec un timestamp > 24h dans `appDataFolder`, vérifier qu'il est ignoré — PC + Android [TEST MANUEL]
- [ ] 10.7 Test token expiré : expirer manuellement le token, déclencher une sync, vérifier le refresh automatique sans intervention — PC + Android [TEST MANUEL]
