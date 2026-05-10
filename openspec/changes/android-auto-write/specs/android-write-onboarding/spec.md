## ADDED Requirements

### Requirement: Dialog d'information au premier passage en mode écriture Android
Au premier passage en SyncIdle sur Android (Mode 2), l'application SHALL afficher un dialog informant l'utilisateur qu'il doit utiliser le bouton "Quitter" pour sauvegarder ses modifications et libérer le verrou avant de fermer l'app.

Le dialog comporte :
- Un titre "Mode écriture activé"
- Un message expliquant l'importance du bouton Quitter
- Une case à cocher "Ne plus afficher ce message"
- Un bouton "OK"

La préférence est persistée via `ConfigService` (clé SharedPreferences `android_write_warning_seen`, bool). Si la case est cochée, le dialog ne s'affiche plus. Si la case n'est pas cochée, le dialog réapparaît au prochain démarrage en mode écriture.

#### Scenario: Premier démarrage Android en mode écriture — warning non vu
- **WHEN** l'app Android passe en SyncIdle pour la première fois (ou que `android_write_warning_seen == false`)
- **THEN** un dialog "Mode écriture activé" est affiché avec le message d'information et la case "Ne plus afficher"

#### Scenario: Utilisateur coche "Ne plus afficher"
- **WHEN** l'utilisateur coche "Ne plus afficher" avant de taper "OK"
- **THEN** `android_write_warning_seen` est écrit à `true` dans SharedPreferences et le dialog ne s'affiche plus lors des prochains démarrages

#### Scenario: Utilisateur tape "OK" sans cocher
- **WHEN** l'utilisateur tape "OK" sans cocher "Ne plus afficher"
- **THEN** `android_write_warning_seen` reste à `false` et le dialog réapparaît au prochain démarrage en mode écriture

#### Scenario: Warning déjà vu — pas d'affichage
- **WHEN** l'app Android passe en SyncIdle et que `android_write_warning_seen == true`
- **THEN** aucun dialog n'est affiché, l'app s'ouvre directement en mode écriture
