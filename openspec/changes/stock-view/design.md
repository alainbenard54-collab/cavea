## Context

L'étape 1 a livré la base drift, les providers Riverpod et l'import CSV. L'écran principal est encore un placeholder. Ce change remplace ce placeholder par la vue stock centrale de l'application, avec filtres et layout adaptatif.

## Goals / Non-Goals

**Goals:**
- Implémenter `StockScreen` avec liste réactive et filtres combinables
- Étendre `BouteilleDao` avec requête filtrée et méthodes de valeurs distinctes
- Implémenter le shell de navigation adaptatif (NavigationRail / BottomNavigationBar)
- Provider Riverpod pour l'état des filtres

**Non-Goals:**
- Indicateurs de maturité (étape 3)
- Actions sur les bouteilles (consommer, déplacer)
- Filtres sauvegardés, tri personnalisable (V1)

---

## Decisions

### D1 — Filtrage : stream drift avec paramètres dynamiques

**Choix** : `watchStockFiltered()` construit une requête drift dynamique selon les filtres actifs. Les filtres null/vides sont ignorés.

**Pourquoi** : Le filtrage en base est plus performant que charger tout le stock et filtrer en Dart, surtout avec des centaines de bouteilles. drift permet de composer les conditions dynamiquement avec `where`.

```dart
Stream<List<Bouteille>> watchStockFiltered({
  String? couleur,
  String? appellation,
  int? millesime,
  String? texte,
})
```

**Fichiers** : `lib/data/daos/bouteille_dao.dart`

---

### D2 — État des filtres : StateNotifierProvider

**Choix** : `StockFilterState` + `StockFilterController extends StateNotifier<StockFilterState>` dans `lib/features/stock/stock_controller.dart`.

**Pourquoi** : Pattern cohérent avec `SetupController` déjà en place. L'état des filtres est local à l'écran stock, `autoDispose` pour nettoyage.

```dart
class StockFilterState {
  final String? couleur;
  final String? appellation;
  final int? millesime;
  final String texte;
}
```

Le provider `stockProvider` combine `stockFilterProvider` et `bouteillesDaoProvider` :
```dart
final stockProvider = StreamProvider<List<Bouteille>>((ref) {
  final filters = ref.watch(stockFilterProvider);
  final dao = ref.watch(bouteillesDaoProvider);
  return dao.watchStockFiltered(...filters);
});
```

---

### D3 — Valeurs de filtres : FutureProvider

**Choix** : `couleursProvider`, `appellationsProvider`, `millesimesProvider` sont des `FutureProvider<List<String/int>>` qui appellent les méthodes `getDistinct*()` du DAO. Ils ne sont pas réactifs (pas de stream) — les listes de valeurs sont chargées une fois à l'ouverture.

**Pourquoi** : Ces listes changent rarement (seulement après import ou ajout). Un `FutureProvider` suffit, un stream serait du sur-engineering.

---

### D4 — Layout adaptatif : AppShell

**Choix** : `AppShell` widget dans `lib/shared/adaptive_layout.dart` qui wrape le contenu avec `NavigationRail` (≥600px) ou `BottomNavigationBar` (<600px). `AppShell` reçoit l'index de destination et la liste des destinations.

```
AppShell
├── ≥600px : Row(NavigationRail | content)
└── <600px : Scaffold(body: content, bottomNavigationBar: BottomNavBar)
```

go_router reste l'autorité sur les routes — `AppShell` ne gère que la navigation visuelle. Le changement d'onglet déclenche un `context.go(route)`.

**Fichiers** : `lib/shared/adaptive_layout.dart`

---

### D5 — Affichage d'une bouteille : ListTile Material 3

**Choix** : `BouteilleListTile` widget dans `lib/features/stock/` avec :
- `leading` : badge coloré (carré coloré selon la couleur du vin)
- `title` : `domaine` en gras
- `subtitle` : `appellation · millesime` + optionnel `cru`
- `trailing` : `emplacement` en texte secondaire

**Pourquoi** : `ListTile` Material 3 est le composant adapté pour des listes denses. Évite de réinventer une mise en page.

---

## Arborescence créée / modifiée

```
lib/
├── data/daos/bouteille_dao.dart        ← +watchStockFiltered, +getDistinct*
├── shared/adaptive_layout.dart         ← AppShell (remplace le stub)
├── features/
│   ├── home/home_screen.dart           ← supprimé (remplacé par stock/)
│   └── stock/
│       ├── stock_screen.dart           ← écran principal
│       ├── stock_controller.dart       ← StockFilterState + providers
│       └── bouteille_list_tile.dart    ← widget ligne
└── app/router.dart                     ← / → StockScreen via AppShell
```

---

## Risks / Trade-offs

**[Trade-off] Filtres en base vs en mémoire** → Le filtrage drift reconstruit le stream à chaque changement de filtre. Sur 800 bouteilles c'est imperceptible. Si le stock dépasse 10 000 bouteilles, envisager un debounce sur la recherche texte.

**[Risque] Valeurs distinctes stales** → Les listes de couleurs/appellations/millésimes sont chargées une fois. Si l'utilisateur importe de nouvelles bouteilles sans recharger l'écran, les listes de filtres peuvent être incomplètes. Mitigation : `ref.invalidate()` après un import réussi (à faire dans `ImportCsvScreen`).
