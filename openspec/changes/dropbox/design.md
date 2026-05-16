## Context

`StorageAdapter` est l'interface abstraite entre `SyncService` et le backend cloud (`lib/services/storage_adapter.dart`). `DriveStorageAdapter` en est la seule implémentation actuelle (~334 lignes). `SyncService` ne connaît pas le backend — il ne manipule qu'un `StorageAdapter?`.

Le `syncServiceProvider` (Riverpod `StateNotifierProvider`) lit `storageModeProvider` pour instancier le bon adaptateur. Actuellement : `mode == 'drive'` → `DriveStorageAdapter()`, sinon → `SyncService(null)` (Mode 1).

La valeur `storageMode` est stockée dans SharedPreferences via `ConfigService.save()`. `AppConfig.storageMode` est un `String` (`'local'` ou `'drive'`).

Paquets disponibles sans ajout de dépendance : `http`, `flutter_secure_storage`, `url_launcher`, `shared_preferences`, `uuid`.

## Goals / Non-Goals

**Goals:**
- Implémenter `DropboxStorageAdapter` avec authentification OAuth 2.0 PKCE (desktop et Android) et API Dropbox v2 via HTTP
- Étendre `syncServiceProvider` pour instancier `DropboxStorageAdapter` quand `storageMode == 'dropbox'`
- Ajouter la sélection du fournisseur (Drive vs Dropbox) dans le wizard de premier lancement et dans Settings
- Conserver le comportement identique à Drive : même lock JSON, même dossier `/Cavea/`, même cycle lock/download/upload

**Non-Goals:**
- Migration automatique d'un fournisseur à l'autre
- Support multi-fournisseur simultané
- SDK Dart officiel Dropbox (l'API REST v2 suffit)
- Changement de l'interface `StorageAdapter`

## Decisions

### D1 — API Dropbox via `http` direct, sans SDK

**Décision** : utiliser `package:http` avec l'API REST Dropbox v2 directement.

**Rationale** : aucun SDK Dart officiel Dropbox stable n'existe. Le paquet `dropbox_client` est abandonné. L'API v2 est simple (headers Bearer, JSON) et `http` est déjà une dépendance. Évite une dépendance lourde de tierce partie.

**Alternative rejetée** : SDK `dropbox_client` — abandonné, incompatible null-safety.

---

### D2 — OAuth 2.0 PKCE avec redirect localhost (desktop)

**Décision** : sur Windows, ouvrir le browser via `url_launcher` avec un redirect vers `http://localhost:PORT/callback`. Écoute d'un `HttpServer` local pour capturer le code d'autorisation. Échange contre un access_token + refresh_token. Stockage du refresh_token dans `flutter_secure_storage`.

**Rationale** : même pattern que `clientViaUserConsent` de `googleapis_auth`. Dropbox supporte PKCE avec redirect localhost pour apps natives. Pas besoin d'une Redirect URI enregistrée fixe — le port peut être dynamique (OS en choisit un disponible).

**Alternative rejetée** : Dropbox OAuth v1 — déprécié. `flutter_appauth` — nouvelle dépendance.

---

### D3 — OAuth Android via browser externe + App Link

**Décision** : sur Android, ouvrir le browser avec `url_launcher` et configurer un App Link (`cavea://oauth/callback`) dans `AndroidManifest.xml`. L'app intercepte le callback via `getInitialUri()` / stream URI.

**Rationale** : cohérent avec le flow Android de Drive (qui utilise `GoogleSignIn` mais suit le même principe de redirect vers l'app). Dropbox recommande PKCE + App Link pour Android native.

**Fichiers à modifier** : `android/app/src/main/AndroidManifest.xml` (intent-filter pour `cavea://oauth/callback`).

---

### D4 — Sélection fournisseur dans le wizard existant

**Décision** : ajouter une étape "Choix du fournisseur" (Drive vs Dropbox) dans le wizard Mode 2 existant, avant l'étape d'authentification. L'étape 3 du wizard (actuellement "Se connecter avec Google") devient conditionnelle selon le fournisseur choisi.

**Rationale** : le wizard est déjà en place et guide l'utilisateur. Injecter une étape de sélection est moins intrusif que de créer un nouveau chemin.

---

### D5 — Changement de fournisseur dans Settings

**Décision** : dans la section "Mode de synchronisation" de `SettingsScreen`, quand Mode 2 est actif, afficher le fournisseur courant avec un bouton "Changer de fournisseur". Ce bouton efface les tokens du fournisseur courant (secure storage), remet `storageMode` à `'local'`, et redirige vers le wizard.

**Rationale** : le reset + wizard est déjà le chemin pour "Reconfigurer". Pas besoin de créer une UI de migration complexe.

---

### D6 — Format de verrou identique à Drive

**Décision** : le lock Dropbox est un fichier JSON `cave.db.lock` dans le dossier `/Cavea/` avec le même format que Drive : `{"locked_by": "<deviceId>", "locked_at": "<ISO8601>"}`.

**Rationale** : `SyncService` est agnostique du backend. Le `deviceId` est stocké dans `flutter_secure_storage` sous une clé spécifique au fournisseur (`dropbox_device_id`). Pas d'interopérabilité entre fournisseurs (dossiers distincts, pas de conflit).

---

### D7 — Secrets Dropbox desktop dans un fichier `dropbox_desktop_secrets.json`

**Décision** : les credentials Dropbox desktop (App Key, App Secret) sont stockés dans `dropbox_desktop_secrets.json` à côté de l'exécutable, lu via `dart:io` (même pattern que `google_desktop_secrets.json`).

**Rationale** : cohérence avec l'existant. Sur Android, l'App Key est hardcodée (Dropbox ne nécessite pas de App Secret pour PKCE Android).

## Risks / Trade-offs

**[Durée de vie des tokens Dropbox]** → Dropbox offline_access tokens sont de longue durée mais révocables. Mitigation : détecter les erreurs 401/403 dans `DropboxStorageAdapter` et notifier `SyncService` (même mécanisme que Drive).

**[App Link Android non testé automatiquement]** → La capture du callback OAuth Android nécessite un test manuel. Mitigation : documenter la procédure de test dans tasks.md.

**[Port localhost dynamique]** → Le port choisi par l'OS peut changer entre sessions. Dropbox autorise les redirects localhost sans port fixe dans l'App Console (option "Allow localhost"). Vérifier cette option lors de la création de l'app Dropbox.

**[Taille des fichiers]** → L'API Dropbox v2 `/files/upload` gère jusqu'à 150 MB en upload simple. `cave.db` dépasse rarement quelques MB. Pas de gestion de sessions d'upload nécessaire.

## Migration Plan

1. Créer `lib/services/dropbox_storage_adapter.dart`
2. Étendre `syncServiceProvider` dans `sync_service.dart`
3. Ajouter `'dropbox'` aux valeurs valides de `storageMode` dans `config_service.dart`
4. Modifier le wizard (étape sélection fournisseur)
5. Modifier `SettingsScreen` (section Mode 2, bouton changement fournisseur)
6. Modifier `AndroidManifest.xml` (App Link OAuth)
7. Test manuel OAuth Windows puis Android

**Rollback** : retirer la valeur `'dropbox'` du `syncServiceProvider` — si `storageMode == 'dropbox'` sans adaptateur, le service est en Mode 1 (safe fallback).

## Open Questions

- Aucune — toutes les décisions sont tranchées.
