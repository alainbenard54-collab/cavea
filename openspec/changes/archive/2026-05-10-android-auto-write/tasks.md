## 1. SyncService — supprimer les branches Android dans syncOnStartup()

- [x] 1.1 Dans `lib/services/sync_service.dart`, supprimer le bloc `if (Platform.isAndroid) { … SyncReadOnly … return; }` dans `syncOnStartup()` (chemin "lock absent"). Android suit désormais le chemin PC : lock → download ou upload → SyncIdle
- [x] 1.2 Vérifier que l'import `dart:io show Platform` reste utilisé ailleurs dans le fichier (il l'est pour `releaseAndExit` et `releaseIfNeeded`) — ne pas le supprimer

## 2. SyncService — supprimer les branches Android dans crash recovery

- [x] 2.1 Dans `resolveOwnLockWithUpload()`, supprimer le bloc `if (Platform.isAndroid) { unlock … SyncReadOnly }` : Android garde le lock après upload et passe en SyncIdle comme Windows
- [x] 2.2 Dans `resolveOwnLockWithDownload()`, supprimer le bloc `if (Platform.isAndroid) { unlock … download … SyncReadOnly }` : Android garde le lock, télécharge, et passe en SyncIdle comme Windows

## 3. ConfigService — clé android_write_warning_seen

- [x] 3.1 Dans `lib/services/config_service.dart`, ajouter la propriété `bool get androidWriteWarningSeen` lisant la clé SharedPreferences `android_write_warning_seen` (défaut `false`)
- [x] 3.2 Ajouter la méthode `Future<void> setAndroidWriteWarningSeen()` écrivant `true` pour cette clé

## 4. UI — dialog d'onboarding Android

- [x] 4.1 Dans `lib/shared/adaptive_layout.dart` (ou dans `_AppShellState`), ajouter un `ref.listen<SyncState>` qui détecte le passage en `SyncIdle` sur Android et vérifie `configService.androidWriteWarningSeen`
- [x] 4.2 Implémenter le dialog `_WriteOnboardingDialog` (StatefulWidget pour la checkbox) : titre "Mode écriture activé", message "Sur Android, utilisez toujours le bouton Quitter pour sauvegarder vos modifications et libérer le verrou. Sans cela, vos données resteraient uniquement en local et l'accès en écriture depuis d'autres appareils serait bloqué.", checkbox "Ne plus afficher ce message", bouton "OK"
- [x] 4.3 Au tap "OK" : si checkbox cochée → appeler `configService.setAndroidWriteWarningSeen()` ; dans tous les cas fermer le dialog

## 5. UI — supprimer _AcquireLockIconBtn et _AbandonWriteIconBtn

- [x] 5.1 Supprimer la classe `_AcquireLockIconBtn` de `adaptive_layout.dart` (bouton "Prendre la main", plus affiché)
- [x] 5.2 Supprimer la classe `_AbandonWriteIconBtn` de `adaptive_layout.dart` (bouton "Retour lecture seule", plus affiché)
- [x] 5.3 Dans `_MobileBar.build()`, retirer les références à `_AcquireLockIconBtn` et `_AbandonWriteIconBtn` — la zone sync Android en mode écriture affiche uniquement `SyncStatusIndicator` + `_SaveIconBtn` + `_QuitIconBtn`

## 6. Tests manuels (Android, Mode 2)

- [x] 6.1 Démarrage Android lock absent : vérifier que l'app s'ouvre directement en mode écriture (icône verte) sans "Prendre la main"
- [x] 6.2 Démarrage Android lock absent (premier lancement Drive vide) : vérifier que la base locale est uploadée et l'app s'ouvre en mode écriture
- [x] 6.3 Dialog onboarding : vérifier qu'il s'affiche au premier démarrage en mode écriture, que "OK" sans coche le fait réapparaît au suivant, et que "OK" avec coche le supprime définitivement
- [x] 6.4 Vérifier que la zone sync Android mode écriture affiche bien uniquement `SyncStatusIndicator` + Sauvegarder + Quitter (sans "Retour lecture seule")
- [x] 6.5 Crash recovery Android : vérifier que les deux choix (upload local / download Drive) aboutissent en SyncIdle (mode écriture) et non en SyncReadOnly
- [x] 6.6 Lock tiers sur Android : vérifier que le dialog existant "Cave utilisée sur un autre appareil" fonctionne toujours correctement (lecture seule ou quitter)
- [x] 6.7 Comportement Windows inchangé : vérifier que le démarrage PC en Mode 2 (lock absent, lock tiers, crash recovery) se comporte exactement comme avant
