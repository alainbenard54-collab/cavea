## Context

`BottleEditScreen` existe et affiche tous les champs éditables d'une bouteille via des `TextFormField`. Aucune vue lecture seule n'est accessible depuis le BottomSheet, ce qui empêche l'utilisateur de consulter le détail d'une bouteille — en particulier en mode `SyncReadOnly` où l'édition est verrouillée. Cette feature ajoute `BottleDetailScreen`, un écran de consultation pure, et étend le BottomSheet avec une nouvelle action "Consulter la fiche".

## Goals / Non-Goals

**Goals:**
- Créer `BottleDetailScreen` (`lib/ui/screens/bottle_detail_screen.dart`) affichant tous les champs utiles d'une bouteille en lecture seule
- Ajouter la route `/bottle/:id` dans le router go_router existant
- Ajouter l'action "Consulter la fiche" dans le BottomSheet, accessible en mode normal et `SyncReadOnly`
- Réordonner les actions : Consommer → Consulter la fiche → Déplacer → Modifier la fiche → Annuler
- Masquer `note_degus` et `commentaire_degus` quand `date_sortie` est vide (bouteille en stock)
- Mettre à jour le comportement `SyncReadOnly` du BottomSheet : afficher "Consulter la fiche" + "Fermer"

**Non-Goals:**
- Refactorisation complète de `BottleEditScreen`
- Extraction de widgets partagés complexes entre édition et consultation (le risque de coupler les deux états dépasse le bénéfice)
- Accès à `BottleDetailScreen` depuis d'autres points de navigation (historique consommations, etc.)

## Decisions

### D1 — Implémentation indépendante vs widgets partagés

**Choix : `BottleDetailScreen` implémente son propre layout sans partager les widgets de `BottleEditScreen`.**

`BottleEditScreen` utilise des `TextFormField` avec controllers, validators et state. Partager ces widgets en mode "disabled" introduirait du state inutile, des controllers à gérer et un risque de régression. La vue lecture seule n'a besoin que de `Text` + `Card`/`ListTile` — des widgets sans state. La duplication du layout (sections, espacements) est préférable au couplage avec un formulaire stateful.

Alternatives considérées :
- `TextFormField(enabled: false, ...)` partout dans `BottleEditScreen` avec un flag `readOnly` → risque de régression, controllers inutiles, comportement visuel mal maîtrisé
- Widget `BottleFieldSection` partagé → abstraction prématurée pour deux écrans aux besoins très différents

### D2 — Route `/bottle/:id` vs paramètre sur `/bottle-edit/:id`

**Choix : nouvelle route `/bottle/:id` distincte.**

Ajouter un paramètre `?mode=view` à la route existante mélangerait deux états dans un seul écran et compliquerait `BottleEditScreen`. Une route dédiée est plus claire, plus testable et plus cohérente avec go_router.

### D3 — Données : watchBottleById vs lecture unique

**Choix : `ref.watch(bottleByIdProvider(id))` (stream réactif drift).**

Le provider de lecture unique via stream est déjà disponible ou trivial à créer depuis `BouteillesDao`. Cela garantit que la fiche se met à jour si la bouteille est modifiée en arrière-plan (sync Mode 2). Pas besoin d'un provider dédié si `bottleByIdProvider` est déjà exposé.

### D4 — Champs à afficher

Tous les champs non-techniques, organisés en sections lisibles :

| Section | Champs |
|---|---|
| Identité | domaine, appellation, millesime, couleur, cru |
| Contenant | contenance, emplacement |
| Acquisition | date_entree, prix_achat, fournisseur_nom, fournisseur_infos, producteur |
| Garde | garde_min, garde_max (+ maturité calculée affichée en badge coloré) |
| Notes entrée | commentaire_entree |
| Consommation *(si date_sortie renseignée)* | date_sortie, note_degus, commentaire_degus |

`id` et `updated_at` : jamais affichés (techniques, sans intérêt utilisateur).

## Risks / Trade-offs

- **[Risque] Duplication du layout** → Acceptable : le layout est simple (labels + valeurs) et les deux écrans évoluent indépendamment. Si un refactoring s'impose plus tard (V2), ce sera plus évident à ce moment-là.
- **[Risque] Route `/bottle/:id` entre en conflit avec une future route** → Faible : l'espace de routes actuel est sparse. La convention `:id` UUID est suffisamment unique.
- **[Trade-off] Pas de bouton "Modifier" dans `BottleDetailScreen`** → Choix délibéré : l'accès à l'édition reste via le BottomSheet uniquement. La fiche reste strictement consultative.
