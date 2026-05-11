## Why

L'application dispose d'un import CSV mais pas d'export : l'utilisateur ne peut pas sauvegarder ses données dans un format ouvert et portable. L'export CSV complète le cycle données en permettant à la fois une sauvegarde fidèle (round-trip avec `updated_at`) et une consultation externe (Excel, LibreOffice). La cohérence avec l'import impose également de rendre le séparateur configurable des deux côtés.

## What Changes

- **Nouveau** : écran Export CSV permettant d'exporter tout ou partie des bouteilles (stock seul ou stock + consommées) dans un fichier CSV avec séparateur au choix (`;`, `,`, tabulation)
- **Nouveau** : service `CsvExportService` qui génère le CSV (UTF-8 BOM, tous les champs y compris `updated_at`)
- **Nouveau** : cible Android — sauvegarde dans Downloads (MediaStore) et partage via `share_plus`
- **Nouveau** : cible Windows — `FilePicker.getSavePath()` pour choisir destination et nom de fichier
- **Modifié** : `csv_parser.dart` — accepte un paramètre `separator` au lieu de supposer `;` fixe ; respecte `updated_at` si présent dans le fichier importé
- **Modifié** : `ImportCsvScreen` — ajout d'un sélecteur de séparateur (`;` par défaut)

## Capabilities

### New Capabilities
- `csv-export` : export des bouteilles en CSV avec choix du séparateur, du scope (stock/tout), et de la destination (Windows FilePicker / Android Downloads + share_plus)

### Modified Capabilities
- `import-csv` : le parseur accepte désormais un séparateur configurable (`;`, `,`, tabulation) et préserve `updated_at` si présent dans le CSV importé

## Impact

- Nouveau fichier : `lib/features/export_csv/export_csv_screen.dart`
- Nouveau fichier : `lib/features/export_csv/csv_export_service.dart`
- Modifiés : `lib/features/import_csv/csv_parser.dart`, `lib/features/import_csv/import_csv_screen.dart`
- Navigation : l'onglet "Import CSV" (index 3 sur desktop, position droite sur mobile) devient "Import / Export" ou un nouvel onglet est ajouté — à trancher en design
- Dépendances : `share_plus` à ajouter si absente, `file_picker` déjà présent
- Modes concernés : Mode 1 et Mode 2 (l'export est une lecture pure — accessible même en SyncReadOnly)

## Non-goals

- Pas d'export XLS ou autre format propriétaire — CSV uniquement
- Pas de filtres fins (appellation, couleur, millésime) — scope binaire stock/tout
- Pas de "mode sauvegarde" distinct — l'export avec `updated_at` est la sauvegarde
- Pas de détection automatique du séparateur à l'import (choix manuel uniquement)
- Mode 3 (Android local sans sync) hors périmètre actuel
