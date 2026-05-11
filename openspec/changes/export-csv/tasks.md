## 1. Dépendances et DAO

- [x] 1.1 Ajouter `share_plus` dans `pubspec.yaml` (Android + Windows) et vérifier compatibilité Flutter 3.41.6
- [x] 1.2 Ajouter `getBouteillesForExport({required bool stockOnly})` dans `bouteille_dao.dart` — `Future<List<Bouteille>>`, filtre `WHERE date_sortie IS NULL` si `stockOnly: true`

## 2. Service d'export CSV

- [x] 2.1 Créer `lib/features/export_csv/csv_export_service.dart` — classe `CsvExportService` avec méthode `String buildCsv(List<Bouteille> bouteilles, {required String separator})` : header, BOM UTF-8, toutes les colonnes dans l'ordre du design, valeurs null → vide, valeurs avec séparateur → guillemets
- [x] 2.2 Vérifier l'échappement des guillemets internes (doubler le `"`) et du séparateur dans les valeurs texte

## 3. Mise à jour du parseur d'import

- [x] 3.1 Modifier `csv_parser.dart` : `parseCsv(String content, {String separator = ';'})` — passer `separator` à `_splitLine`
- [x] 3.2 Dans `_rowToCompanion` : lire `row['updated_at']`, tenter `DateTime.tryParse()`, conserver si valide, sinon `DateTime.now()`

## 4. Écran Import/Export (fusion)

- [x] 4.1 Créer `lib/features/export_csv/export_csv_screen.dart` — widget `ExportCsvScreen` avec `SegmentedButton` scope (Stock / Tout) et `SegmentedButton` séparateur (`;` / `,` / Tab), bouton "Exporter" (Windows) ou deux boutons "Enregistrer" + "Partager…" (Android, détection `Platform.isAndroid`)
- [x] 4.2 Implémenter la logique d'export Windows dans `ExportCsvScreen` : `FilePicker.platform.saveFile()` → `dart:io File.writeAsBytes(utf8.encode(bom + csv))`
- [x] 4.3 Implémenter la logique d'export Android — "Enregistrer" : `FilePicker.platform.saveFile()` ; "Partager…" : écriture dans `getTemporaryDirectory()` puis `SharePlus.instance.shareXFiles([XFile(tempPath)])`
- [x] 4.4 Ajouter snackbar de succès (chemin du fichier ou "Fichier exporté") et snackbar d'erreur en cas d'exception
- [x] 4.5 Modifier `import_csv_screen.dart` : ajouter `SegmentedButton` séparateur au-dessus du bouton "Choisir un fichier CSV" ; passer le séparateur choisi à `parseCsv()`
- [x] 4.6 Créer `lib/features/export_csv/import_export_screen.dart` (ou adapter `ImportCsvScreen`) encapsulant les deux sections Import et Export dans un `ListView` avec `Card` séparées

## 5. Navigation

- [x] 5.1 Dans `adaptive_layout.dart` : renommer la destination index 4 en "Données", changer l'icône en `Icons.import_export`, retirer l'index 4 de `_writeOnlyIndices`
- [x] 5.2 Mettre à jour la route de l'onglet pour pointer vers `ImportExportScreen`
- [x] 5.3 Dans la section Import de l'écran : désactiver le bouton "Importer" en SyncReadOnly (même snackbar "Indisponible en mode lecture seule") — le badge cadenas passe de l'onglet au bouton interne
- [x] 5.4 Sur `_MobileBar` : mettre à jour le menu "Plus" pour refléter le renommage "Données" et pointer vers la bonne route

## 6. Tests manuels

- [x] 6.1 Windows Mode 1 : exporter stock seul avec séparateur `;` → vérifier BOM, colonnes, updated_at dans Excel
- [x] 6.2 Windows Mode 1 : exporter Tout avec séparateur `,` → vérifier bouteilles consommées présentes
- [x] 6.3 Windows Mode 1 : exporter puis réimporter → vérifier round-trip fidèle (updated_at conservé, aucune donnée perdue)
- [x] 6.4 Windows Mode 1 : annuler le FilePicker → vérifier absence de fichier créé
- [x] 6.5 Windows Mode 1 : importer un CSV avec séparateur `,` → vérifier parsing correct
- [x] 6.6 Windows Mode 1 : importer un CSV sans colonne `updated_at` → vérifier que `updated_at` est rempli à `DateTime.now()`
- [x] 6.7 Android : "Enregistrer" → dialog système → sauvegarder dans Downloads → vérifier fichier accessible depuis Fichiers
- [x] 6.8 Android : "Partager…" → feuille de partage → envoyer par e-mail → vérifier pièce jointe correcte
- [x] 6.9 Android SyncReadOnly : vérifier onglet "Données" accessible, bouton "Importer" grisé, boutons Export actifs
