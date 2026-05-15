## Why

Cavea est aujourd'hui entièrement en français (libellés, messages, formats). Supporter l'anglais permet d'ouvrir l'application à des utilisateurs anglophones et prépare la base technique pour toute langue future. La feature i18n est inscrite au périmètre V1 depuis le début du projet.

## What Changes

- Ajout de `flutter_localizations` + `intl` comme dépendances principales.
- Création de deux fichiers ARB (`lib/l10n/app_fr.arb` + `lib/l10n/app_en.arb`) couvrant l'ensemble des strings statiques : libellés de champs, titres d'écrans, noms d'onglets, messages snackbar/dialog, tooltips, placeholders, contenu de l'`AboutDialog`.
- Extraction de tous les strings hardcodés vers les ARB (remplacement systématique dans tous les fichiers `.dart`).
- Ajout d'un sélecteur de langue dans l'écran Paramètres : **Automatique / Français / English**. La préférence est stockée dans `ConfigService` (SharedPreferences). `MaterialApp.locale` est piloté par ce choix (null = délégation à la locale OS). Fallback : français.
- Adaptation des formats date et nombre à la locale via `intl` (`DateFormat`, `NumberFormat`) — décimales, séparateurs de milliers.
- Traduction des libellés des couleurs builtin dans l'UI uniquement (Rouge→Red, Blanc→White…) via un mapping statique dans `ConfigService`. Les valeurs stockées en base restent invariablement en français.
- Traduction des en-têtes de colonnes du CSV exporté selon la locale active au moment de l'export.
- Gestion des pluriels via les règles ARB (`{count, plural, one{} other{}}`) pour tous les compteurs de bouteilles.
- Création de deux pages de politique de confidentialité sur GitHub (`docs/privacy/fr.md` + `docs/privacy/en.md`) avec lien dynamique selon la locale dans l'`AboutDialog`.
- Messages d'erreur non interceptés provenant de l'API Drive/Google OAuth : laissés en anglais (texte brut externe non contrôlé). Messages reformulés par l'app : traduits via ARB.

## Capabilities

### New Capabilities

- `locale-infrastructure` : infrastructure i18n — dépendances, fichiers ARB fr+en, extraction de tous les strings statiques, pluriels, intégration dans `MaterialApp`.
- `locale-settings` : sélecteur de langue dans Paramètres (Automatique/Français/English), stockage dans `ConfigService`, adaptation des formats date/nombre à la locale.
- `locale-color-display` : mapping statique des libellés couleurs builtin (fr↔en) dans `ConfigService` ; clés DB inchangées.

### Modified Capabilities

- `csv-export` : les en-têtes de colonnes du fichier CSV sont désormais traduits selon la locale active au moment de l'export (exigence fonctionnelle nouvelle sur le format de sortie).
- `app-config` : ajout d'une clé `langue` (Automatique/fr/en) dans la section Paramètres, stockée dans `ConfigService`/SharedPreferences.

## Impact

- **Dépendances** : `flutter_localizations` (Flutter SDK, inclus), `intl` (pub.dev — déjà probablement transitive, à vérifier).
- **Fichiers nouveaux** : `lib/l10n/app_fr.arb`, `lib/l10n/app_en.arb`, `lib/l10n/l10n.dart` (barrel), `docs/privacy/fr.md`, `docs/privacy/en.md`.
- **Fichiers modifiés** : `pubspec.yaml` (dépendances + génération ARB), `lib/main.dart` (localizations delegates + locale resolver), `lib/shared/config_service.dart` (préférence langue + mapping couleurs), `lib/features/settings/settings_screen.dart` (sélecteur langue + formats), `lib/features/export_csv/csv_export_service.dart` (en-têtes traduits), et **tous les fichiers `.dart`** contenant des strings hardcodés (remplacement systématique par `context.l10n.*`).
- **Non-goals** :
  - Traduction des valeurs métier saisies par l'utilisateur (domaine, appellation, commentaires…).
  - Traduction des valeurs CRU (appellations françaises d'usage international).
  - Traduction des messages d'erreur bruts Google/OAuth non interceptés.
  - Ajout d'une troisième langue (hors périmètre V1).
  - Mode 3 (Android local seul) non concerné — aucun impact spécifique.
