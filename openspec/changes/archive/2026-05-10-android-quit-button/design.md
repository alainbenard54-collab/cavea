## Context

`_MobileBar` (`lib/shared/adaptive_layout.dart`) affiche en mode écriture Android trois éléments dans la zone sync :
- `_AbandonWriteIconBtn` (`lock_reset`, orange) → `syncService.abandonWrite()` — supprime le lock sans upload, revient en SyncReadOnly
- `_SaveReleaseIconBtn` (`cloud_done`, vert) → `syncService.releaseManual()` — upload + supprime lock + SyncReadOnly
- Aucun bouton de fermeture propre

`SyncService` expose déjà :
- `sync()` — upload uniquement, lock conservé, reste SyncIdle
- `releaseManual()` — upload + unlock + SyncReadOnly
- `releaseAndExit()` — `SyncExiting` + `releaseIfNeeded()` + `ServicesBinding.instance.exitApplication(AppExitType.required)`

Le renommage de "Sauvegarder et libérer" → "Sauvegarder" implique de changer l'appel de `releaseManual()` à `sync()` dans `_SaveReleaseIconBtn`. Le nouvel bouton "Quitter" réutilise `releaseAndExit()`.

## Goals / Non-Goals

**Goals:**
- Permettre une sauvegarde intermédiaire sans perte du lock (session continue)
- Fournir une sortie propre Android : upload + unlock + exit en un geste
- Zéro modification de `SyncService` — recâblage UI uniquement

**Non-Goals:**
- Modifier la logique de sync ou les états `SyncState`
- Impacter Windows (exit via `didRequestAppExit` + `releaseAndExit()` inchangé)
- Modifier le comportement en lecture seule ou en Mode 1

## Decisions

### 1. "Sauvegarder" utilise `sync()`, pas un nouveau mécanisme

**Décision :** `_SaveIconBtn` appelle `syncService.sync()` qui existe déjà (upload sans unlock, état SyncIdle conservé). C'est exactement le comportement du bouton "Synchroniser" Windows.

**Rationale :** Réutiliser une méthode éprouvée évite d'introduire un nouveau chemin de code. Le feedback visuel est identique au bouton "Synchroniser" (`SyncSyncing` → `SyncIdle` → snackbar "Cave sauvegardée sur Drive").

### 2. "Quitter" utilise `releaseAndExit()` sans modification

**Décision :** `_QuitIconBtn` appelle `syncService.releaseAndExit()` qui fait : `SyncExiting` → `releaseIfNeeded()` (upload + unlock) → `ServicesBinding.instance.exitApplication(AppExitType.required)`.

**Rationale :** `releaseAndExit()` était conçu pour le workflow de fermeture Windows (`didRequestAppExit`), mais son comportement est identique à ce dont on a besoin sur Android. `AppExitType.required` bypass le handler `onExitRequested`, ce qui évite la boucle de récursion et garantit la fermeture. L'état visuel `SyncExiting` (overlay spinner "Sauvegarde en cours…") assure l'utilisateur que l'upload est en cours avant la fermeture.

**Alternative rejetée :** `releaseManual()` + `exit(0)` séquentiels dans le widget — moins propre car l'état `SyncExiting` ne serait pas déclenché, et le spinner ne s'afficherait pas pendant l'upload.

### 3. Icônes distinctives pour les trois actions

**Décision :**
- "Retour lecture seule" : `lock_reset` orange (inchangé)
- "Sauvegarder" : `save` (ou `cloud_upload`) vert — `cloud_done` était ambigu (suggérait "terminé/libéré")
- "Quitter" : `exit_to_app` (standard Material "quitter l'app")

**Rationale :** `cloud_done` suggérait une finalité (libération) qui n'est plus le comportement. `save` ou `cloud_upload` est plus neutre. `exit_to_app` est le standard Material pour "quitter l'application".

### 4. Tooltip et dialog de confirmation pour "Quitter"

**Décision :** Un dialog de confirmation avant `releaseAndExit()` : "Sauvegarder et quitter ? Vos modifications seront envoyées sur Drive et le verrou libéré." — boutons "Annuler" et "Quitter".

**Rationale :** L'action est irréversible (quitte l'app). Un dialog évite les fermetures accidentelles. Le comportement est cohérent avec `_AbandonWriteIconBtn` qui demande aussi confirmation.

## Risks / Trade-offs

- **[Risque] `releaseAndExit()` peut ne pas fermer l'app sur certains Android** → Si `ServicesBinding.instance.exitApplication` est bloqué, `exit(0)` en fallback dans le catch. À tester sur Android physique.
- **[Trade-off] Trois boutons dans la zone sync** : la barre peut être chargée visuellement. Mitigation : les trois boutons existent déjà (Abandon + SaveRelease) + SyncStatusIndicator + AcquireLock, la zone est déjà dense. Tester sur petits écrans.
