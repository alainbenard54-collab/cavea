## Context

Cavea est un projet open source personnel, hébergé sur GitHub. La convention GitHub standard est un README.md en anglais à la racine. Toutefois, l'auteur et l'audience principale parlent français — un README uniquement en anglais serait artificiel. La documentation utilisateur couvre 13 scénarios complets, chacun devant exister en fr et en en.

Il n'y a aucune modification de code : ce changement crée exclusivement des fichiers Markdown.

## Goals / Non-Goals

**Goals:**
- README bilingue diffusable sans friction (fr + en)
- Documentation utilisateur versionnable dans le repo, sans outillage externe
- Structure simple, maintenable à la main par un seul auteur
- Chaque scénario existe en version française ET anglaise

**Non-Goals:**
- Site de documentation statique ou rendu HTML
- Traduction automatique (machine translation)
- Documentation de déploiement / release (chanter B séparé)
- Captures d'écran ou médias embarqués (hors scope initial)

## Decisions

### D1 — README bilingue : deux fichiers séparés

**Choix** : `README.md` principal en anglais + `README.fr.md` en français, chacun avec un lien vers l'autre en tête de fichier.

**Alternatives considérées :**
- Un seul README.md avec les deux langues (fr puis en) : simple mais difficile à lire, section h2 qui se duplique, et long
- README.md en français uniquement : non standard pour GitHub open source
- Badges de langue en HTML dans le README : complexe à maintenir, rendu inégal

**Rationale** : la convention GitHub la plus répandue est README.md en anglais + README.fr.md ou README-fr.md pour la version locale. Le lien réciproque en tête de fichier (`🇫🇷 [Version française](README.fr.md)`) rend la navigation triviale. Les deux fichiers ont exactement la même structure — maintenabilité maximale.

### D2 — Documentation utilisateur : un dossier docs/ avec sous-dossiers par langue

**Choix** : `docs/fr/` et `docs/en/`, un fichier par scénario, nommés `01-premier-demarrage.md` / `01-first-start.md`, etc. Un `docs/README.md` bilingue sert d'index et de point d'entrée.

**Alternatives considérées :**
- Un seul fichier par scénario avec fr et en côte à côte : pénible à éditer, diffs illisibles
- Wiki GitHub : non versionné dans le repo, déconnecté du code
- Scénarios intégrés dans le README : trop long, mauvaise séparation des publics

**Rationale** : une structure symétrique `docs/fr/` / `docs/en/` permet de versionner la doc avec le code, de faire des PR doc comme des PR code, et d'ajouter d'autres langues plus tard sans restructuration. La numérotation des fichiers (`01-`, `02-`, …) conserve l'ordre de lecture dans l'explorateur de fichiers et dans GitHub.

### D3 — Langue des titres de scénarios

Les noms de fichiers dans `docs/fr/` utilisent des slugs français sans accents (`01-premier-demarrage.md`), dans `docs/en/` des slugs anglais (`01-first-start.md`). L'index `docs/README.md` liste les deux colonnes côte à côte.

## Risks / Trade-offs

- [Dérive de synchronisation fr/en] → Les deux versions peuvent diverger si l'auteur n'update qu'une langue. Mitigation : tâches toujours couplées (une tâche = écrire fr ET en du même scénario).
- [README.md en anglais artificiel pour un projet 100% francophone] → Acceptable : c'est la convention open source, et la version française est à un clic.
- [Pas de rendu HTML des images] → Hors scope. La documentation texte suffit pour les 13 scénarios définis.
