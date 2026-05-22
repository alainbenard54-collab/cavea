## 1. Structure des fichiers

- [x] 1.1 Créer le répertoire `docs/` à la racine du repo
- [x] 1.2 Créer les sous-répertoires `docs/fr/` et `docs/en/`
- [x] 1.3 Créer `docs/README.md` — index bilingue avec tableau fr/en des 13 scénarios et liens vers chaque fichier

## 2. README bilingue

- [x] 2.1 Rédiger `README.md` en anglais — sections : Philosophy, Deployment modes (Local + Shared avec explication du verrou), Platforms, Tech stack, Build, OAuth configuration, License
- [x] 2.2 Rédiger `README.fr.md` en français — même structure que README.md, lien réciproque en tête de fichier
- [x] 2.3 Ajouter dans README.md et README.fr.md un lien vers `docs/README.md` pour la documentation utilisateur complète

## 3. Documentation utilisateur — scénarios 01 à 05

- [x] 3.1 Rédiger `docs/fr/01-premier-demarrage.md` et `docs/en/01-first-start.md` — choix du mode, chemin cave.db, connexion cloud
- [x] 3.2 Rédiger `docs/fr/02-ajout-bouteilles.md` et `docs/en/02-add-bottles.md` — formulaire bulk-add, champs communs, répartition multi-emplacement, validation garde
- [x] 3.3 Rédiger `docs/fr/03-stock.md` et `docs/en/03-stock.md` — filtres, tri, différence table desktop / liste mobile
- [x] 3.4 Rédiger `docs/fr/04-maturite.md` et `docs/en/04-maturity.md` — niveaux de maturité, calcul, filtre, tri par urgence
- [x] 3.5 Rédiger `docs/fr/05-consommer.md` et `docs/en/05-consume.md` — BottomSheet consommation, date modifiable, note /10, commentaire

## 4. Documentation utilisateur — scénarios 06 à 10

- [x] 4.1 Rédiger `docs/fr/06-deplacer.md` et `docs/en/06-move.md` — BottomSheet déplacer, autocomplétion, distinction déplacer ≠ consommer
- [x] 4.2 Rédiger `docs/fr/07-modifier-fiche.md` et `docs/en/07-edit-bottle.md` — accès via BottomSheet, champs éditables, champs protégés
- [x] 4.3 Rédiger `docs/fr/08-selection-multiple.md` et `docs/en/08-multi-select.md` — appui long, barre d'actions, déplacer/consommer en lot, désactivé en lecture seule
- [x] 4.4 Rédiger `docs/fr/09-emplacements.md` et `docs/en/09-locations.md` — arbre hiérarchique, fil d'ariane cliquable, statistiques, bouteilles directes vs sous-emplacements
- [x] 4.5 Rédiger `docs/fr/10-historique.md` et `docs/en/10-history.md` — liste consommations, tri date, recherche, Réhabiliter

## 5. Documentation utilisateur — scénarios 11 à 13

- [x] 5.1 Rédiger `docs/fr/11-import-export.md` et `docs/en/11-import-export.md` — import CSV (séparateur, updated_at), export CSV (scope, séparateur, FilePicker Windows / share_plus Android)
- [x] 5.2 Rédiger `docs/fr/12-mode-partage.md` et `docs/en/12-shared-mode.md` — verrou auto démarrage/fermeture, bouton Quitter Android (Mode 2), lecture seule, sync manuelle, indicateurs AppBar, crash recovery
- [x] 5.3 Rédiger `docs/fr/13-parametres.md` et `docs/en/13-settings.md` — chemin cave.db (Mode Local), couleur/contenance par défaut, listes de référence éditables, changer de fournisseur cloud

## 6. Liens et cohérence

- [x] 6.1 Vérifier que chaque scénario contient une section "Voir aussi" / "See also" avec liens vers les scénarios connexes
- [x] 6.2 Vérifier que `docs/README.md` liste bien les 13 scénarios avec liens fr et en fonctionnels
- [x] 6.3 Vérifier que README.md et README.fr.md ont exactement les mêmes sections dans le même ordre
