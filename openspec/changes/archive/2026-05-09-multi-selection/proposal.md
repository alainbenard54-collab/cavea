## Why

La vue stock ne permet actuellement que des actions unitaires sur les bouteilles (consommer, déplacer, modifier). Pour les utilisateurs gérant plusieurs dizaines de bouteilles à traiter simultanément (ex : rangement après une commande, consommation d'un repas de groupe), l'absence de multi-sélection génère une répétition fastidieuse des mêmes gestes. Cette feature V1 répond directement au besoin de gestion en lot, identifié dans le PRD et documenté dans ARCHITECTURE.md.

## What Changes

- Ajout d'un **mode sélection** dans la vue stock, activé par appui long sur une ligne
- Affichage de **cases à cocher** sur chaque ligne en mode sélection
- **Barre d'actions contextuelle** en bas d'écran (au-dessus de la BottomNavigationBar sur Android, fixée en bas sur desktop) avec compteur de sélection, actions Déplacer / Consommer, et bouton Annuler
- Action **Déplacer en lot** : un seul champ emplacement + autocomplétion → UPDATE emplacement sur toutes les bouteilles sélectionnées
- Action **Consommer en lot** : formulaire identique au Consommer unitaire (date, note, commentaire) → UPDATE date_sortie + note_degus + commentaire_degus sur toutes
- **Mode lecture seule** : les actions de modification restent cachées (cohérence avec règle SyncReadOnly existante)

## Capabilities

### New Capabilities

- `bulk-select`: Mode sélection multiple dans la vue stock — entrée via appui long, cases à cocher, sortie via Annuler ou après exécution d'une action
- `bulk-actions`: Barre d'actions contextuelle et formulaires d'actions en lot (Déplacer + Consommer) appliqués à la sélection courante

### Modified Capabilities

- `bottle-actions`: Aucun changement de spec — le BottomSheet unitaire reste inchangé, le tap simple continue de l'ouvrir

## Impact

- `lib/screens/stock_screen.dart` : gestion de l'état de sélection (liste d'IDs sélectionnés, booléen `isSelectMode`), affichage des checkboxes, barre contextuelle
- `lib/widgets/` : nouveau widget `BulkActionBar` (barre d'actions contextuelle)
- `lib/screens/` : nouveaux formulaires bottom sheet pour Déplacer en lot et Consommer en lot (ou réutilisation des widgets existants avec adaptation)
- `lib/dao/bouteilles_dao.dart` : méthodes batch (`moveBottles(List<String> ids, String emplacement)`, `consumeBottles(List<String> ids, ...)`)
- Aucune modification du schéma de base de données
- Modes 1 et 2 concernés ; Mode 3 hors périmètre

## Non-goals

- Sélection globale "tout sélectionner" (hors périmètre V1)
- Actions en lot autres que Déplacer et Consommer (suppression, export — hors périmètre)
- Modification de fiche en lot
- Persistance de la sélection entre sessions
