## Why

L'écran de premier démarrage (`SetupScreen`) guide l'utilisateur dans le choix du mode (Local ou Partagé) mais ne propose pas de choisir la langue de l'app. Un utilisateur qui installe Cavea en anglais sur un Windows en français se retrouve avec l'interface en français, sans indication qu'il peut changer la langue. Le seul endroit pour modifier la langue est l'écran Paramètres — inaccessible avant d'avoir terminé la configuration.

## What Changes

- `_ModeChoiceStep` dans `setup_screen.dart` : converti en `ConsumerWidget`, ajout d'un `SegmentedButton<String>` FR/EN en haut de l'écran (avant le titre et les cartes de mode)
- Sélectionner une langue appelle `ref.read(localeProvider.notifier).setLocale(code)` — changement immédiat et persisté

## Capabilities

### New Capabilities

- `setup-locale-selector` : sélecteur de langue FR/EN sur l'écran de premier démarrage, avant le choix du mode

### Modified Capabilities

*(aucune)*

## Non-goals

- Ajout d'autres langues — seules FR et EN sont supportées
- Sélecteur sur les autres étapes du setup (pathInput, driveAuth, etc.)
- Nouvelle clé l10n — les labels "Français" et "English" sont non traduits (noms de langues dans leur propre langue, règle déjà établie)

## Impact

- `lib/features/setup/setup_screen.dart` : `_ModeChoiceStep` → `ConsumerWidget` + `SegmentedButton`
- `lib/core/locale_provider.dart` : lu en lecture seule via `ref.watch(localeProvider)`, pas de modification
- Modes 1 et 2, PC et Android
