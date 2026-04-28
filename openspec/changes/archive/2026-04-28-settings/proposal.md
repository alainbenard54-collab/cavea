## Why

L'étape 8 du MVP ferme les deux derniers points de configuration hardcodés : le chemin vers `cave.db` (Mode 1) et les valeurs par défaut du formulaire bulk-add (`couleur`, `contenance`). Ces valeurs sont actuellement en dur dans le code avec des `TODO(settings)` en attente. L'écran Paramètres existe déjà dans la navigation mais est minimal (Drive uniquement) ; il faut le compléter.

## What Changes

- `ConfigService` étendu avec :
  - Deux valeurs par défaut : `couleurDefaut` (défaut "Rouge") et `contenanceDefaut` (défaut "75 cl")
  - Trois **listes de référence** persistées : `refCouleurs`, `refContenances`, `refCrus` — préchargées avec des valeurs builtin métier
- Écran Paramètres enrichi avec :
  - **Mode 1** : affichage du chemin actuel de `cave.db` + bouton "Modifier"
  - **Valeurs par défaut (ajout en lot)** : couleur et contenance pré-sélectionnées
  - **Listes de référence** : gestion des valeurs proposées dans les listes couleur/contenance/cru (ajout/suppression de chips)
- `BulkAddScreen` : les constantes hardcodées remplacées par lecture `ConfigService` ; les listes couleur/contenance/cru fusionnent valeurs DB + listes de référence

## Capabilities

### New Capabilities

- `settings-screen` : écran Paramètres complet — chemin cave.db, valeurs par défaut bulk-add, gestion des listes de référence, À propos

### Modified Capabilities

- `app-config` : ajout de `couleurDefaut`, `contenanceDefaut`, `refCouleurs`, `refContenances`, `refCrus` dans `ConfigService` (SharedPreferences)
- `bulk-add` : listes couleur/contenance/cru = union(valeurs DB, listes de référence) ; constantes hardcodées supprimées

## Impact

- `lib/core/config_service.dart` : nouveaux champs + clés SharedPreferences + méthodes save
- `lib/features/settings/settings_screen.dart` : nouvelles sections + widget `_RefListEditor`
- `lib/features/bulk_add/bulk_add_screen.dart` + `bulk_add_controller.dart` : suppression constantes, lecture ConfigService, fusion listes
- `file_picker` (déjà en dépendance) utilisé pour le sélecteur de dossier Mode 1

## Non-goals

- Configuration Mode 2 (Google Drive / Dropbox) — placeholder uniquement en MVP
- Mode 3 (Android local) — hors périmètre MVP
- Validation ou migration du chemin cave.db existant (l'utilisateur est responsable du chemin valide)
- Export/import de la configuration
