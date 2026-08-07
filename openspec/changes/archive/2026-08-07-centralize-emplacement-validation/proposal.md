## Why

Le formulaire Déplacer bloque un déplacement vers un emplacement pourtant déjà présent en base (`Liebherr Vinothek > sortie_réfrigérateur ou habitat`, importé sans problème via CSV) : la regex de validation n'autorise ni underscore `_` ni tiret `-`. L'utilisateur ne souhaite pas renommer cet emplacement — c'est la validation qui doit être corrigée. En creusant, cette regex est dupliquée indépendamment dans 5 fichiers (2 variantes légèrement différentes), et l'import CSV n'applique aucune validation de format sur ce champ — d'où l'incohérence : une valeur acceptée à l'import devient ensuite impossible à re-saisir via l'UI.

## What Changes

- Élargir le jeu de caractères accepté pour chaque niveau d'un emplacement : ajout de `_` (underscore) et `-` (tiret), en plus des lettres (dont accentuées), chiffres et espaces déjà acceptés. La règle "doit commencer par un caractère alphanumérique" et le séparateur ` > ` restent inchangés.
- Centraliser la validation dans un seul endroit partagé (nouveau fichier dans `lib/shared/`), remplaçant les 5 copies indépendantes actuelles : `deplacer_form.dart`, `deplacer_batch_sheet.dart`, `bottle_edit_screen.dart`, `bulk_add_controller.dart`, `repartition_row.dart`.
- Appliquer ce même validateur partagé à l'import CSV (`csv_parser.dart`), qui n'a aujourd'hui aucune validation de format sur `emplacement`. Une ligne CSV avec un emplacement invalide sera désormais ignorée et reportée en erreur, selon la même convention déjà utilisée pour les autres champs obligatoires (domaine, appellation, millesime, couleur) : ligne skippée, ajoutée à `ParseError`, import des autres lignes non interrompu.
- Mettre à jour CLAUDE.md (section Data model) pour refléter le nouveau jeu de caractères accepté.

## Capabilities

### New Capabilities
(aucune)

### Modified Capabilities
- `bottle-actions` : le "Format emplacement" documenté (action Déplacer unitaire) inclut désormais `_` et `-` dans les caractères acceptés par niveau.
- `bottle-edit-screen` : la "Validation du format emplacement" du formulaire d'édition inclut désormais `_` et `-`.
- `bulk-add` : la "Validation format emplacement" de la répartition en lot inclut désormais `_` et `-` dans les caractères acceptés.
- `import-csv` : nouveau comportement — une ligne dont l'emplacement ne respecte pas le format hiérarchique valide est désormais ignorée et comptée en erreur (auparavant : aucune validation, toute valeur était acceptée).

## Impact

- Nouveau fichier partagé de validation dans `lib/shared/` (ex. `emplacement_validator.dart`), source unique de vérité pour le format emplacement.
- Fichiers modifiés : `lib/features/bottle_actions/widgets/deplacer_form.dart`, `lib/features/stock/widgets/deplacer_batch_sheet.dart`, `lib/features/bottle_edit/bottle_edit_screen.dart`, `lib/features/bulk_add/bulk_add_controller.dart`, `lib/features/bulk_add/widgets/repartition_row.dart`, `lib/features/import_csv/csv_parser.dart`.
- Messages d'erreur existants (`deplacerFormatError`, `repartitionFormatError` dans les ARB fr/en) réutilisés tels quels, sauf si leur texte doit explicitement mentionner `_`/`-` (à trancher en design).
- `CLAUDE.md` (section Data model, règle emplacement).
- Aucun changement de schéma de données, aucun impact sur les Modes 1/2/3 ni sur `StorageAdapter`/`SyncService`.
- Donnée existante de l'utilisateur (`Liebherr Vinothek > sortie_réfrigérateur ou habitat`) non modifiée — elle devient valide sous la nouvelle règle, sans migration nécessaire.
