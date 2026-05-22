## ADDED Requirements

### Requirement: README anglais à la racine
Le repo SHALL contenir un `README.md` en anglais à sa racine, servant de point d'entrée standard GitHub.

Le fichier SHALL contenir dans l'ordre :
1. Lien vers la version française (`README.fr.md`) en tête
2. Titre et description en une phrase
3. Section "Philosophy" : simple, no photos, no barcodes, focus on stock/location/maturity/consumption
4. Section "Deployment modes" : Mode Local (dart:io direct, single device, no cloud) + Mode Shared (Google Drive or Dropbox, single write lock, read-only for other devices)
5. Section "Platforms" : Windows desktop (primary), Linux desktop, Android
6. Section "Tech stack" : Flutter 3 / Dart, drift (SQLite ORM), Riverpod, go_router, Material 3
7. Section "Build" : prerequisites (Flutter SDK, Dart), `flutter pub get`, `flutter run`
8. Section "OAuth configuration" : instructions pour configurer les credentials GCP (Drive) et Dropbox pour le Mode Partagé
9. Section "License" : Apache 2.0

#### Scenario: Découverte du projet sur GitHub
- **WHEN** un développeur arrive sur la page GitHub du projet
- **THEN** il voit immédiatement le README anglais avec le lien vers la version française en tête de page

#### Scenario: Navigation vers la version française
- **WHEN** un utilisateur francophone clique sur le lien `🇫🇷 Version française` en tête du README.md
- **THEN** il est redirigé vers `README.fr.md` qui contient exactement la même structure en français

#### Scenario: Compréhension du mode partagé
- **WHEN** un lecteur consulte la section "Deployment modes"
- **THEN** il comprend que le mode partagé utilise un verrou exclusif en écriture (un seul appareil à la fois) et que les autres appareils sont en lecture seule pendant ce temps

### Requirement: README français miroir
Le repo SHALL contenir un `README.fr.md` à la racine, en français, avec exactement la même structure que `README.md`.

Le fichier SHALL commencer par un lien vers `README.md` (`🇬🇧 English version`).

#### Scenario: Cohérence de structure
- **WHEN** les deux fichiers README.md et README.fr.md sont comparés
- **THEN** ils ont exactement les mêmes sections dans le même ordre, seule la langue diffère

#### Scenario: Lien retour vers l'anglais
- **WHEN** un lecteur consulte README.fr.md
- **THEN** un lien `🇬🇧 English version` en tête de fichier permet de revenir à README.md
