## Why

La vue stock et la vue "Quoi boire ?" sont redondantes et complémentaires : chacune manque de ce que l'autre apporte. L'utilisateur doit naviguer entre les deux pour avoir une image complète. La fusion en une seule vue enrichie simplifie l'expérience et prépare les actions futures (déplacer, consommer).

## What Changes

- Suppression de la vue "Quoi boire ?" en tant qu'écran séparé
- Colonne GARDE dans le tableau desktop colorée selon la maturité, avec delta lisible (ex. `5-10 ans · +3 ans`)
- Filtre couleur de vin remplacé par FilterChips multi-sélect (plusieurs couleurs simultanément)
- Filtre maturité ajouté : chips colorés selon le niveau (À boire urgent !, À boire, Trop jeune, Sans données)
- Filtre millésime déplacé dans un panneau "Filtres avancés" repliable
- Tri secondaire dans chaque groupe de maturité : urgence croissante (le plus en retard en premier dans "À boire urgent !", le plus proche de la limite en premier dans "À boire", etc.)
- Label "À boire !" renommé en "À boire urgent !"

## Capabilities

### New Capabilities

- `stock-maturity-filter`: Filtrage multi-sélect couleur + filtre maturité avec chips colorés.

### Modified Capabilities

- `stock-view`: La vue stock intègre les indicateurs de maturité (colonne GARDE colorée, tri secondaire par urgence, filtre maturité). La vue "Quoi boire ?" est supprimée.
- `quoi-boire`: Supprimée — ses fonctionnalités sont absorbées par `stock-view`.

## Impact

- `lib/features/stock/` : enrichissement du contrôleur, du tableau, des filtres
- `lib/features/quoi_boire/` : suppression complète du module
- `lib/core/maturity/maturity_service.dart` : ajout tri secondaire (urgency score)
- `lib/shared/adaptive_layout.dart` : suppression de la destination "Quoi boire ?"
- `lib/app/router.dart` : suppression de la route `/quoi-boire`
- `openspec/changes/quoi-boire/` : le change reste archivable tel quel (fonctionnalité remplacée)

## Non-goals

- Action "consommer" ou "déplacer" depuis la vue stock (étapes 4 et 6 du MVP)
- Tri par maturité comme tri de colonne cliquable (le tri maturité n'est actif que quand le filtre maturité est sélectionné)
- Filtres sauvegardés entre sessions
