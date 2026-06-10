## Why

La documentation utilisateur (13 scénarios, bilingue fr/en) existe dans `docs/` et est publiée via GitHub Pages, mais elle n'est pas accessible depuis l'application. L'utilisateur doit la trouver sur GitHub sans aucun lien depuis l'app. Par ailleurs, l'index `docs/README.md` mélange les deux langues dans un seul tableau, ce qui rend l'URL de la documentation non déterministe par langue.

## What Changes

- **Restructuration `docs/`** : `docs/README.md` (index bilingue mélangé) est remplacé par trois fichiers distincts :
  - `docs/README.md` → page d'entrée minimaliste avec deux liens langue
  - `docs/fr/README.md` → index complet en français uniquement
  - `docs/en/README.md` → full index in English only
- **Bouton "Documentation" dans le dialog "À propos"** : nouveau `TextButton` entre "Confidentialité" et "Licences" qui ouvre `https://cavea.abapps.fr/fr/` ou `.../en/` selon la langue courante de l'app. `url_launcher` est déjà une dépendance.
- **Clé l10n** : ajout de `aboutDocumentation` dans `app_fr.arb` et `app_en.arb`.

## Capabilities

### New Capabilities

- `app-documentation-link` : bouton dans le dialog "À propos" ouvrant la documentation en ligne selon la langue courante de l'application

### Modified Capabilities

- `user-documentation` : restructuration de l'index docs/ — `docs/README.md` devient un sélecteur de langue, deux nouveaux fichiers `docs/fr/README.md` et `docs/en/README.md` servent d'index par langue

## Non-goals

- Aucune documentation embarquée offline dans l'app (flutter_markdown, assets bundlés)
- Aucune WebView intégrée
- Pas de changement au contenu des 13 scénarios existants (uniquement l'index)

## Impact

- `lib/features/settings/settings_screen.dart` : ajout d'un `TextButton` dans l'`AlertDialog` "À propos"
- `lib/l10n/app_fr.arb`, `lib/l10n/app_en.arb` : nouvelle clé `aboutDocumentation`
- `lib/l10n/app_localizations*.dart` : régénéré par `flutter gen-l10n`
- `docs/README.md` : remplacé (contenu simplifié)
- `docs/fr/README.md` : créé (nouveau fichier)
- `docs/en/README.md` : créé (nouveau fichier)
- Modes 1 et 2 concernés (les paramètres sont accessibles dans les deux modes)
