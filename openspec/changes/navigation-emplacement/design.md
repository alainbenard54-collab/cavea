## Context

La vue stock liste toutes les bouteilles en stock sans regroupement spatial. L'emplacement est stocké comme une chaîne hiérarchique (`Niveau1 > Niveau2 > Niveau3`, séparateur ` > `) dans la colonne `emplacement` (NOT NULL). Il n'existe pas aujourd'hui de requête agrégeant les bouteilles par emplacement.

## Goals / Non-Goals

**Goals:**
- Arbre hiérarchique navigable des emplacements avec stats (count + valeur prix_achat)
- Toggle "Inclure sous-emplacements" pour agréger les stats des enfants dans le parent
- Liste des bouteilles d'un nœud feuille avec les mêmes actions que le stock
- Onglet dédié dans NavigationRail (Windows) et BottomBar (Android)

**Non-Goals:**
- Modifier les emplacements depuis cet écran
- Renommer ou fusionner des emplacements en masse
- Navigation "push" vers la vue stock avec filtre actif (la liste bouteilles vit dans l'écran emplacements)

## Decisions

### D1 — Requête SQL unique + construction de l'arbre en Dart

**Décision :** Une seule requête `SELECT emplacement, COUNT(*), SUM(prix_achat) FROM bouteilles WHERE date_sortie IS NULL GROUP BY emplacement` retourne les feuilles avec leurs stats. L'arbre est reconstruit en Dart par split sur ` > `.

**Alternative écartée :** Plusieurs requêtes filtrées par préfixe. Plus simple en SQL mais N+1 à chaque tap de navigation.

**Rationale :** La requête unique charge toutes les données en mémoire (au maximum quelques centaines de nœuds feuilles). La construction de l'arbre est O(n·d) avec d = profondeur max (3). Adapté à la taille d'une cave personnelle.

### D2 — Navigation interne avec Navigator.push dans l'onglet

**Décision :** Navigation dans l'arbre via `Navigator.push` local (pas de routes go_router pour les nœuds intermédiaires). Seule la route racine `/locations` est déclarée dans go_router.

**Alternative écartée :** Routes go_router `/locations/:path` pour chaque nœud. Utile pour les deep links — non requis ici.

**Rationale :** L'arbre d'emplacements est une navigation self-contained. Navigator.push évite la complexité d'encoder/décoder les chemins d'emplacements dans les URLs.

### D3 — Provider Riverpod dédié avec stream drift

**Décision :** `locationStatsProvider` — `StreamProvider<List<LocationLeaf>>` basé sur un stream drift `watchLocationStats()` dans `BouteilleDao`.

**Rationale :** Cohérent avec le pattern existant (tous les providers stock utilisent des streams drift). Les mises à jour en temps réel (ex. après un "Consommer" dans la liste bouteilles) se propagent automatiquement.

### D4 — Réutilisation du stock existant pour la liste bouteilles

**Décision :** La liste de bouteilles d'un nœud feuille utilise `bouteillesEnStockStream()` filtré par emplacement exact (LIKE avec wildcards si toggle "Inclure sous-emplacements" actif). Affiche les mêmes `BottleListTile` et le même `BottomSheet` que la vue stock.

**Rationale :** Pas de duplication de logique d'affichage. Le mode lecture seule (SyncReadOnly) est géré automatiquement par le même BottomSheet.

### D5 — Toggle "Inclure sous-emplacements" état local (pas persisté)

**Décision :** Toggle géré par un `StateProvider` local à l'écran, réinitialisé à chaque ouverture de l'onglet.

**Rationale :** Préférence d'affichage contextuelle (inventaire vs. consultation), pas une config utilisateur permanente.

## Risks / Trade-offs

- [Performance] Si la cave contient des milliers de bouteilles avec des centaines d'emplacements distincts, le chargement initial peut être perceptible → Acceptable pour une cave personnelle ; le stream drift affiche un état de chargement.
- [Cohérence] Les stats s'agrègent sur `prix_achat` qui peut être NULL (champ optionnel) → Afficher la somme des valeurs renseignées sans signaler les nulls (comportement silencieux, cohérent avec le reste de l'app).
- [Onglet supplémentaire Android] La BottomBar passe de 4 à 5 icônes de navigation principales → Vérifier que les labels restent lisibles sur petits écrans ; icône `Icons.shelves` ou `Icons.inventory_2`.

## Migration Plan

Pas de migration de base de données. Nouvelle requête drift uniquement.

Déploiement : ajout de l'onglet dans `adaptive_layout.dart`, nouvelles routes dans `router.dart`, nouveau provider dans `lib/features/locations/`.
