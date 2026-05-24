## ADDED Requirements

### Requirement: Sélecteur de langue sur l'écran de premier démarrage
L'écran de premier démarrage SHALL afficher un `SegmentedButton` FR/EN en haut de la première étape (choix du mode), avant le titre de bienvenue.

Le sélecteur SHALL :
- Afficher deux segments : "Français" et "English" (labels non traduits)
- Refléter la langue courante de l'app via `Localizations.localeOf(context).languageCode`
- Appeler `ref.read(localeProvider.notifier).setLocale(code)` lors de la sélection
- Être centré horizontalement et compact (pas pleine largeur)
- Être visible uniquement sur l'étape `SetupStep.modeChoice`

#### Scenario: Premier lancement sur Windows français, utilisateur anglophone
- **WHEN** l'utilisateur ouvre Cavea pour la première fois sur un système en français
- **THEN** l'écran de démarrage affiche le sélecteur FR/EN avec "Français" actif, l'utilisateur peut tapper "English" pour basculer l'interface en anglais avant de choisir le mode

#### Scenario: Changement de langue immédiat
- **WHEN** l'utilisateur tape "English" dans le sélecteur
- **THEN** toute l'interface de l'écran de démarrage bascule en anglais immédiatement, sans rechargement de page

#### Scenario: Langue persistée après la configuration
- **WHEN** l'utilisateur sélectionne "English" puis termine la configuration (choix du mode, chemin, etc.)
- **THEN** l'app démarre en anglais et garde cette langue lors des lancements suivants
