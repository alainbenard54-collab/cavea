### Requirement: Écran fiche bouteille lecture seule
L'application SHALL fournir un écran `BottleDetailScreen` accessible via la route `/bottle/:id` affichant toutes les informations d'une bouteille en mode lecture seule. Aucun champ ne SHALL être modifiable depuis cet écran.

#### Scenario: Affichage fiche bouteille en stock
- **WHEN** l'utilisateur navigue vers `/bottle/:id` pour une bouteille dont `date_sortie` est vide
- **THEN** l'écran affiche les sections Identité, Contenant, Acquisition, Garde et Notes entrée ; les sections Consommation (`note_degus`, `commentaire_degus`) sont masquées

#### Scenario: Affichage fiche bouteille consommée
- **WHEN** l'utilisateur navigue vers `/bottle/:id` pour une bouteille dont `date_sortie` est renseignée
- **THEN** l'écran affiche toutes les sections incluant Consommation avec `date_sortie`, `note_degus` et `commentaire_degus`

#### Scenario: Bouteille introuvable
- **WHEN** l'utilisateur navigue vers `/bottle/:id` avec un `id` inexistant en base
- **THEN** un message d'erreur est affiché ("Bouteille introuvable") et un bouton "Retour" permet de revenir à l'écran précédent

---

### Requirement: Champs techniques exclus de la fiche
L'application SHALL ne jamais afficher `id` et `updated_at` dans `BottleDetailScreen`, ces champs n'ayant aucune valeur pour l'utilisateur final.

#### Scenario: Vérification champs techniques absents
- **WHEN** la fiche bouteille est affichée
- **THEN** aucun champ `id` (UUID) ni `updated_at` (timestamp) n'apparaît dans l'interface

---

### Requirement: Maturité affichée sur la fiche
L'application SHALL afficher la maturité calculée de la bouteille (badge coloré) dans la section Garde, en complément de `garde_min` et `garde_max`.

#### Scenario: Badge maturité bouteille en stock
- **WHEN** la fiche d'une bouteille en stock est affichée avec `garde_min` et `garde_max` renseignés
- **THEN** un badge coloré (bleu/vert/rouge) indiquant le statut de maturité est visible dans la section Garde

#### Scenario: Badge maturité sans données de garde
- **WHEN** la fiche d'une bouteille est affichée sans `garde_min` ou `garde_max`
- **THEN** un badge gris "Sans données" est affiché à la place
