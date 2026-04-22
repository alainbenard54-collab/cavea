## Context

La vue stock a un `onTap: null` sur toutes les lignes (commentaire "futur : ouvrir la fiche" dans `stock_table.dart`). Ce change active ces taps et branche un BottomSheet contextuel. Le DAO dispose déjà de `updateBouteille(BouteillesCompanion)` qui permet une mise à jour complète ; on y ajoute deux méthodes ciblées pour la lisibilité et la sécurité (éviter d'exposer tous les champs dans chaque action).

## Goals / Non-Goals

**Goals:**
- BottomSheet accessible depuis liste mobile ET tableau desktop
- Action Déplacer : champ texte + autocomplétion sur emplacements distincts en base
- Action Consommer : date modifiable + note /10 + commentaire — seuls `date_sortie`, `note_degus`, `commentaire_degus` sont écrits
- Action Modifier fiche : stub qui affiche un SnackBar "Fonctionnalité à venir" (V1)
- Pas de navigation supplémentaire — tout se passe dans le BottomSheet

**Non-Goals:**
- Écran d'édition complète (V1)
- Suppression physique de bouteille
- Validation oenologique de la note

## Decisions

### 1. BottomSheet avec deux phases pour Déplacer et Consommer

**Structure** : le BottomSheet affiche d'abord le menu (4 items). Les actions Déplacer et Consommer remplacent le contenu du BottomSheet par le formulaire correspondant (pas de dialog supplémentaire, pas de navigation).

**Rationale** : rester dans un seul composant modal évite la superposition de layers et est cohérent sur desktop comme mobile.

### 2. Deux méthodes DAO dédiées

```dart
Future<void> deplacerBouteille(String id, String emplacement);
Future<void> consommerBouteille(String id, {
  required String dateSortie,
  int? noteDegus,
  String? commentaireDegus,
});
```

**Rationale** : `updateBouteille` accepte un `BouteillesCompanion` complet — risque de zapper des champs non fournis. Les méthodes ciblées n'écrivent que les colonnes nécessaires via `update()..where()`.

### 3. Autocomplétion emplacement : nouvelle méthode DAO

```dart
Future<List<String>> getDistinctEmplacements();
```

Retourne les emplacements distincts non vides du stock courant, triés alphabétiquement. Utilisé pour les suggestions dans le champ Déplacer.

### 4. DatePicker pour la date de consommation

`showDatePicker` Material 3 avec `initialDate: DateTime.now()`, `firstDate: DateTime(2000)`, `lastDate: DateTime.now()`. L'utilisateur ne peut pas déclarer une consommation future.

### 5. Note de dégustation : Slider /10 + affichage numérique

Slider de 0 à 10 (pas 1, valeur entière). `null` = non renseigné. Un switch ou checkbox "Noter" active/désactive le slider pour ne pas forcer une note.

### 6. Structure de fichiers

```
lib/features/bottle_actions/
  bottle_actions_sheet.dart      # BottomSheet principal (menu + routage)
  widgets/
    deplacer_form.dart           # Formulaire déplacement
    consommer_form.dart          # Formulaire consommation
```

## Risks / Trade-offs

- [Autocomplétion emplacement] → `Autocomplete<String>` Flutter standard. Si la cave a des centaines d'emplacements distincts, les suggestions seront longues — acceptable pour une cave personnelle.
- [Date consommation passée] → `lastDate: DateTime.now()` empêche les dates futures. Correct pour une déclaration réelle ou tardive.
- [Note null vs 0] → `null` = "pas de note" ; `0` = note explicite de zéro. Le Slider part à `null` par défaut.
