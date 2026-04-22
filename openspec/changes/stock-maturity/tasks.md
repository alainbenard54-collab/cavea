## 1. Logique maturité — urgency score (PC + Android)

- [x] 1.1 Dans `lib/core/maturity/maturity_service.dart`, ajouter `urgencyScore(millesime, gardeMin, gardeMax)` retournant un int : `age - gardeMax` pour aBoireUrgent, `gardeMax - age` pour optimal, `gardeMin - age` pour tropJeune, `0` pour sansDonnee
- [x] 1.2 Renommer le label "À boire !" en "À boire urgent !" dans `maturity_badge.dart`

## 2. DAO — filtre couleurs multi-sélect (PC + Android)

- [x] 2.1 Dans `lib/data/daos/bouteille_dao.dart`, modifier `watchStockFiltered` pour accepter `List<String>? couleurs` (au lieu de `String? couleur`) et générer `b.couleur.isIn(couleurs)` quand la liste est non vide

## 3. Contrôleur stock — nouveau state (PC + Android)

- [x] 3.1 Dans `lib/features/stock/stock_controller.dart`, remplacer `couleur: String?` par `couleurs: Set<String>` (ensemble vide = pas de filtre), ajouter `maturite: MaturityLevel?`
- [x] 3.2 Ajouter méthodes `toggleCouleur(String)`, `clearCouleurs()`, `setMaturite(MaturityLevel?)`
- [x] 3.3 Mettre à jour `stockProvider` : passer `couleurs` au DAO, appliquer le filtre maturité en Dart, appliquer le tri secondaire par urgence quand `maturite != null`
- [x] 3.4 Mettre à jour `couleursProvider`, `appellationsProvider`, `millesimesProvider` pour tenir compte du nouveau champ `couleurs` (Set) au lieu de `couleur` (String?)

## 4. Tableau desktop — colonne GARDE colorée (PC)

- [x] 4.1 Dans `lib/features/stock/stock_table.dart`, modifier `_dataRow` : calculer `MaturityLevel` pour chaque bouteille et afficher la cellule GARDE avec fond coloré (rouge/vert/bleu/neutre pâle)
- [x] 4.2 Afficher le delta dans la cellule GARDE : `+N an(s)` pour aBoireUrgent, `-N an(s)` pour optimal, `dans N an(s)` pour tropJeune (sur une seconde ligne ou en suffixe)
- [x] 4.3 Augmenter `_wGarde` si nécessaire pour accommoder le delta (110px)

## 5. Écran stock — nouveaux filtres UI (PC + Android)

- [x] 5.1 Dans `lib/features/stock/stock_screen.dart`, remplacer le dropdown couleur par une rangée de `FilterChip` multi-sélect scrollable horizontalement
- [x] 5.2 Ajouter une rangée de `FilterChip` colorés pour le filtre maturité (rouge/vert/bleu/gris), un seul actif à la fois
- [x] 5.3 Déplacer les dropdowns appellation et millésime dans un `ExpansionTile` "Filtres avancés" replié par défaut
- [x] 5.4 Mettre à jour la logique de reset pour inclure `couleurs` et `maturite`
- [x] 5.5 Mettre à jour l'appel à `watchStockFiltered` dans le provider pour passer `couleurs` (liste) au lieu de `couleur` (string)

## 6. Suppression du module quoi_boire (PC + Android)

- [x] 6.1 Supprimer le répertoire `lib/features/quoi_boire/` complet
- [x] 6.2 Dans `lib/app/router.dart`, supprimer la route `/quoi-boire` et l'import `QuoiBoireScreen`
- [x] 6.3 Dans `lib/shared/adaptive_layout.dart`, supprimer la destination "Quoi boire ?" et restaurer l'icône `wine_bar` pour Stock

## 7. Validation manuelle (PC)

- [ ] 7.1 Vérifier que les chips couleur fonctionnent en multi-sélect (ex. Liquoreux + Moelleux simultanément)
- [ ] 7.2 Vérifier que les cellules GARDE sont colorées correctement et affichent le bon delta
- [ ] 7.3 Activer le filtre "À boire urgent !" : vérifier tri par dépassement décroissant
- [ ] 7.4 Activer le filtre "À boire" : vérifier tri par proximité de fin de garde
- [ ] 7.5 Vérifier que les filtres avancés (millésime/appellation) se replient et fonctionnent
- [ ] 7.6 Vérifier que la navigation ne contient plus "Quoi boire ?"
