## Purpose

Détecter les régressions visuelles majeures (disparition d'élément, changement de couleur significatif, désalignement de layout) sur un sous-ensemble représentatif d'écrans, via des golden tests Flutter comparant le rendu réel à une référence versionnée dans le dépôt.

## ADDED Requirements

### Requirement: Golden tests sur le premier jeu d'écrans représentatifs
Le système SHALL fournir des golden tests pour les écrans Stock (table + liste), Emplacements (arbre), Fiche bouteille + BottomSheet actions, et Formulaire bulk-add, chacun rendu avec des données Riverpod statiques déterministes et la locale `fr`.

#### Scenario: Golden test Stock — rendu conforme à la référence
- **WHEN** le widget Stock (table desktop et liste mobile) est rendu avec un jeu de données de test fixe
- **THEN** le rendu correspond pixel pour pixel à l'image de référence versionnée dans `test/golden/stock/`

#### Scenario: Golden test Emplacements — rendu conforme à la référence
- **WHEN** le widget Emplacements (arbre de navigation) est rendu avec un jeu de données de test fixe
- **THEN** le rendu correspond pixel pour pixel à l'image de référence versionnée dans `test/golden/emplacements/`

#### Scenario: Golden test Fiche bouteille + BottomSheet — rendu conforme à la référence
- **WHEN** la fiche bouteille et le BottomSheet d'actions sont rendus avec une bouteille de test fixe
- **THEN** le rendu correspond pixel pour pixel à l'image de référence versionnée dans `test/golden/bottle_detail/`

#### Scenario: Golden test Formulaire bulk-add — rendu conforme à la référence
- **WHEN** le formulaire bulk-add est rendu dans son état initial déterministe
- **THEN** le rendu correspond pixel pour pixel à l'image de référence versionnée dans `test/golden/bulk_add/`

#### Scenario: Régression visuelle détectée — test en échec
- **WHEN** un changement de code modifie visuellement un écran couvert (couleur, position, élément manquant) sans mise à jour de la référence
- **THEN** le golden test correspondant échoue avec un diff visuel exploitable

### Requirement: Références golden versionnées et régénérables volontairement
Les images de référence golden SHALL être stockées sous `test/golden/<écran>/`, versionnées dans le dépôt Git, et régénérables via une commande documentée (`flutter test --update-goldens`, exécutée sous Windows natif — seul environnement de référence retenu pour ce premier jeu).

#### Scenario: Régénération volontaire après changement visuel intentionnel
- **WHEN** un développeur modifie intentionnellement l'apparence d'un écran couvert et exécute `flutter test --update-goldens` sous Windows
- **THEN** les fichiers de référence sous `test/golden/<écran>/` sont mis à jour et committables

#### Scenario: Absence de comparaison inter-OS
- **WHEN** les golden tests sont exécutés sur un OS autre que Windows (ex. Linux)
- **THEN** aucune référence dédiée à cet OS n'existe — ce cas n'est pas couvert par ce premier jeu (voir design.md, hors périmètre explicite)
