# ↔️ Import / Export CSV

Import data from a CSV file or export your cellar to a CSV file.

## Prerequisites

- The **↔️ Data** tab is accessible even in 🔒 read-only mode (except the Import button)

## CSV Export

### 1. Open the Data tab

Tap the **↔️ Data** tab in the navigation.

### 2. Choose the scope

- **Stock only**: bottles currently in stock (no exit date)
- **All**: stock + consumed bottles (complete history)

### 3. Choose the column separator

| Separator | Recommended for |
|---|---|
| `;` (semicolon) | French Excel / LibreOffice configured in French |
| `,` (comma) | English Excel, Numbers (Mac), Google Sheets |
| Tab | Technical imports, command-line tools |

### 4. Run the export

Tap **Export**. The app generates a CSV file encoded in UTF-8 with BOM (compatible with Excel).

- **Windows**: a dialog asks where to save the file
- **Android**: a save dialog opens, then a share option (email, cloud, etc.)

The file contains all fields, including `updated_at` (the last modification date of each row).

## CSV Import

### 1. Format requirements

The CSV file must have:
- A header row with column names
- The separator configured in the UI (`;`, `,`, or tab)
- UTF-8 encoding (with or without BOM)

Recognised columns: `id`, `Domain`, `Appellation`, `Vintage`, `Colour`, `Cru`, `Volume`, `Location`, `Entry date`, `Exit date`, `Purchase price`, `Min aging`, `Max aging`, `Entry comment`, `Tasting rating`, `Tasting comment`, `Supplier name`, `Supplier info`, `Producer`, `Updated at`.

### 2. Run the import

In the **↔️ Data** tab, tap **Import**. Select the CSV file.

> In 🔒 read-only mode, the Import button is greyed out.

### 3. Import behaviour

Behaviour depends on whether the `id` column is present in the file.

**File exported from Cavea** (with `id` column):

Each row is identified by its UUID.

- **"Overwrite existing rows" unchecked** (default): rows already in the database with the same UUID are **skipped**. Reimporting the same file does not create duplicates.
- **"Overwrite existing rows" checked**: existing rows are **updated**, new rows are inserted. Use this to integrate corrections made in a spreadsheet.

**External file without `id` column**:

A new UUID is generated for each row on every import. Importing the same file twice will create duplicate rows.

> If the `Updated at` column is present, it is preserved (useful for migrating an existing history).

After import, a summary shows the number of rows inserted, updated, skipped, and in error.

## See also

- [01 — First start](01-first-start.md) (migrating an existing cellar)
- [13 — Settings](13-settings.md)
