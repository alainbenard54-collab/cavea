## Context

La vue stock actuelle utilise des dropdowns mono-sélect pour les filtres et n'affiche aucune information de maturité. Le module `quoi_boire` créé à l'étape 3 est redondant et fragmenté. Ce change fusionne les deux vues, enrichit le tableau desktop, et améliore l'ergonomie des filtres.

État du code à modifier :
- `stock_controller.dart` : `StockFilterState.couleur: String?` → devient `Set<String>`
- `stock_table.dart` : colonne GARDE affiche `from–to` texte neutre → devient colorée avec delta
- `stock_screen.dart` : dropdowns → FilterChips multi-sélect
- `bouteille_dao.dart` : `watchStockFiltered(couleur: String?)` → accepte `List<String>? couleurs`
- `maturity_service.dart` : ajouter `urgencyScore()` pour le tri secondaire

## Goals / Non-Goals

**Goals:**
- Une seule vue stock qui répond à "qu'est-ce que j'ai ?" et "qu'est-ce que je dois boire ?"
- Filtre couleur multi-sélect (FilterChips, scrollable horizontal)
- Filtre maturité avec chips colorés selon le niveau
- Colonne GARDE colorée selon maturité + delta affiché
- Tri secondaire par urgence dans chaque groupe de maturité
- Suppression complète du module `quoi_boire`

**Non-Goals:**
- Actions consommer / déplacer (MVP étapes 4 et 6)
- Tri de colonne "Maturité" cliquable (le tri secondaire est automatique)
- Persistance des filtres entre sessions

## Decisions

### 1. Multi-sélect couleur : `Set<String>` dans le state + `IN` SQL

**Décision** : `StockFilterState.couleurs: Set<String>` (ensemble vide = pas de filtre).  
`watchStockFiltered` accepte `List<String>? couleurs`, traduit en `b.couleur.isIn(couleurs)`.

**Rationale** : La liste de couleurs est courte (5-8 valeurs), les FilterChips sont le composant Material adapté. `Set` évite les doublons, `isIn()` génère un `WHERE couleur IN (...)` propre.

### 2. Filtre maturité : appliqué en Dart sur la liste déjà filtrée

**Décision** : Le filtre maturité (`MaturityLevel?`) est appliqué **après** le stream SQL, dans le provider, en filtrant la liste en mémoire.

**Rationale** : La maturité n'est pas une colonne SQL, elle est calculée à la volée. Filtrer en Dart sur une liste déjà chargée est simple et suffisant.

### 3. Tri secondaire par urgence, activé quand filtre maturité présent OU par défaut

**Décision** : Quand aucun tri de colonne explicite n'est actif (`sortColumn == 'maturity'`), la liste est triée par :
1. Ordre de niveau : `aBoireUrgent(0) → optimal(1) → tropJeune(2) → sansDonnee(3)`
2. Score d'urgence secondaire :
   - `aBoireUrgent` : `age - gardeMax` décroissant (plus en retard = plus haut)
   - `optimal` : `gardeMax - age` croissant (plus proche de la limite = plus haut)
   - `tropJeune` : `gardeMin - age` croissant (plus proche de la maturité = plus haut)

**Déclenchement** : automatique quand le filtre maturité est actif. Le tri de colonne cliquable reste disponible pour les autres colonnes.

### 4. Colonne GARDE colorée : fond de cellule + delta

**Format** :
- `aBoireUrgent` : fond rouge pâle, texte `2015–2025\n+3 ans`
- `optimal` : fond vert pâle, texte `2015–2025\n-1 an`
- `tropJeune` : fond bleu pâle, texte `2015–2025\ndans 4 ans`
- `sansDonnee` : fond neutre, texte `2015–2025` ou `—`

Le delta est calculé dans `StockTable` via `computeMaturity` + score d'urgence.

### 5. Filtres avancés repliables

**Décision** : `ExpansionTile` "Filtres avancés" contenant le dropdown millésime + appellation.

**Rationale** : Les filtres couleur et maturité couvrent 80% des usages. Millésime et appellation sont des filtres précis moins fréquents.

### 6. Structure de fichiers — suppressions

```
SUPPRIMÉ :
  lib/features/quoi_boire/          (module entier)

MODIFIÉ :
  lib/core/maturity/maturity_service.dart   (+ urgencyScore)
  lib/data/daos/bouteille_dao.dart          (couleurs multi-sélect)
  lib/features/stock/stock_controller.dart  (nouveau state + tri)
  lib/features/stock/stock_screen.dart      (UI filtres)
  lib/features/stock/stock_table.dart       (colonne GARDE colorée)
  lib/shared/adaptive_layout.dart           (- destination quoi-boire)
  lib/app/router.dart                       (- route /quoi-boire)
```

## Risks / Trade-offs

- [Suppression quoi_boire] → Le change `quoi-boire` dans openspec sera archivé avec la note "remplacé par stock-maturity". Aucune perte de spec.
- [Filtre maturité + filtre couleur simultanés] → AND logique : la liste SQL est filtrée par couleurs, puis en mémoire par maturité. Cohérent avec le reste.
- [Largeur colonne GARDE] → Le delta ajoute du texte. Augmenter `_wGarde` de 96 à 110px si nécessaire.
