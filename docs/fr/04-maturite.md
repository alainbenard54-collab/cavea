# 🍷 Maturité

Comprendre les niveaux de maturité, utiliser le filtre maturité et trier les bouteilles par urgence.

## Comment la maturité est calculée

La maturité est calculée automatiquement à chaque affichage, à partir du millésime et des gardes saisies :

| Condition | Niveau | Couleur |
|---|---|---|
| `année_courante < millésime + garde_min` | Trop jeune | 🔵 Bleu |
| `millésime + garde_min ≤ année_courante ≤ millésime + garde_max` | Optimal | 🟢 Vert |
| `année_courante > millésime + garde_max` | À boire d'urgence | 🔴 Rouge |
| garde_min ou garde_max absent | Sans données | ⚫ Gris |

Exemples avec millésime 2015, garde_min 5, garde_max 10 :
- En 2019 → 🔵 Trop jeune (2020 est la première année optimale)
- En 2022 → 🟢 Optimal
- En 2026 → 🔴 À boire d'urgence

> **garde_min = 0** est une valeur légitime : la bouteille est buvable dès le millésime.

## Filtrer par maturité

Dans la vue **🍷 Stock**, utilisez le filtre **Maturité** (multi-sélect) pour n'afficher que les niveaux souhaités. Exemples :
- Cocher 🟢 "Optimal" + 🔴 "À boire" → bouteilles prêtes à boire maintenant
- Cocher 🔵 "Trop jeune" → bouteilles à garder encore

## Tri par urgence

Dans la colonne **GARDE** du tableau desktop, le tri secondaire par urgence classe les bouteilles selon `(année_courante - garde_max)` décroissant — les plus en retard apparaissent en premier.

La colonne GARDE affiche le delta en années (ex : `-3` = 3 ans avant l'optimum, `+2` = 2 ans après la fin de garde).

## Bouteilles sans données de garde

Si garde_min ou garde_max n'est pas renseigné, la maturité affiche ⚫ "Sans données". Ces bouteilles peuvent être filtrées ou ignorées.

## Voir aussi

- [02 — Ajouter des bouteilles](02-ajout-bouteilles.md) (saisir les gardes à l'ajout)
- [03 — Consulter le stock](03-stock.md)
- [07 — Modifier la fiche](07-modifier-fiche.md) (corriger les gardes d'une bouteille existante)
