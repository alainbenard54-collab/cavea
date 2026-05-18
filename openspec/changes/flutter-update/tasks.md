## 1. Prise d'inventaire — état avant upgrade

- [x] 1.1 Vérifier la version Flutter actuelle : lancer `flutter --version` et coller le résultat à Claude (PC Windows)
- [x] 1.2 Vérifier les dépendances dépassées : lancer `flutter pub outdated` et coller le résultat à Claude (PC Windows)

## 2. Mise à jour du SDK Flutter

- [x] 2.1 Mettre à jour le SDK : lancer `flutter upgrade` et coller la dernière ligne affichée (PC Windows)
- [x] 2.2 Confirmer la nouvelle version : lancer `flutter --version` et coller le résultat à Claude pour mettre à jour la mémoire

## 3. Mise à jour des dépendances pubspec.yaml

- [x] 3.1 Mettre à jour toutes les dépendances en acceptant les nouvelles majeures : lancer `flutter pub upgrade --major-versions` et coller le résultat complet à Claude (PC Windows)
- [x] 3.2 Claude analyse les nouvelles versions adoptées et identifie les breaking changes potentiels à corriger
- [x] 3.3 Vérifier le fichier pubspec.yaml résultant : lancer `cat pubspec.yaml` ou coller le contenu à Claude pour vérification

## 4. Régénération du code drift (build_runner)

- [x] 4.1 Supprimer les fichiers générés obsolètes et régénérer : lancer `dart run build_runner build --delete-conflicting-outputs` (PC Windows)
- [x] 4.2 Coller le résultat à Claude — si des erreurs apparaissent, Claude guide les corrections

## 5. Détection et correction des breaking changes

- [x] 5.1 Analyser statiquement le code : lancer `flutter analyze` et coller le résultat complet à Claude (PC Windows)
- [x] 5.2 Claude identifie chaque erreur et fournit les corrections Dart à appliquer dans les fichiers concernés
- [x] 5.3 Appliquer les corrections fournies par Claude dans VSCode
- [x] 5.4 Relancer `flutter analyze` — itérer 5.2→5.4 jusqu'à 0 erreur (PC Windows)

## 6. Validation par la suite de tests

- [x] 6.1 Lancer la suite de tests complète : `flutter test` et coller le résultat à Claude (PC Windows)
- [x] 6.2 Si des tests échouent : Claude identifie la cause (breaking change non corrigé ou régression) et fournit le correctif
- [x] 6.3 Relancer `flutter test` — valider que les 78 cas passent avec 0 failure

## 7. Vérification build Windows

- [x] 7.1 Compiler en release pour Windows : lancer `flutter build windows --release` (PC Windows)
- [x] 7.2 Coller le résultat (succès ou erreurs) à Claude — corriger si nécessaire

## 8. Mise à jour de la contrainte sdk: dans pubspec.yaml

- [x] 8.1 Claude vérifie que la contrainte `sdk:` dans pubspec.yaml est cohérente avec la version Dart bundlée dans le nouveau Flutter
- [x] 8.2 Si la contrainte doit changer, Claude fournit la valeur exacte à mettre dans pubspec.yaml

## 9. Finalisation

- [ ] 9.1 Claude met à jour la mémoire avec la nouvelle version Flutter installée
- [ ] 9.2 Claude prépare le commit git avec les fichiers modifiés (pubspec.yaml, pubspec.lock, fichiers .dart corrigés, fichiers générés .g.dart / .drift.dart)
