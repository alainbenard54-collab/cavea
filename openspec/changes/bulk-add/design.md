## Context

L'application ne dispose pas encore d'interface de saisie manuelle. Les bouteilles entrent uniquement via import CSV. Ce change ajoute un écran dédié accessible depuis la navigation principale, avec un formulaire complet et une section de répartition multi-emplacement.

## Goals / Non-Goals

**Goals:**
- Formulaire complet de tous les champs non-protégés, organisé par groupes logiques
- Section répartition dynamique : groupes `(quantité, emplacement)` avec contrainte somme = total
- Autocomplétion emplacement (réutilise `getDistinctEmplacements()`)
- Insertion transactionnelle : N lignes ou 0 en cas d'erreur
- Compatible desktop et mobile (ScrollView + gestion insets clavier)

**Non-Goals:**
- Ajout de bouteilles hétérogènes en une passe (millésimes ou domaines différents)
- Formulaire d'édition d'une bouteille existante (V1)

## Decisions

### 1. Structure de l'écran

Écran complet (pas un BottomSheet) accessible via la navigation principale — le formulaire est trop long pour un sheet. Route `/bulk-add`, destination dans NavigationRail/BottomNavigationBar avec icône `add_circle_outline`.

### 2. Organisation du formulaire

Groupes de champs dans un `ListView` scrollable :

```
── Identité ──────────────────────
  Domaine*   Appellation*
  Millésime* Couleur* (dropdown)
  Cru        Contenance

── Garde & prix ──────────────────
  Garde min  Garde max  Prix achat

── Fournisseur ───────────────────
  Fournisseur nom   Fournisseur infos
  Producteur

── Commentaire ───────────────────
  Commentaire entrée (multiline)
  Date d'entrée (DatePicker, défaut = aujourd'hui)

── Répartition ───────────────────
  Quantité totale : [ N ]
  ┌────────────────────────────────┐
  │ [2] [Cave > Étagère 1    ▾] [✕]│
  │ [2] [Cave garage         ▾] [✕]│
  └────────────────────────────────┘
  + Ajouter un emplacement
  Assignées : 4 / 6  ⚠
```

### 3. Validation de la répartition

- Somme des quantités de chaque groupe == quantité totale : bloquant à la confirmation
- Chaque quantité de groupe >= 1
- Emplacement de chaque groupe validé avec le même regex que `deplacer_form.dart` : `^[a-zA-ZÀ-ÿ0-9][a-zA-ZÀ-ÿ0-9 ]*( > [a-zA-ZÀ-ÿ0-9][a-zA-ZÀ-ÿ0-9 ]*)*$`
- Champs obligatoires : domaine, appellation, millésime, couleur

### 4. Insertion en lot transactionnelle

```dart
Future<void> insertBouteilles(List<BouteillesCompanion> bouteilles) {
  return _db.transaction(() async {
    for (final b in bouteilles) {
      await _db.into(_db.bouteilles).insert(b);
    }
  });
}
```

Chaque bouteille reçoit un UUID distinct (`const Uuid().v4()`). `date_entree` = date choisie dans le formulaire (défaut aujourd'hui). `updated_at` = `DateTime.now().toIso8601String()`.

### 5. Structure de fichiers

```
lib/features/bulk_add/
  bulk_add_screen.dart       # Écran principal + formulaire
  bulk_add_controller.dart   # State Riverpod (champs + groupes répartition)
  widgets/
    repartition_row.dart     # Ligne (quantité, emplacement) avec autocomplete
```

### 6. État du formulaire

`BulkAddState` dans un `StateNotifier` Riverpod :
- Champs communs : `Map<String, dynamic>` ou classe dédiée
- `int quantiteTotal`
- `List<RepartitionGroup>` : `{int quantite, String emplacement}`
- `bool isValid` : calculé (obligatoires remplis + somme correcte)

### 7. Autocomplétion champs texte

Les champs `domaine`, `appellation`, `cru`, `contenance`, `fournisseur_nom` utilisent un widget `_AutocompleteField` (StatefulWidget avec `TextEditingController` stable) :
- Suggestions affichées en `Column` sous le champ (pas d'overlay `Overlay`) — même pattern que l'emplacement dans `RepartitionRow`
- Filtrage côté client (contains, insensible à la casse) sur les valeurs en base
- Requêtes DAO sans filtre `date_sortie` → toutes bouteilles (stock + consommées) → cohérence même si toutes les bouteilles d'un domaine ont été consommées
- Contenance : valeur par défaut "75 cl" dans `BulkAddState`

### 8. Validation de la garde

Deux règles distinctes, déclenchées au clic Confirmer (après `Form.validate()` et `isValid`) :
1. `garde_min > garde_max` si les deux sont renseignés → snackbar d'erreur, retour bloqué
2. L'un ou l'autre absent → `AlertDialog` de confirmation ; l'utilisateur peut poursuivre ou revenir pour saisir

### 9. Gestion des TextEditingController dans les widgets formulaire

Problème Flutter : `TextFormField` avec `initialValue` dans un `ListView` piloté par `ref.watch` → `TextFormField.didUpdateWidget` peut déclencher `FormState._forceRebuild` pendant le build → exception `setState() during build`.

Solutions appliquées :
- Champ quantité totale : `TextEditingController` stable (`_qtCtrl`) possédé par `_BulkAddScreenState`, `controller:` au lieu de `initialValue:` → plus de notification pendant le build
- Champ quantité dans `RepartitionRow` : changé de `TextFormField` à `TextField` (aucun validator) → `_qtyCtrl.text = newText` dans `didUpdateWidget` ne déclenche plus `FormState._fieldDidChange`
- Champ emplacement dans `RepartitionRow` : `TextEditingController` stable (`_emplacementCtrl`) → supprime le `TextEditingController(...)` créé à chaque `build()` (fuite mémoire + saut de curseur)
- `_AutocompleteField` : chaque instance possède son propre `TextEditingController` (cycle `initState`/`dispose`) → restauration du texte automatique si le widget est recyclé par `ListView`
- Autres champs via `_field` : `initialValue: state.XXX` → restauration après recycle `ListView` ; sécurisé car la valeur du controller est déjà synchronisée quand `didUpdateWidget` compare

## Risks / Trade-offs

- [Formulaire long] → `ListView` scrollable avec `keyboardDismissBehavior`. Sur Android, les `viewInsets.bottom` gèrent le clavier automatiquement avec `resizeToAvoidBottomInset: true`.
- [Couleur] → dropdown des valeurs existantes en base (`getAllDistinctCouleurs()` — toutes bouteilles) + saisie libre pour une nouvelle couleur. Évite les fautes de frappe.
- [UUID] → package `uuid` déjà présent en dépendance via drift.
