## ADDED Requirements

### Requirement: Version Flutter minimale garantie
L'application SHALL être compilable et exécutable avec la dernière version stable du SDK Flutter disponible au moment de la mise à jour. La contrainte `sdk:` dans pubspec.yaml DOIT refléter la version Dart minimale requise par cette version Flutter.

#### Scenario: Build Windows après upgrade
- **WHEN** l'utilisateur exécute `flutter build windows --release` avec le SDK mis à jour
- **THEN** la compilation se termine sans erreur

#### Scenario: Build Android après upgrade
- **WHEN** l'utilisateur exécute `flutter build apk --release` avec le SDK mis à jour
- **THEN** la compilation se termine sans erreur

#### Scenario: Tests unitaires après upgrade
- **WHEN** l'utilisateur exécute `flutter test`
- **THEN** les 78 cas passent, 0 failure, 0 erreur de compilation

### Requirement: Dépendances à jour
Toutes les dépendances listées dans `pubspec.yaml` SHALL être à leur dernière version stable compatible avec le SDK Flutter cible. Aucune dépendance ne SHALL afficher d'avertissement `flutter pub outdated` après la mise à jour.

#### Scenario: Vérification outdated
- **WHEN** l'utilisateur exécute `flutter pub outdated`
- **THEN** aucune dépendance n'affiche de mise à jour disponible non appliquée (hors contraintes intentionnelles)
