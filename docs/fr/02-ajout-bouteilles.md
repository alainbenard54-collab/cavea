# ➕ Ajouter des bouteilles

Ajouter des bouteilles en lot via le formulaire d'ajout : renseigner les champs communs, définir la quantité totale et répartir entre plusieurs emplacements.

## Prérequis

- Application ouverte en mode écriture (Mode Local, ou 🔄 Mode Partagé avec le verrou)

## Étapes

### 1. Ouvrir le formulaire d'ajout

Appuyez sur l'onglet **➕ Ajouter** dans la navigation.

> En 🔄 Mode Partagé lecture seule, cet onglet est grisé (🔒) — vous devez fermer l'autre appareil qui a le verrou d'abord.

### 2. Remplir les champs communs

Ces informations s'appliquent à toutes les bouteilles du lot.

**Section Identité**

| Champ | Obligatoire | Notes |
|---|---|---|
| Domaine | **Oui** | Autocomplétion sur les valeurs existantes |
| Appellation | **Oui** | Autocomplétion |
| Millésime | **Oui** | Année numérique (ex : 2019) |
| Couleur | **Oui** | Liste de référence configurable dans ⚙️ Paramètres |
| Cru | Non | Liste de référence configurable |
| Contenance | Non | Défaut "75 cl" (configurable dans ⚙️ Paramètres) |

**Section Garde**

| Champ | Obligatoire | Notes |
|---|---|---|
| Garde min | Non | Nombre d'années avant l'optimum |
| Garde max | Non | Nombre d'années jusqu'à la fin de garde |
| Prix d'achat | Non | Par bouteille |

**Section Fournisseur**

| Champ | Obligatoire | Notes |
|---|---|---|
| Fournisseur | Non | Autocomplétion |
| Infos fournisseur | Non | Adresse, contact, etc. |
| Producteur | Non | Autocomplétion |

**Section Commentaire**

| Champ | Obligatoire | Notes |
|---|---|---|
| Commentaire d'entrée | Non | Commentaire libre à l'achat |
| Date d'entrée | Non | Défaut : aujourd'hui |

### 3. Définir la quantité totale

Saisissez le nombre total de bouteilles à ajouter dans le champ **Quantité totale**.

### 4. Répartir entre les emplacements

La section **Répartition** distribue les bouteilles dans les zones de votre cave.

- Chaque groupe = `(quantité, emplacement)`
- L'emplacement propose l'autocomplétion sur vos emplacements existants
- La somme des quantités dans la répartition doit être **égale** à la quantité totale (indicateur de validation affiché en temps réel)
- Si toutes les bouteilles vont au même endroit, laissez un seul groupe

**Format d'emplacement** : `Niveau1` ou `Niveau1 > Niveau2 > Niveau3`

Exemples : `Cave`, `Cave > Casiers > A1`, `Réserve`

### 5. Validation des gardes

- Si `garde_min` et `garde_max` sont tous les deux renseignés : `garde_min ≤ garde_max` est vérifié — une erreur s'affiche sinon et l'enregistrement est bloqué
- Si l'un des deux est absent : une boîte de dialogue vous avertit que la maturité ne pourra pas être calculée. Choisissez **Confirmer sans garde** ou **Retour**

### 6. Enregistrer

Appuyez sur **Ajouter N bouteille(s)**. L'application crée une ligne distincte en base pour chaque bouteille physique, avec un identifiant unique.

## Voir aussi

- [03 — Consulter le stock](03-stock.md)
- [04 — Maturité](04-maturite.md)
- [13 — Paramètres](13-parametres.md) (listes de référence, valeurs par défaut)
