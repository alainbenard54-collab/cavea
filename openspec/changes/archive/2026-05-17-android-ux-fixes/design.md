## Context

Deux problèmes UX Android en orientation paysage, indépendants l'un de l'autre :

1. **Table stock** : `stock_table.dart` utilise un padding vertical fixe (`vertical: 10`) sur toutes les cellules. En paysage Android (~360dp de hauteur utile), les lignes occupent trop de place et peu de bouteilles sont visibles sans scroll.

2. **Autocomplétion** : `RawAutocomplete` (bottle_edit) et `_AutocompleteField` (bulk_add) ouvrent toujours leurs suggestions vers le bas (`OptionsViewOpenDirection.down` par défaut). En paysage avec le clavier virtuel ouvert, la liste de suggestions se retrouve partiellement ou totalement sous le clavier.

Détection paysage déjà utilisée dans `stock_screen.dart` (ligne 80) :
```dart
final isLandscapeMobile = Platform.isAndroid &&
    MediaQuery.of(context).orientation == Orientation.landscape;
```
On applique le même pattern dans les widgets concernés.

## Goals / Non-Goals

**Goals:**
- Réduire la densité verticale de la table stock en paysage Android
- Ouvrir les suggestions d'autocomplétion vers le haut en paysage Android

**Non-Goals:**
- Refonte du layout paysage (filtres, NavigationBar — déjà traités)
- Modification du comportement sur Windows/Linux
- Changement du seuil 640dp table/liste

## Decisions

### Table stock — réduction du padding en paysage

**Choix** : `StockTable` détecte lui-même l'orientation via `MediaQuery` + `Platform.isAndroid`, sans paramètre supplémentaire.

Padding cellules : `vertical: 10` → `vertical: 4` en paysage.

**Alternatif écarté** : passer `isLandscapeMobile` depuis `stock_screen.dart` en paramètre. Crée du prop drilling inutile — `StockTable` a déjà accès au contexte.

### Autocomplétion — direction d'ouverture

**Choix** : calculer `isLandscapeMobile` au niveau du widget parent (écran) et passer `OptionsViewOpenDirection` en paramètre à `RawAutocomplete` / `_AutocompleteField`.

- `bottle_edit_screen.dart` : ajouter `optionsViewOpenDirection: isLandscapeMobile ? OptionsViewOpenDirection.up : OptionsViewOpenDirection.down` sur le `RawAutocomplete` (ligne ~624).
- `bulk_add_screen.dart` : ajouter un paramètre `openDirection` à `_AutocompleteField`, passé depuis l'écran parent.

**Alternatif écarté** : détecter l'orientation à l'intérieur de `_AutocompleteField`. Possible, mais l'écran parent calcule déjà `isLandscapeMobile` pour d'autres usages — cohérent de centraliser.

## Risks / Trade-offs

- **RawAutocomplete.optionsViewOpenDirection** : disponible depuis Flutter 3.x — vérifier que la version du projet supporte ce paramètre avant implémentation. Si absent, fallback : wrapper le `RawAutocomplete` dans un `Align` avec un overlay manuel (complexité +++) — peu probable sur Flutter 3.41.
- **Padding réduit lisibilité** : `vertical: 4` peut sembler serré sur certains écrans. Valeur ajustable si retour utilisateur négatif.
