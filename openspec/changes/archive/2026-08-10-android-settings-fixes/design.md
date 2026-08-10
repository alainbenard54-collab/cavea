## Context

`_CloudActiveTile` dans `settings_screen.dart` gère l'affichage de la section Mode 2 actif. Deux actions y sont définies : `_deactivate()` (revenir en local) et `_changeProvider()` (changer de fournisseur). Les deux étaient cachées sur Android via des gardes `Platform.isAndroid` introduites avant que l'App Key Dropbox soit bundlée — elles supposaient que l'utilisateur Android ne pouvait pas configurer Dropbox sans saisie manuelle. Ce prérequis n'existe plus.

`DriveStorageAdapter._authenticateAndroid()` utilise `GoogleSignIn.instance.authenticate()` qui peut retourner `null` sans lever d'exception quand le SHA-1 de la clé de signature APK n'est pas enregistré dans GCP Console. Le code en aval appelle alors `.authorizationClient` sur `null` → NPE muette, ou le bouton reste simplement sans réaction visible.

## Goals / Non-Goals

**Goals:**
- Android : "Revenir en local" et "Changer de fournisseur" visibles et fonctionnels
- Android : message d'erreur explicite quand Google Drive échoue (SHA-1 manquant ou autre)
- Documenter le prérequis SHA-1 pour les builds Android

**Non-Goals:**
- Automatiser l'enregistrement SHA-1 dans GCP
- Gestion du keystore de production
- Corriger les WARNING Kotlin Gradle Plugin

## Decisions

### D1 — Layout Android pour "Revenir en local"

**Choix** : remplacer `trailing: Platform.isAndroid ? null : OutlinedButton(...)` par un `ListTile` dédié toujours affiché, avec `leading: Icon(Icons.logout)` et `onTap: _deactivate`.

**Pourquoi** : sur Android, les boutons dans les `trailing` de ListTile sont petits et peu accessibles. Un ListTile dédié est cohérent avec le pattern Material Android et avec `_changeProvider` qui est déjà un ListTile.

### D2 — Guard Android sur "Changer de fournisseur"

**Choix** : supprimer `if (!Platform.isAndroid)` — le ListTile est affiché sur toutes les plateformes.

**Pourquoi** : la seule raison de cacher cette action sur Android était la saisie manuelle de l'App Key. Cette contrainte n'existe plus.

### D3 — Erreur Drive Android

**Choix** : dans `_authenticateAndroid()`, après `account ??= await GoogleSignIn.instance.authenticate(...)`, vérifier `if (account == null)` et lever une `Exception` avec un message mentionnant explicitement le SHA-1 et la GCP Console.

**Pourquoi** : `GoogleSignIn` sur Android échoue silencieusement quand le SHA-1 n'est pas enregistré. L'utilisateur voit le bouton "Se connecter" sans retour visuel. Le message d'erreur doit être actionnable.

## Risks / Trade-offs

- **[Risque] _deactivate sur Android en Mode 2 écriture** : `_deactivate()` appelle `releaseIfNeeded()` qui fait un upload + unlock. Sur Android en mode écriture, c'est le même comportement que "Quitter" — acceptable, l'utilisateur confirme via dialog.
- **[Trade-off] SHA-1 documenté mais non automatisé** : l'utilisateur doit toujours enregistrer son SHA-1 manuellement dans GCP. C'est incontournable — Google ne fournit pas d'API pour automatiser cela.
