## Context

`_BottleListBody` (`lib/features/locations/location_tree_screen.dart`) affiche toujours `ListView.separated` + `BouteilleListTile`, sans jamais consulter la largeur disponible. `StockTable` (`lib/features/stock/stock_table.dart`) existe déjà et implémente le rendu tableau triable, mais suppose un usage Stock : colonnes fixes (icône, domaine, appellation, millésime, **emplacement**, garde, prix), et `sortColumn`/`sortAscending`/`onSort` pilotés en pratique par `stockFilterProvider` (`stock_controller.dart`), qui porte aussi les filtres couleur/appellation/millésime/texte propres à l'écran Stock.

Voir proposal.md pour le problème motivant ce change.

## Goals / Non-Goals

**Goals:**
- Réutiliser `StockTable` telle quelle pour le rendu (pas de duplication de la logique de colonnes/tri/maturité)
- Masquer la colonne Emplacement dans ce contexte, sans casser l'usage existant sur l'écran Stock
- Tri par colonne indépendant du `stockFilterProvider` (l'écran Emplacements n'a pas de filtres couleur/appellation/etc.)

**Non-Goals:**
- Ajouter des filtres à l'écran Emplacements (hors périmètre, voir proposal.md)
- Persister le tri entre sessions ou entre nœuds visités

## Decisions

### D1 — Paramètre `showEmplacementColumn` sur `StockTable`

**Choix** : ajouter `final bool showEmplacementColumn` (défaut `true`) à `StockTable`. Quand `false`, la colonne Emplacement est retirée de `_layout()` (header et lignes de données), les autres colonnes gardent leurs largeurs/flex actuels.

**Pourquoi** : `StockTable` a déjà toute la logique de rendu (icône couleur, cellule GARDE colorée par maturité, sélection multiple, tri). Dupliquer ce widget pour l'écran Emplacements créerait une deuxième source de vérité à maintenir en parallèle à chaque évolution du tableau Stock (ex. ajout futur d'une colonne). Un paramètre optionnel garde un seul widget, comportement par défaut inchangé pour Stock.

**Alternative rejetée** : extraire un widget `_TableRow` générique paramétré par liste de colonnes. Sur-ingénierie pour un seul cas d'usage actuel (2 colonnes prédéfinies au lieu d'une liste dynamique) ; peut être reconsidéré si un 3e écran a besoin d'un sous-ensemble de colonnes différent.

### D2 — État de tri local à `_BottleListBody`, réutilisation de `_sorted()`

**Choix** : convertir `_BottleListBody` en widget avec état local (`sortColumn`/`sortAscending`, défaut `'domaine'`/`true`), trier la liste reçue du provider côté client avec la fonction `_sorted()` de `stock_controller.dart` (rendue accessible depuis ce fichier — elle ne dépend déjà d'aucun état de `stockFilterProvider`, seulement de `List<Bouteille>` + colonne + sens).

**Pourquoi** : `watchBouteillesParEmplacement()` (DAO) trie déjà côté SQL par domaine puis millésime — c'est un tri fixe, pas paramétrable sans changer la requête. La liste par emplacement est bornée (un seul emplacement, jamais toute la cave), donc un tri client-side sur la liste déjà chargée est largement suffisant en performance, et évite de complexifier le DAO ou de créer un second `Notifier` juste pour porter deux champs (colonne, sens) qui n'ont aucun rapport avec les filtres Stock.

**Alternative rejetée** : réutiliser `stockFilterProvider` tel quel. Rejeté — ce provider porte aussi couleurs/appellation/millésime/texte, qui n'existent pas sur cet écran ; le coupler ici créerait une dépendance croisée artificielle entre deux écrans indépendants (si un filtre Stock change de forme, l'écran Emplacements serait affecté sans raison).

### D3 — Seuil de bascule identique à Stock

**Choix** : même mécanisme que `stock_screen.dart` — `LayoutBuilder` sur la largeur disponible du contenu, seuil `>= 640`, indépendant de la plateforme et de l'orientation.

**Pourquoi** : décision utilisateur explicite — homogénéité entre Stock et Emplacements, sur toutes plateformes (Windows, Linux, Android), pas seulement en paysage Android. Un seul mécanisme à maintenir.

## Risks / Trade-offs

- **[Risque] Divergence future entre StockTable et l'usage Emplacements** si une évolution ajoute une colonne Stock-only sans considérer le cas `showEmplacementColumn: false` → mitigé par le fait que `StockTable` reste un seul widget avec un seul point de layout (`_layout()`), toute modification de colonnes est visible dans le même fichier pour les deux usages.
- **[Trade-off] Tri client-side vs SQL** : pour un emplacement avec un très grand nombre de bouteilles directes, le tri Dart en mémoire est légèrement moins efficace qu'un `ORDER BY` SQL paramétré — jugé négligeable vu le volume réaliste d'une cave personnelle (voir Non-Goals : pas de pagination envisagée).
