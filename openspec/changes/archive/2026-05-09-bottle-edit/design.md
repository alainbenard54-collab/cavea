## Context

Le BottomSheet `bottle_actions_sheet.dart` expose déjà l'entrée "Modifier la fiche" avec un callback `onModifierFiche` qui appelle un SnackBar stub. `BouteilleDao.updateBouteille()` est déjà implémenté (accepte un `BouteillesCompanion` complet). Le router go_router n'a pas de route d'édition. La logique d'autocomplétion et de validation des champs est déjà éprouvée dans `BulkAddScreen`.

Stockage : Mode 1 (dart:io direct) et Mode 2 (sync Drive) — l'édition passe par `BouteilleDao` dans les deux cas, aucun appel direct à dart:io ou StorageAdapter.

## Goals / Non-Goals

**Goals:**
- Écran d'édition de tous les champs non protégés d'une bouteille
- Autocomplétion cohérente avec `BulkAddScreen` (domaine, appellation, cru, contenance, fournisseur)
- Validation garde_min ≤ garde_max (même règle que bulk_add)
- Emplacement validé avec le même regex hiérarchique que `DeplacerForm`
- `updated_at` mis à jour automatiquement à la sauvegarde

**Non-Goals:**
- Fiche lecture seule (feature V1 distincte)
- Édition des champs protégés (`id`, `updated_at`, `date_sortie`, `note_degus`, `commentaire_degus`)
- Historique des modifications
- Édition en lot

## Decisions

**1. Route en dehors du ShellRoute**
`/bottle-edit/:id` est déclarée au niveau racine du router, hors du `ShellRoute`. L'écran s'affiche en plein écran sans NavigationRail ni BottomNavigationBar — cohérent avec un écran de détail/édition.
*Alternative écartée* : route imbriquée dans le ShellRoute — la présence du rail de navigation pendant l'édition gêne l'UX et complique le layout sur desktop.

**2. Chargement par ID via `getBouteilleById`**
Le BottomSheet passe uniquement l'`id` dans la route. `BottleEditScreen` charge la bouteille depuis la DB dans `initState` via `BouteilleDao.getBouteilleById(id)`. Les contrôleurs de champs sont initialisés à partir de la bouteille chargée.
*Alternative écartée* : passer la bouteille sérialisée dans les `extra` de go_router — fragile (perte des données au hot-reload) et couplage fort entre BottomSheet et écran d'édition.

**3. State : StatefulWidget + ConsumerWidget (Riverpod)**
Un `ConsumerStatefulWidget` porte les `TextEditingController` pour chaque champ. Riverpod est utilisé uniquement pour accéder au `BouteilleDao` et aux données d'autocomplétion (même pattern que BulkAddScreen).
Pas de state manager dédié pour ce formulaire — la complexité ne le justifie pas.

**4. Autocomplétion : réutilisation du pattern BulkAddScreen**
Les champs domaine, appellation, cru, contenance, fournisseurNom utilisent `Autocomplete<String>` avec requête asynchrone vers les méthodes `getDistinct*` du DAO. Emplacement utilise la même autocomplétion que `DeplacerForm`.

**5. Couleur : DropdownButtonFormField**
Identique à BulkAddScreen — liste issue de `ConfigService.refCouleurs`, valeur initiale pré-sélectionnée si la couleur de la bouteille est dans la liste.

**6. Millésime, gardeMin, gardeMax : TextFormField numérique**
Saisie texte avec `keyboardType: TextInputType.number`, conversion `int.tryParse` à la validation. Champs optionnels (garde) : vides si null en base.

**7. Sauvegarde : `updateBouteille` avec companion complet**
À la confirmation, tous les champs sont assemblés en `BouteillesCompanion` avec `updated_at = DateTime.now().toIso8601String()`. Appel à `BouteilleDao.updateBouteille()`. Retour à l'écran précédent (`context.pop()`) après succès.

## Risks / Trade-offs

- **Champ couleur absent de refCouleurs** → si la bouteille a une couleur non présente dans la liste de référence, le dropdown affiche la valeur actuelle comme option supplémentaire pour éviter une perte silencieuse.
- **Garde partielle (un seul champ renseigné)** → même comportement que bulk_add : dialogue de confirmation avertissant que la maturité ne sera pas calculable.
- **Perte de focus sur Android avec le clavier** → géré par `resizeToAvoidBottomInset` et `SingleChildScrollView` englobant le formulaire.
