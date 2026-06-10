## Context

L'app possède un dialog "À propos" dans `settings_screen.dart` avec deux actions : "Confidentialité" (ouvre la privacy page via `url_launcher`) et "Licences" (`showLicensePage`). `url_launcher ^6.3.1` est déjà une dépendance du projet.

La documentation utilisateur (13 scénarios) est dans `docs/fr/` et `docs/en/`, publiée via GitHub Pages sur `https://cavea.abapps.fr/`. L'index `docs/README.md` contient un tableau bilingue mélangeant les deux langues. Il n'existe pas de fichier `docs/fr/README.md` ni `docs/en/README.md`.

GitHub Pages avec Jekyll sert automatiquement `README.md` comme index d'un répertoire : `docs/fr/README.md` est accessible à l'URL `/fr/`.

## Goals / Non-Goals

**Goals:**
- Ajouter un bouton "Documentation" dans le dialog "À propos" qui ouvre la doc en ligne dans le navigateur externe selon la langue de l'app
- Créer `docs/fr/README.md` et `docs/en/README.md` comme index monolingues par langue
- Simplifier `docs/README.md` en page d'entrée minimaliste (sélecteur de langue)

**Non-Goals:**
- Documentation embarquée offline dans l'app
- WebView intégrée (dépendance supplémentaire non justifiée)
- Modification du contenu des 13 scénarios existants

## Decisions

### D1 — Ouverture dans le navigateur externe (pas de WebView)

`url_launcher` avec `LaunchMode.externalApplication` — identique à ce qui est déjà fait pour la privacy page. Avantage : zéro dépendance nouvelle, cohérence avec l'existant, fonctionne offline (l'app s'ouvre, le bouton est visible, l'utilisateur sait qu'il a besoin d'internet pour la doc).

Alternative écartée : `webview_flutter` — dépendance lourde (surtout sur desktop Windows), complexité inutile pour un contenu externe.

### D2 — Détection de langue via `Localizations.localeOf(context)`

Même pattern que la privacy page (lignes 92-93 de `settings_screen.dart`). La locale courante de l'app détermine l'URL : `languageCode == 'en'` → `/en/`, sinon → `/fr/`.

### D3 — Structure docs/ : landing page + index par langue

`docs/README.md` devient une page d'entrée minimaliste (titre + 2 liens langue). Utile pour les visiteurs arrivant directement sur GitHub.com (qui affiche README.md automatiquement).

`docs/fr/README.md` et `docs/en/README.md` sont des index monolingues complets. GitHub Pages les sert respectivement à `/fr/` et `/en/` via Jekyll (convention index de répertoire).

Alternative écartée : supprimer `docs/README.md` entièrement — les visiteurs GitHub.com n'auraient plus de point d'entrée dans le dossier `docs/`.

### D4 — Clé l10n `aboutDocumentation`

Même mot ("Documentation") dans les deux langues — pas de traduction nécessaire. Ajout dans `app_fr.arb` et `app_en.arb`. Régénération via `flutter gen-l10n` (intégré dans le build, pas besoin de `build_runner`).

## Risks / Trade-offs

- [Dépendance réseau] Le bouton Documentation ne fonctionne que si l'appareil a accès à internet et GitHub Pages est disponible → Mitigation : comportement attendu et documenté ; `url_launcher` gère silencieusement l'absence de réseau (le navigateur affiche l'erreur réseau, pas l'app)
- [URL fixe en dur] Si le dépôt ou l'organisation GitHub est renommé, l'URL dans le code devient invalide → Mitigation : l'URL est stable (organisation dédiée), et peut être mise à jour dans une future release si besoin
