## 1. Logique de maturité (pur Dart, PC + Android)

- [x] 1.1 Créer `lib/core/maturity/maturity_service.dart` : enum `MaturityLevel` (tropJeune, optimal, aBoireUrgent, sansDonnee) et fonction `computeMaturity(millesime, gardeMin, gardeMax, annee)`
- [x] 1.2 Vérifier les 4 cas limites : garde absente (null/0), age < gardeMin, age dans [gardeMin, gardeMax], age > gardeMax

## 2. Provider quoi-boire (PC + Android)

- [x] 2.1 Créer `lib/features/quoi_boire/providers/quoi_boire_provider.dart` : `StateNotifierProvider` tenant le filtre couleur sélectionné (String?) et exposant un stream de bouteilles triées par maturité via `watchStockFiltered`
- [x] 2.2 Implémenter le tri : `aBoireUrgent` → `optimal` → `tropJeune` → `sansDonnee` dans le provider
- [x] 2.3 Exposer les valeurs distinctes de couleur (réutiliser `getDistinctCouleurs()` du DAO)

## 3. Widgets (PC + Android)

- [x] 3.1 Créer `lib/features/quoi_boire/widgets/maturity_badge.dart` : chip Material 3 coloré selon `MaturityLevel` (bleu/vert/rouge/gris + labels "Trop jeune" / "À boire" / "À boire !" / "?")
- [x] 3.2 Créer `lib/features/quoi_boire/widgets/bouteille_maturity_tile.dart` : ligne liste affichant domaine, appellation, millésime, emplacement et le `MaturityBadge`

## 4. Écran principal (PC + Android)

- [x] 4.1 Créer `lib/features/quoi_boire/quoi_boire_screen.dart` : scaffold avec barre de filtre couleur (chips horizontaux) et `ListView` des `BouteilleMaturityTile`
- [x] 4.2 Afficher un message "Aucune bouteille en stock" quand la liste est vide
- [x] 4.3 Afficher un indicateur de chargement pendant la première émission du stream

## 5. Navigation (PC + Android)

- [x] 5.1 Ajouter la route `/quoi-boire` dans `go_router` (`lib/core/navigation/`)
- [x] 5.2 Ajouter la destination "Quoi boire ?" dans `NavigationRail` (desktop ≥600px) et `BottomNavigationBar` (mobile <600px) — icône `wine_bar` ou similaire Material
- [x] 5.3 Vérifier que la navigation active met en surbrillance le bon item dans les deux layouts

## 6. Validation manuelle (PC)

- [ ] 6.1 Lancer l'app Windows, vérifier que les badges couleur correspondent aux calculs attendus sur quelques bouteilles réelles
- [ ] 6.2 Vérifier le filtre couleur : sélectionner "Rouge", vérifier que seules les rouges apparaissent
- [ ] 6.3 Vérifier le tri : les bouteilles `aBoireUrgent` apparaissent bien en premier
- [ ] 6.4 Vérifier le layout adaptatif : redimensionner la fenêtre sous 600px, la BottomNavigationBar doit apparaître
