## Context

L'application dispose d'un écran Import CSV (index 4 dans la navigation, `_writeOnlyIndices = {1, 4}`). L'export est une opération de lecture pure — accessible même en SyncReadOnly. Le parseur actuel (`csv_parser.dart`) suppose le séparateur `;` et écrase toujours `updated_at` avec `DateTime.now()`.

Dépendances actuelles pertinentes : `file_picker ^8.0.0` (déjà présent), `share_plus` absent.

## Goals / Non-Goals

**Goals:**
- Exporter toutes les bouteilles (ou stock seul) en CSV fidèle (round-trip `updated_at`)
- Rendre le séparateur configurable à l'import et à l'export
- Fonctionner sur Windows (FilePicker) et Android (FilePicker save + share_plus)
- Accessible en SyncReadOnly (lecture pure)

**Non-Goals:**
- Détection automatique du séparateur à l'import
- Filtres fins à l'export (appellation, couleur…)
- Formats non-CSV (XLS, JSON…)
- Mode 3 Android local

## Decisions

### D1 — Fusion Import + Export dans un onglet "Données"

**Décision** : l'onglet "Import CSV" (index 4) devient "Données", accessible en SyncReadOnly (retiré de `_writeOnlyIndices`). La section Import est désactivée en lecture seule (bouton grisé + snackbar), la section Export reste toujours active.

**Alternative écartée** : nouvel onglet dédié Export — alourdit la navigation pour une feature qui ne justifie pas une destination séparée.

**Impacte** : `adaptive_layout.dart` (label, icône `import_export`, retrait index 4 de `_writeOnlyIndices`, badge cadenas sur le bouton Import uniquement au lieu de l'onglet entier), `import_csv_screen.dart` renommé ou encapsulé dans un nouvel `export_import_screen.dart`.

### D2 — CsvExportService : service pur sans Riverpod provider

**Décision** : `CsvExportService` est un objet Dart simple (pas de `@riverpod`). Il reçoit une `List<Bouteille>` et un séparateur, retourne une `String`. La récupération des données et l'écriture du fichier restent dans l'UI layer (`ExportCsvScreen`).

**Rationale** : opération one-shot sans état persistant — un provider serait du sur-ingénierie.

### D3 — DAO : méthode one-shot `getBouteillesForExport`

**Décision** : ajouter `Future<List<Bouteille>> getBouteillesForExport({required bool stockOnly})` dans `BouteilleDao`. `stockOnly: true` → `WHERE date_sortie IS NULL`, `false` → toutes les bouteilles.

**Rationale** : l'export n'a pas besoin d'un stream réactif. Une méthode `Future` suffit et évite de garder un stream ouvert pendant l'opération.

### D4 — Écriture fichier Android : FilePicker saveFile + share_plus

**Décision** :
- **Windows** : `FilePicker.platform.saveFile(fileName: 'cave_YYYY-MM-DD.csv', allowedExtensions: ['csv'])` → retourne le chemin → `dart:io File.writeAsBytes()`
- **Android** : deux actions distinctes :
  1. `FilePicker.platform.saveFile(...)` → dialog Android "Enregistrer sous" (ACTION_CREATE_DOCUMENT) → permet de choisir Downloads, Drive, etc. depuis le sélecteur système
  2. `share_plus` `SharePlus.instance.shareXFiles([XFile(tempPath)])` → feuille de partage → Drive, e-mail, Bluetooth…
  
Pour Android l'export écrit d'abord dans `getTemporaryDirectory()` puis utilise soit FilePicker soit share_plus selon l'action choisie.

**Alternative écartée** : MediaStore plugin (`media_store_plus`) — dépendance supplémentaire non justifiée car `FilePicker.saveFile` couvre le cas Downloads via le sélecteur système.

### D5 — Séparateur à l'import : paramètre `separator` dans `parseCsv`

**Décision** : `parseCsv(String content, {String separator = ';'})`. `_splitLine` reçoit également `separator`. `ImportCsvScreen` ajoute un `SegmentedButton<String>` avec les 3 options (`;`, `,`, `\t`) avant le bouton import.

### D6 — Colonne `updated_at` à l'import

**Décision** : `_rowToCompanion` lit `row['updated_at']` ; si la valeur est un ISO8601 valide → conservée ; sinon → `DateTime.now()`. Cela rend l'import idempotent sur un CSV exporté par l'app.

### D7 — Ordre et nommage des colonnes CSV exportées

**Décision** : même noms snake_case que le parseur d'import, même ordre que les champs `bouteilles.dart`, `updated_at` en dernière colonne. Header complet :

```
id;domaine;appellation;millesime;couleur;cru;contenance;emplacement;date_entree;date_sortie;prix_achat;garde_min;garde_max;commentaire_entree;note_degus;commentaire_degus;fournisseur_nom;fournisseur_infos;producteur;updated_at
```

Les valeurs null → champ vide. Les valeurs contenant le séparateur ou des guillemets → entre guillemets doubles (`"valeur;avec;points"`, guillemets internes doublés).

### D8 — Encodage UTF-8 BOM

**Décision** : le CSV commence par le BOM UTF-8 (`0xEF 0xBB 0xBF`). Compatibilité Excel/LibreOffice sans configuration de l'utilisateur.

## Risks / Trade-offs

- **`FilePicker.saveFile` non testé sur toutes versions Android** → risque de régression sur Android < 10. Mitigation : tester sur émulateur API 29 et 33.
- **`share_plus` absente des dépendances** → à ajouter dans `pubspec.yaml`. Vérifier compatibilité avec la version Flutter actuelle (3.41.6).
- **Export lent sur grande base** → génération synchrone du CSV string. Pour une cave de quelques centaines de bouteilles ce n'est pas un problème. Pas d'async streaming nécessaire.
- **Fusion Import+Export dans un onglet** → l'onglet n'est plus dans `_writeOnlyIndices`, le badge cadenas disparaît au niveau de l'onglet. Compensation : badge cadenas sur le bouton "Importer" interne, snackbar identique au comportement actuel.

## Open Questions

- Aucune — toutes les décisions ont été tranchées avant la rédaction de ce design.
