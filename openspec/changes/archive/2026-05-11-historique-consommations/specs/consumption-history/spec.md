## ADDED Requirements

### Requirement: Onglet Historique dans la navigation principale
L'application SHALL afficher un onglet "Historique" dans la navigation principale (`Icons.history`, index 3), accessible depuis le `_DesktopRail` (Windows) et la `_MobileBar` (Android). L'onglet est toujours accessible, y compris en mode SyncReadOnly. `_writeOnlyIndices = {1, 4}` (Ajouter=1, Import CSV=4). Import CSV passe à l'index 4, Paramètres à l'index 5.

#### Scenario: Onglet visible sur Windows
- **WHEN** l'app est ouverte sur Windows
- **THEN** le rail de navigation affiche une entrée "Historique" avec `Icons.history` à l'index 3

#### Scenario: Onglet visible sur Android
- **WHEN** l'app est ouverte sur Android
- **THEN** la barre du bas affiche une icône "Historique" à l'index 3

#### Scenario: Onglet accessible en lecture seule
- **WHEN** l'app est en SyncReadOnly
- **THEN** l'onglet Historique reste accessible (consultation possible, actions d'écriture désactivées)

---

### Requirement: Liste des bouteilles consommées
L'écran Historique SHALL afficher toutes les bouteilles dont `date_sortie IS NOT NULL`, triées par `date_sortie` décroissant (plus récente en premier). Chaque entrée affiche : domaine (titre), appellation + millésime (sous-titre), date de consommation, note /10 si renseignée.

#### Scenario: Affichage initial
- **WHEN** l'utilisateur ouvre l'onglet Historique
- **THEN** la liste affiche toutes les bouteilles consommées, les plus récentes en premier

#### Scenario: Liste vide
- **WHEN** aucune bouteille n'a encore été consommée
- **THEN** l'écran affiche "Aucune bouteille consommée."

#### Scenario: Mise à jour en temps réel
- **WHEN** une bouteille est consommée depuis la vue Stock ou Emplacements
- **THEN** elle apparaît immédiatement en tête de l'historique (stream drift réactif)

---

### Requirement: Recherche dans l'historique
L'écran Historique SHALL permettre de filtrer la liste par une recherche texte sur le domaine et l'appellation (contient, insensible à la casse).

#### Scenario: Recherche active
- **WHEN** l'utilisateur saisit un texte dans la SearchBar
- **THEN** la liste se restreint aux bouteilles dont le domaine ou l'appellation contient le texte

#### Scenario: Effacement de la recherche
- **WHEN** l'utilisateur efface le texte de la SearchBar
- **THEN** la liste complète réapparaît

---

### Requirement: Détail et actions depuis l'historique
Un tap sur une bouteille de l'historique SHALL ouvrir un BottomSheet affichant les informations complètes de la consommation et proposant l'action Réhabiliter (en mode écriture uniquement).

#### Scenario: BottomSheet en mode écriture
- **WHEN** l'app est en mode écriture (SyncIdle ou Mode 1) et l'utilisateur tape sur une bouteille
- **THEN** un BottomSheet s'affiche avec : domaine, appellation, millésime, couleur, emplacement d'origine, date de consommation, note /10 (si renseignée), commentaire de dégustation (si renseigné), bouton "Réhabiliter" et bouton "Consulter la fiche"

#### Scenario: BottomSheet en mode lecture seule
- **WHEN** l'app est en SyncReadOnly et l'utilisateur tape sur une bouteille
- **THEN** le BottomSheet affiche les informations sans le bouton Réhabiliter, avec un libellé "Mode lecture seule"

---

### Requirement: Réhabilitation d'une bouteille consommée par erreur
L'application SHALL permettre de réhabiliter une bouteille consommée (erreur de saisie) via une action explicite avec confirmation. La réhabilitation efface `date_sortie`, `note_degus` et `commentaire_degus` — la bouteille réapparaît en stock avec son emplacement et ses données d'origine intactes.

#### Scenario: Réhabilitation confirmée
- **WHEN** l'utilisateur tape "Réhabiliter" dans le BottomSheet et confirme dans l'AlertDialog
- **THEN** `date_sortie`, `note_degus` et `commentaire_degus` sont effacés (`NULL`), `updated_at` est mis à jour, la bouteille disparaît de l'historique et réapparaît dans le stock

#### Scenario: Réhabilitation annulée
- **WHEN** l'utilisateur tape "Réhabiliter" puis annule dans l'AlertDialog
- **THEN** aucune modification n'est effectuée

#### Scenario: Confirmation explicite du contenu perdu
- **WHEN** l'AlertDialog de confirmation est affiché
- **THEN** le message précise que la note et le commentaire de dégustation seront effacés et que la bouteille sera remise en stock à son emplacement d'origine

#### Scenario: Réhabilitation indisponible en lecture seule
- **WHEN** l'app est en SyncReadOnly
- **THEN** le bouton Réhabiliter n'est pas affiché dans le BottomSheet

#### Scenario: Mise à jour réactive après réhabilitation
- **WHEN** la réhabilitation est confirmée
- **THEN** la bouteille disparaît immédiatement de l'historique (stream drift) et réapparaît dans la vue Stock
