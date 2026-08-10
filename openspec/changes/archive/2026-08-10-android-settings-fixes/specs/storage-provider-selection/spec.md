## MODIFIED Requirements

### Requirement: Sélection / changement de fournisseur dans Settings
L'écran Settings SHALL afficher le fournisseur cloud actif dans la section "Mode de synchronisation" quand Mode 2 est activé. Les actions "Revenir en local" et "Changer de fournisseur" SHALL être accessibles sur toutes les plateformes, y compris Android.

#### Scenario: Affichage du fournisseur actif
- **WHEN** l'écran Settings est ouvert et que `storageMode == 'drive'` ou `'dropbox'`
- **THEN** le fournisseur actif est affiché (ex. "Google Drive" ou "Dropbox") dans la section Mode de synchronisation

#### Scenario: Revenir en local depuis Android
- **WHEN** l'utilisateur Android appuie sur "Revenir en local" dans les Paramètres
- **THEN** un dialog de confirmation s'affiche, et après confirmation les tokens sont effacés, le lock est relâché et l'app passe en Mode 1

#### Scenario: Changer de fournisseur depuis Android
- **WHEN** l'utilisateur Android appuie sur "Changer de fournisseur" dans les Paramètres
- **THEN** un dialog de confirmation s'affiche, les tokens du fournisseur courant sont effacés, et le wizard de premier lancement s'affiche pour choisir un nouveau fournisseur

#### Scenario: Changer de fournisseur depuis Settings (desktop)
- **WHEN** l'utilisateur desktop appuie sur "Changer de fournisseur"
- **THEN** les tokens du fournisseur courant sont effacés de `flutter_secure_storage`, `storageMode` est réinitialisé à `'local'`, et le wizard de premier lancement s'affiche

#### Scenario: Fournisseur affiché côté Mode 1
- **WHEN** l'écran Settings est ouvert et que `storageMode == 'local'`
- **THEN** aucun fournisseur cloud n'est affiché et les boutons "Revenir en local" / "Changer de fournisseur" sont absents
