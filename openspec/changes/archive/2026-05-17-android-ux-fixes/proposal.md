## Why

Sur Android en orientation paysage, deux problèmes de lisibilité/utilisabilité persistent : la table stock s'affiche (largeur ≥640dp) mais ses lignes sont trop denses pour la hauteur réduite de l'écran, et les suggestions d'autocomplétion s'ouvrent vers le bas et se retrouvent masquées derrière le clavier virtuel. Ces deux régressions UX ont été identifiées en fin de V1.

## What Changes

- **Table stock (paysage Android)** : réduire le padding vertical des lignes quand l'appareil est en landscape, pour afficher davantage de bouteilles dans la hauteur disponible (~320-360dp).
- **Autocomplétion (paysage Android)** : forcer `OptionsViewOpenDirection.up` sur les champs `RawAutocomplete` / `_AutocompleteField` en landscape pour que les suggestions s'ouvrent au-dessus du champ (hors de portée du clavier virtuel).
- Fichiers concernés : `stock_table.dart`, `stock_screen.dart`, `bottle_edit_screen.dart`, `bulk_add_screen.dart`.

## Capabilities

### New Capabilities
_(aucune — corrections de comportement existant uniquement)_

### Modified Capabilities

- `stock-view` : adaptation de la densité de la table en paysage Android (padding vertical réduit)
- `bottle-edit-screen` : direction d'ouverture des suggestions autocomplete adaptée au paysage
- `bulk-add` : direction d'ouverture des suggestions autocomplete adaptée au paysage

## Impact

- **Plateforme cible** : Android uniquement (Mode 1 et Mode 2 — lecture seule incluse)
- **Fichiers touchés** : `lib/features/stock/stock_table.dart`, `lib/features/stock/stock_screen.dart` (pour la détection landscape), `lib/features/bottle_edit/bottle_edit_screen.dart`, `lib/features/bulk_add/bulk_add_screen.dart`
- **Aucun impact** sur Windows, Linux, la logique métier, la base de données, ou le système de sync

## Non-goals

- Refonte complète du layout paysage Android
- Modification du seuil 640dp de bascule table/liste
- Changements sur les filtres paysage (déjà implémentés et archivés dans android-ux)
