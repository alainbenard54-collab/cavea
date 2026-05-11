## Why

L'application permet de consommer des bouteilles mais ne donne aucune visibilité sur l'historique des sorties. De plus, une bouteille marquée consommée par erreur est actuellement irrécupérable — il manque une action "Réhabiliter" pour corriger les erreurs de saisie sans supprimer la bouteille.

## What Changes

- Nouvel onglet ou écran "Historique" affichant les bouteilles consommées, triées par `date_sortie` décroissant
- Chaque entrée affiche : domaine, appellation, millésime, date de consommation, note /10 (si renseignée), emplacement d'origine
- Tap sur une entrée → fiche lecture seule + action **Réhabiliter** (efface `date_sortie`, `note_degus`, `commentaire_degus` → bouteille réapparaît en stock)
- Confirmation obligatoire avant réhabilitation (action non destructive mais significative)
- Action Réhabiliter bloquée en mode SyncReadOnly
- Recherche et filtres basiques sur l'historique (domaine, appellation, période)

## Capabilities

### New Capabilities
- `consumption-history`: Écran listant les bouteilles consommées (`date_sortie IS NOT NULL`), tri par date décroissante, recherche texte, action Réhabiliter

### Modified Capabilities
- `bottle-actions`: Ajout de l'action Réhabiliter accessible depuis l'historique (le BottomSheet bouteille existant n'est pas modifié — Réhabiliter n'a de sens que depuis l'historique, pas depuis le stock)

## Impact

- `BouteilleDao` : nouvelle requête `watchHistorique()` — `WHERE date_sortie IS NOT NULL`, tri `date_sortie DESC`
- `BouteilleDao` : nouvelle méthode `rehabiliterBouteille(String id)` — UPDATE efface `date_sortie`, `note_degus`, `commentaire_degus`
- Nouvelle route `/historique` dans `router.dart`
- Nouvelle destination dans `_DesktopRail` (Windows) et `_MobileBar` (Android) — index 3, Import CSV passe à 4, Paramètres à 5
- `_writeOnlyIndices` mis à jour (Import CSV : 4, Ajouter : 1)
- Modes 1 et 2 concernés — pas de dépendance au StorageAdapter

## Non-goals

- Suppression physique d'une bouteille de la base (hors périmètre)
- Statistiques avancées de consommation (courbes, tendances) — V2
- Export de l'historique — couvert par la feature Export CSV séparée
