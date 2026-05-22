## ADDED Requirements

### Requirement: Index de la documentation utilisateur
Le repo SHALL contenir un fichier `docs/README.md` bilingue (fr + en dans le même fichier) servant d'index et de point d'entrée pour la documentation utilisateur.

L'index SHALL lister les 13 scénarios avec un lien vers chaque fichier fr et en correspondant, organisé en tableau à deux colonnes (Français / English).

#### Scenario: Navigation vers un scénario
- **WHEN** un utilisateur ouvre `docs/README.md`
- **THEN** il voit un tableau listant les 13 scénarios avec un lien vers la version française et un lien vers la version anglaise pour chacun

#### Scenario: Lien depuis le README principal
- **WHEN** un utilisateur consulte README.md ou README.fr.md
- **THEN** un lien vers `docs/README.md` pointe vers la documentation utilisateur complète

### Requirement: Structure des fichiers de scénarios
La documentation utilisateur SHALL être organisée dans `docs/fr/` (français) et `docs/en/` (anglais), avec un fichier par scénario, nommé `NN-slug.md` (ex : `01-premier-demarrage.md`, `01-first-start.md`).

Chaque fichier de scénario SHALL contenir :
- Titre h1
- Résumé en une phrase du scénario
- Prérequis (si applicable)
- Étapes numérotées avec description claire de l'action et du résultat attendu
- Section "Voir aussi" avec liens vers les scénarios connexes (si applicable)

#### Scenario: Numérotation et ordre de lecture
- **WHEN** un utilisateur liste les fichiers dans `docs/fr/` ou `docs/en/`
- **THEN** les fichiers apparaissent dans l'ordre de lecture logique (01 à 13) dans l'explorateur de fichiers et dans GitHub

#### Scenario: Symétrie fr/en
- **WHEN** les répertoires `docs/fr/` et `docs/en/` sont comparés
- **THEN** ils contiennent exactement le même nombre de fichiers, avec les mêmes numéros de préfixe

### Requirement: Scénario 01 — Premier démarrage
`docs/fr/01-premier-demarrage.md` et `docs/en/01-first-start.md` SHALL documenter le flux de premier démarrage : choix du mode (local ou partagé), configuration du chemin de la cave, connexion cloud si Mode Partagé.

#### Scenario: Mode local décrit
- **WHEN** un utilisateur lit le scénario 01
- **THEN** il comprend comment configurer le chemin vers son fichier cave.db en Mode Local (PC seul)

#### Scenario: Mode partagé décrit
- **WHEN** un utilisateur lit le scénario 01
- **THEN** il comprend comment connecter Google Drive ou Dropbox pour le Mode Partagé et ce que signifie le verrou automatique

### Requirement: Scénario 02 — Ajouter des bouteilles
`docs/fr/02-ajout-bouteilles.md` et `docs/en/02-add-bottles.md` SHALL documenter le formulaire d'ajout en lot : champs communs, quantité totale, répartition multi-emplacement, validation garde min/max.

#### Scenario: Répartition multi-emplacement expliquée
- **WHEN** un utilisateur lit le scénario 02
- **THEN** il comprend comment répartir un lot entre plusieurs emplacements et que chaque bouteille physique crée une ligne distincte en base

### Requirement: Scénario 03 — Consulter le stock
`docs/fr/03-stock.md` et `docs/en/03-stock.md` SHALL documenter la vue stock : filtres (couleur, maturité, appellation, millésime, texte), tri, différence entre vue table desktop et liste mobile.

#### Scenario: Filtres décrits
- **WHEN** un utilisateur lit le scénario 03
- **THEN** il comprend comment combiner les filtres couleur, maturité, appellation, millésime et texte libre

### Requirement: Scénario 04 — Maturité
`docs/fr/04-maturite.md` et `docs/en/04-maturity.md` SHALL documenter les niveaux de maturité (trop jeune / optimal / à boire urgent / sans données), le calcul (millésime + garde_min/max vs année courante), le filtre maturité et le tri par urgence.

#### Scenario: Calcul de maturité expliqué
- **WHEN** un utilisateur lit le scénario 04
- **THEN** il comprend que la maturité est calculée à la volée à partir du millésime et des gardes, sans donnée stockée

### Requirement: Scénario 05 — Consommer une bouteille
`docs/fr/05-consommer.md` et `docs/en/05-consume.md` SHALL documenter le flux de consommation via le BottomSheet : date de consommation (défaut aujourd'hui, modifiable), note /10 optionnelle, commentaire de dégustation optionnel.

#### Scenario: Déclaration tardive
- **WHEN** un utilisateur lit le scénario 05
- **THEN** il sait qu'il peut renseigner une date de consommation passée (déclaration tardive)

### Requirement: Scénario 06 — Déplacer une bouteille
`docs/fr/06-deplacer.md` et `docs/en/06-move.md` SHALL documenter le déplacement d'une bouteille via le BottomSheet : saisie libre avec autocomplétion, distinction déplacer ≠ consommer.

#### Scenario: Distinction déplacer/consommer
- **WHEN** un utilisateur lit le scénario 06
- **THEN** il comprend que déplacer ne change pas la date de sortie et que la bouteille reste en stock

### Requirement: Scénario 07 — Modifier la fiche
`docs/fr/07-modifier-fiche.md` et `docs/en/07-edit-bottle.md` SHALL documenter l'accès à l'écran de modification via le BottomSheet, les champs éditables et les champs protégés (date_sortie, note_degus, commentaire_degus — accessibles uniquement via Consommer).

#### Scenario: Champs protégés expliqués
- **WHEN** un utilisateur lit le scénario 07
- **THEN** il comprend pourquoi certains champs n'apparaissent pas dans le formulaire d'édition

### Requirement: Scénario 08 — Sélection multiple
`docs/fr/08-selection-multiple.md` et `docs/en/08-multi-select.md` SHALL documenter l'appui long pour entrer en mode sélection, la barre d'actions contextuelle (Déplacer / Consommer en lot), et la désactivation en Mode Lecture Seule.

#### Scenario: Appui long décrit
- **WHEN** un utilisateur lit le scénario 08
- **THEN** il sait qu'un appui long sur une ligne active le mode sélection multiple

### Requirement: Scénario 09 — Navigation par emplacement
`docs/fr/09-emplacements.md` et `docs/en/09-locations.md` SHALL documenter l'onglet Emplacements : arbre hiérarchique, fil d'ariane cliquable, statistiques (bouteilles + valeur) par nœud, liste directe vs sous-emplacements.

#### Scenario: Fil d'ariane cliquable
- **WHEN** un utilisateur lit le scénario 09
- **THEN** il comprend qu'il peut naviguer directement vers n'importe quel niveau de l'arbre en cliquant sur le fil d'ariane

### Requirement: Scénario 10 — Historique des consommations
`docs/fr/10-historique.md` et `docs/en/10-history.md` SHALL documenter l'onglet Historique : liste des bouteilles consommées, tri par date, recherche texte, BottomSheet détail, action Réhabiliter.

#### Scenario: Réhabiliter une bouteille
- **WHEN** un utilisateur lit le scénario 10
- **THEN** il sait qu'il est possible de remettre en stock une bouteille marquée comme consommée via l'action Réhabiliter

### Requirement: Scénario 11 — Import/Export CSV
`docs/fr/11-import-export.md` et `docs/en/11-import-export.md` SHALL documenter l'onglet Données : import CSV (séparateur configurable, conservation de updated_at), export CSV (scope stock/tout, séparateur configurable, FilePicker Windows / share_plus Android).

#### Scenario: Options de séparateur
- **WHEN** un utilisateur lit le scénario 11
- **THEN** il comprend les options de séparateur (`;` / `,` / tabulation) et quand les utiliser

### Requirement: Scénario 12 — Mode Partagé
`docs/fr/12-mode-partage.md` et `docs/en/12-shared-mode.md` SHALL documenter le Mode Partagé complet : verrou automatique au démarrage, libération à la fermeture (PC) ou bouton Quitter (Android), mode lecture seule quand verrou détenu par un autre appareil, synchronisation manuelle, indicateurs dans l'AppBar.

#### Scenario: Verrou automatique expliqué
- **WHEN** un utilisateur lit le scénario 12
- **THEN** il comprend que le verrou est acquis automatiquement au démarrage et libéré à la fermeture propre, et ce qui se passe si l'application plante

#### Scenario: Mode lecture seule décrit
- **WHEN** un utilisateur lit le scénario 12
- **THEN** il sait quelles fonctionnalités restent accessibles en mode lecture seule (stock, fiche bouteille, historique, emplacements, paramètres) et lesquelles sont bloquées (ajout, consommer, déplacer, import)

### Requirement: Scénario 13 — Paramètres
`docs/fr/13-parametres.md` et `docs/en/13-settings.md` SHALL documenter l'écran Paramètres : chemin cave.db (Mode Local), couleur et contenance par défaut pour l'ajout en lot, listes de référence éditables (couleurs, contenances, crus), changement de fournisseur cloud.

#### Scenario: Listes de référence
- **WHEN** un utilisateur lit le scénario 13
- **THEN** il comprend comment ajouter ou supprimer des valeurs dans les listes de référence et comment elles s'intègrent dans le formulaire d'ajout
