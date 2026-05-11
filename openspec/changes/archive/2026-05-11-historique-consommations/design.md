## Context

L'app gère le stock de bouteilles via la table `bouteilles`. Une bouteille consommée a `date_sortie` renseignée. Aucune vue ne liste ces bouteilles consommées. De plus, aucun mécanisme ne permet de corriger une consommation enregistrée par erreur — la bouteille est définitivement "sortie" sans possibilité de retour en stock.

Navigation actuelle (5 destinations) : Stock (0), Ajouter (1), Emplacements (2), Import CSV (3), Paramètres (4). L'ajout d'Historique implique un 6e onglet.

## Goals / Non-Goals

**Goals:**
- Lister les bouteilles consommées (`date_sortie IS NOT NULL`) triées par date décroissante
- Permettre la réhabilitation d'une bouteille (erreur de saisie) : efface `date_sortie`, `note_degus`, `commentaire_degus`
- Recherche texte sur domaine/appellation dans l'historique
- Accessible en Mode 1 et Mode 2, désactivé (lecture seule) pour les actions en SyncReadOnly

**Non-Goals:**
- Statistiques ou graphiques de consommation
- Export de l'historique (couvert par Export CSV séparé)
- Suppression physique d'une bouteille

## Decisions

### D1 — Navigation Android : onglet "Plus" (⋯) pour les destinations secondaires

La `_MobileBar` est limitée à 5 onglets avant d'overflow sur petits écrans Android (411 dp), surtout en Mode 2 écriture où la zone sync prend ~145 dp. Avec l'ajout de l'Historique et les futures features (Export CSV, Dropbox…), un menu secondaire est indispensable.

**Décision** : 4 destinations primaires + 1 onglet "Plus" (`Icons.more_horiz`) :
- Primary (0→3) : Stock, Ajouter, Emplacements, Historique
- Plus (index 4) : tap → `ModalBottomSheet` listant Import CSV, Paramètres (et futures destinations)
- L'onglet "Plus" affiche un état "sélectionné" quand une destination secondaire est active

`_writeOnlyIndices = {1}` (Ajouter uniquement — Import CSV géré dans le BottomSheet secondaire).

**DesktopRail Windows** : toutes les destinations sont listées directement dans le rail vertical (pas de contrainte de largeur). Index global : Stock(0), Ajouter(1), Emplacements(2), Historique(3), Import CSV(4), Paramètres(5).

**Évolutivité** : ajouter une feature secondaire = ajouter un `ListTile` dans le BottomSheet "Plus", sans toucher aux 4 onglets primaires. Promouvoir une feature de secondaire à primaire = déplacer son index et son `_NavBtn`.

Alternative rejetée : Import CSV dans Paramètres — Paramètres serait trop chargé et Import CSV serait inaccessible en Mode 2 lecture seule (Paramètres reste accessible, Import CSV bloqué).

Alternative rejetée : 6 onglets compacts — overflow garanti en Mode 2 écriture Android.

### D2 — Widget unique ConsumerStatefulWidget (même pattern que LocationTreeScreen)

L'écran Historique est un `ConsumerStatefulWidget` avec recherche texte inline. Le tap sur une bouteille affiche un BottomSheet avec les détails et l'action Réhabiliter (si mode écriture). Pas de route séparée pour le détail.

Alternative rejetée : route `/historique/:id` → navigation trop lourde pour une liste + action simple.

### D3 — Réhabilitation via BottomSheet avec confirmation

Tap bouteille → BottomSheet affichant : domaine, appellation, millésime, date de consommation, note /10, commentaire de dégustation, emplacement. Bouton "Réhabiliter" → `AlertDialog` de confirmation → `rehabiliterBouteille(id)`.

En SyncReadOnly : BottomSheet affiche les infos en lecture seule, bouton Réhabiliter masqué.

### D4 — `watchHistorique()` stream drift réactif

```dart
Stream<List<Bouteille>> watchHistorique({String? searchQuery}) {
  return (_db.select(_db.bouteilles)
    ..where((b) => b.dateSortie.isNotNull() & b.dateSortie.isNotValue(''))
    ..orderBy([(b) => OrderingTerm.desc(b.dateSortie)])
  ).watch();
}
```

La recherche texte est appliquée côté Dart (filtre sur la liste) pour simplifier — le volume de l'historique reste limité (quelques centaines de bouteilles max).

### D5 — `rehabiliterBouteille` : UPDATE atomique

```dart
Future<void> rehabiliterBouteille(String id) async {
  await (_db.update(_db.bouteilles)
    ..where((b) => b.id.equals(id))
  ).write(BouteillesCompanion(
    dateSortie: const Value(null),
    noteDegus: const Value(null),
    commentaireDegus: const Value(null),
    updatedAt: Value(DateTime.now()),
  ));
}
```

`date_sortie` repassée à null → la bouteille réapparaît dans `watchStock()` et disparaît de `watchHistorique()` — réactivité drift automatique.

## Risks / Trade-offs

[Réhabilitation irréversible (dans l'autre sens)] → Confirmation obligatoire via AlertDialog avant exécution. Libellé clair : "Cette bouteille sera remise en stock à son emplacement d'origine."

[Perte des données de dégustation] → Comportement attendu : la réhabilitation efface note et commentaire de dégustation (données liées à la "consommation" incorrecte). Documenté dans la confirmation.

[Onglet "Plus" sur Android] → L'état "sélectionné" du bouton Plus quand une destination secondaire est active peut dérouter. Mitigation : colorer l'icône ⋯ avec `colorScheme.primary` quand `selectedIndex >= 4` (secondaire actif).
