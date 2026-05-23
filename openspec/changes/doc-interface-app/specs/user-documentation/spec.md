## MODIFIED Requirements

### Requirement: Index de la documentation utilisateur
Le repo SHALL contenir trois fichiers d'index dans `docs/` :

1. `docs/README.md` — page d'entrée minimaliste bilingue contenant uniquement un titre et deux liens vers les index par langue (`fr/` et `en/`). Ce fichier sert de point d'entrée pour les visiteurs GitHub.com.

2. `docs/fr/README.md` — index complet en français uniquement, listant les 13 scénarios avec liens relatifs vers les fichiers `fr/NN-slug.md`. Ce fichier est servi par GitHub Pages à l'URL `https://alainbenard54-collab.github.io/cavea/fr/`.

3. `docs/en/README.md` — full index in English only, listing the 13 scenarios with relative links to `en/NN-slug.md` files. This file is served by GitHub Pages at `https://alainbenard54-collab.github.io/cavea/en/`.

#### Scenario: Navigation vers un scénario depuis l'index FR
- **WHEN** un utilisateur ouvre `docs/fr/README.md` (ou l'URL `/fr/` sur GitHub Pages)
- **THEN** il voit un index listant les 13 scénarios en français avec des liens relatifs vers chaque fichier `fr/`

#### Scenario: Navigation vers un scénario depuis l'index EN
- **WHEN** a user opens `docs/en/README.md` (or the `/en/` URL on GitHub Pages)
- **THEN** they see an index listing all 13 scenarios in English with relative links to each `en/` file

#### Scenario: Page d'entrée GitHub
- **WHEN** un visiteur ouvre le dossier `docs/` sur GitHub.com
- **THEN** `docs/README.md` s'affiche avec deux liens clairs vers la documentation française et anglaise

#### Scenario: Lien depuis le README principal
- **WHEN** un utilisateur consulte `README.md` ou `README.fr.md`
- **THEN** un lien vers `docs/README.md` pointe vers la page d'entrée de la documentation
