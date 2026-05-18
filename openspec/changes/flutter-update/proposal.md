## Why

Flutter publie régulièrement de nouvelles versions stables apportant des correctifs, des améliorations de performance et des évolutions d'API. Le projet tourne actuellement sur Flutter 3.41.6 (Windows) / 3.41.9 (Linux VM) avec des dépendances figées à des versions datant de la phase V1. Une mise à jour synchronisée SDK + dépendances garantit la pérennité du projet et l'accès aux correctifs de sécurité.

## What Changes

- Mise à jour du SDK Flutter vers la dernière version stable disponible (`flutter upgrade`)
- Mise à jour de toutes les dépendances pubspec.yaml vers leurs dernières versions compatibles (`flutter pub upgrade --major-versions`)
- Correction des éventuelles ruptures d'API (breaking changes) introduites par les nouvelles versions
- Mise à jour de la contrainte `sdk:` dans pubspec.yaml pour refléter la nouvelle version Dart minimale requise
- Validation complète par la suite de tests unitaires existante (78 cas, 8 fichiers de test)
- Pas de modification de fonctionnalité, pas de nouvel écran, pas de nouveau flux utilisateur

## Capabilities

### New Capabilities
_(aucune — mise à jour purement technique, sans nouvelle fonctionnalité)_

### Modified Capabilities
_(aucune — les exigences métier restent identiques ; seule l'implémentation technique évolue si des API Flutter/dépendances changent)_

## Impact

- **pubspec.yaml** : contrainte `sdk:`, versions de toutes les dépendances `dependencies:` et `dev_dependencies:`
- **Code source Dart** : corrections ponctuelles si des API dépréciées ou supprimées sont utilisées (à identifier au moment de `flutter pub upgrade`)
- **Tests** : suite existante utilisée comme filet de sécurité — 0 régression attendue
- **Modes de déploiement** : Modes 1 et 2 concernés (Windows + Android + Linux VM). Aucun impact sur la logique métier ou les règles de stockage.
- **Non-goals** : ne pas introduire de nouvelles dépendances, ne pas refactorer le code existant au-delà des corrections imposées par les breaking changes, ne pas modifier les specs fonctionnelles
