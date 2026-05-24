## Context

`_ModeChoiceStep` est actuellement un `StatelessWidget`. Il reçoit `onSelect` en callback mais n'a pas accès à Riverpod. `localeProvider` expose un `NotifierProvider<LocaleNotifier, Locale?>` — `LocaleNotifier.setLocale(String?)` persiste et applique le changement immédiatement.

Les labels "Français" et "English" ne sont pas traduits (noms de langues dans leur propre langue — règle établie dans le projet).

## Goals / Non-Goals

**Goals:**
- Sélecteur FR/EN visible dès la première étape du setup
- Changement de langue immédiat et persisté
- Cohérence visuelle Material 3

**Non-Goals:**
- Sélecteur sur les étapes suivantes (pathInput, driveAuth, etc.)
- Support d'autres langues

## Decisions

### D1 — `SegmentedButton<String>` plutôt que deux `TextButton`

`SegmentedButton` est le composant Material 3 standard pour les choix exclusifs de ce type. Il affiche visuellement la langue active. `settings_screen.dart` utilise `SegmentedButton` pour le même sélecteur de langue → cohérence UX.

### D2 — Placement : au-dessus du titre `setupWelcome`

Le sélecteur de langue doit être vu avant tout texte en français. Le placer en tout premier, centré horizontalement et compact, minimise son impact visuel tout en restant accessible.

### D3 — `_ModeChoiceStep` devient `ConsumerWidget`

Minimal : seul `_ModeChoiceStep` a besoin d'accès au provider. Les autres sous-widgets du setup (`_PathInputStep`, `_DriveAuthStep`, etc.) restent inchangés. Pas de remontée de state au niveau `SetupScreen`.

### D4 — Langue courante détectée via `Localizations.localeOf(context)`

Plus fiable que `ref.watch(localeProvider)` qui retourne `null` si la locale n'a pas encore été persistée (premier lancement sans préférence). `Localizations.localeOf(context)` reflète toujours la locale effective de l'app à l'instant t.

## Risks / Trade-offs

- [Rebuild lors du changement de locale] Le `SegmentedButton` doit se mettre à jour après `setLocale`. Comme `SetupScreen` est un `ConsumerWidget` qui watch `localeProvider`, et que `MaterialApp` rebuild l'arbre entier quand la locale change, le `SegmentedButton` reflétera automatiquement la nouvelle locale — pas de gestion d'état locale nécessaire.
