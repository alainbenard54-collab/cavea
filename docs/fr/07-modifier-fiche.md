# ✏️ Modifier la fiche d'une bouteille

Modifier les informations d'une bouteille en stock (domaine, appellation, millésime, gardes, etc.).

## Prérequis

- Application ouverte en mode écriture

## Étapes

### 1. Ouvrir le panneau d'actions

Dans la vue **🍷 Stock**, appuyez sur la ligne de la bouteille à modifier.

### 2. Consulter la fiche d'abord (optionnel)

Appuyez sur **ℹ️ Consulter la fiche** pour voir toutes les informations en lecture seule avant de les modifier.

### 3. Choisir ✏️ Modifier la fiche

Appuyez sur **✏️ Modifier la fiche** dans le panneau d'actions. L'écran de modification s'ouvre.

### 4. Modifier les champs

Tous les champs non protégés sont éditables :

- Domaine, appellation, millésime, couleur, cru, contenance
- Prix d'achat, gardes min/max
- Date d'entrée, fournisseur, producteur
- Commentaire d'entrée

Les champs disposent d'autocomplétion et de menus déroulants filtrables pour les listes de référence.

### 5. Champs protégés (non éditables ici)

Ces champs ne sont **pas** dans le formulaire de modification :

| Champ | Pourquoi protégé | Comment le modifier |
|---|---|---|
| Date de consommation | Renseigné lors de la consommation | Via **🍸 Consommer** |
| Note /10 | Renseigné lors de la consommation | Via **🍸 Consommer** |
| Commentaire de dégustation | Renseigné lors de la consommation | Via **🍸 Consommer** |
| Identifiant (id) | Clé primaire — jamais modifiable | — |

### 6. Enregistrer

Appuyez sur le bouton de sauvegarde. Les modifications sont appliquées immédiatement.

## Voir aussi

- [05 — Consommer une bouteille](05-consommer.md)
- [09 — Navigation par emplacement](09-emplacements.md)
