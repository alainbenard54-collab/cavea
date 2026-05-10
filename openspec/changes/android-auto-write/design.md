## Context

`sync_service.dart` contient deux branches `if (Platform.isAndroid)` dans `syncOnStartup()`, `resolveOwnLockWithUpload()` et `resolveOwnLockWithDownload()` qui font diverger Android de Windows. Sur Android, le chemin "lock absent" va en `SyncReadOnly` (sans acquérir de lock) et le crash recovery libère le lock après résolution. Ce comportement était justifié par l'absence de sortie propre sur Android — risque de lock fantôme si l'OS tue le process. Ce risque est maintenant mitigé par le bouton "Quitter" (`_QuitIconBtn`) et le crash recovery existant au prochain démarrage.

Côté UI, `adaptive_layout.dart` affiche dans `_MobileBar` : `_AcquireLockIconBtn` (Prendre la main, mode lecture seule Android) et `_AbandonWriteIconBtn` (Retour lecture seule, mode écriture Android). Ces deux boutons deviennent inutiles avec l'auto-acquisition.

## Goals / Non-Goals

**Goals:**
- Supprimer les branches `Platform.isAndroid` dans `syncOnStartup()`, `resolveOwnLockWithUpload()`, `resolveOwnLockWithDownload()` — Android suit exactement le chemin Windows
- Supprimer `_AcquireLockIconBtn` et `_AbandonWriteIconBtn` de `_MobileBar`
- Afficher un dialog d'information one-time "Pensez à utiliser le bouton Quitter" au premier passage en mode écriture sur Android

**Non-Goals:**
- Modifier le comportement Windows (aucune touche)
- Modifier le dialog lock tiers (`SyncNeedsLockChoice`) — inchangé
- Modifier le dialog crash recovery (`SyncNeedsCrashRecovery`) — inchangé (mais son issue passe en SyncIdle sur Android comme sur Windows)
- Chiffrement de cave.db
- Support Mode 3 (Android full local)

## Decisions

**1. Suppression directe des branches `Platform.isAndroid` dans `SyncService`**

Alternative : introduire une abstraction `_platformStrategy`. Rejeté — sur-ingénierie, 3 méthodes concernées, la diff est triviale. La suppression directe est lisible et testable.

Dans `syncOnStartup()` chemin "lock absent" : supprimer le bloc `if (Platform.isAndroid) { … SyncReadOnly … return; }`. Le chemin PC (lock → download ou upload → SyncIdle) s'applique désormais aux deux plateformes.

Dans `resolveOwnLockWithUpload()` : supprimer le bloc `if (Platform.isAndroid) { unlock … SyncReadOnly }`. Android garde le lock → SyncIdle.

Dans `resolveOwnLockWithDownload()` : supprimer le bloc `if (Platform.isAndroid) { unlock … download … SyncReadOnly }`. Android garde le lock, download sans unlock → SyncIdle.

**2. Warning one-time géré dans l'UI, pas dans `SyncService`**

Le service émet des états (`SyncState`) ; la décision d'afficher un dialog appartient à la couche présentation. Le warning sera déclenché depuis `_AppShellState` via `ref.listen<SyncState>` : quand l'état passe à `SyncIdle` sur Android et que `configService.androidWriteWarningSeen == false`, le dialog est affiché.

Alternative : émettre un état `SyncIdleFirstAndroid`. Rejeté — pollue le graphe d'états pour un cas UI pur.

**3. Persistance via `ConfigService` / SharedPreferences**

Clé : `android_write_warning_seen` (bool, défaut `false`). Déjà cohérent avec les autres préférences utilisateur dans `ConfigService`. Si l'utilisateur coche "Ne plus afficher" → `true` écrit en SharedPreferences. Sans coche → reste `false`, le dialog réapparaît au prochain démarrage.

**4. Suppression de `_AcquireLockIconBtn` et `_AbandonWriteIconBtn`**

Ces classes deviennent du code mort. Supprimées intégralement plutôt que gardées commentées ou conditionnées — elles n'ont aucun usage post-changement. `_MobileBar` en mode écriture Android affiche désormais : `SyncStatusIndicator` + `_SaveIconBtn` + `_QuitIconBtn`.

## Risks / Trade-offs

**Android pourrait maintenant acquérir le lock à chaque démarrage même si l'utilisateur voulait juste consulter** → Acceptable. L'"intent" de lecture seule n'est plus un cas d'usage premier (une cave à vin personnelle est presque toujours ouverte pour modifier). Le lock est libéré proprement en quittant.

**Lock fantôme si l'OS Android tue le process** → Déjà géré : le crash recovery au prochain démarrage propose upload local ou téléchargement Drive. Ce chemin est inchangé (seule son issue passe en SyncIdle au lieu de SyncReadOnly).

**Utilisateurs habitués à "Prendre la main"** → Aucune migration nécessaire : ils arrivent directement en écriture, expérience simplifiée.

## Open Questions

Aucune.
