## MODIFIED Requirements

### Requirement: Action Modifier la fiche (interface prête, MVP stub)
L'application SHALL exposer une entrée "Modifier la fiche" dans le BottomSheet. En V1, cette entrée SHALL naviguer vers l'écran d'édition complète `BottleEditScreen` via la route `/bottle-edit/:id`. Le stub "Fonctionnalité à venir" est supprimé.

**Champs protégés — jamais exposés dans le formulaire d'édition :**
- `id` (clé primaire)
- `updated_at` (auto-géré)
- `date_sortie` (uniquement via action Consommer)
- `note_degus` (uniquement via action Consommer)
- `commentaire_degus` (uniquement via action Consommer)

#### Scenario: Clic sur Modifier la fiche (V1)
- **WHEN** l'utilisateur appuie sur "Modifier la fiche" dans le BottomSheet
- **THEN** le BottomSheet se ferme et `BottleEditScreen` s'ouvre avec les données actuelles de la bouteille
