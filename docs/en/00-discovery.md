# 🧪 Getting started with sample data

Cavea ships with two sample CSV files so you can explore the app with real data, without having to enter your bottles manually.

These files are available for download on the [GitHub release page](https://github.com/alainbenard54-collab/cavea/releases/latest):

- `cavea_sample_en.csv` — columns and data in English
- `cavea_sample_fr.csv` — columns and data in French (same content)

## What's in the files

- **50 bottles in stock** spread across a cellar with 4 racks: `Cave > Casier 1`, `Cave > Casier 2`, `Cave > Casier 3 > Gauche`, `Cave > Casier 3 > Droite`, `Cave > Casier 4`
- **20 consumed bottles** with tasting notes
- Representative French wines: Bordeaux, Burgundy, Rhône, Alsace, Champagne, Provence
- All colours: Red, White, Rosé, Sparkling white, Sweet white
- All maturity stages: too young, optimal, drink now, no aging data
- Realistic domains and vintages ranging from 2012 to 2023

## Importing the sample data

### 1. Download the file

On the [GitHub release page](https://github.com/alainbenard54-collab/cavea/releases/latest), download `cavea_sample_en.csv` (or `cavea_sample_fr.csv` if your interface is in French).

### 2. Set up Cavea

If you have not yet configured the app, follow scenario [01 — First start](01-first-start.md). Local mode is sufficient for exploring the app.

### 3. Run the import

1. Open the **↔️ Data** tab
2. Make sure the separator is set to **`;` (semicolon)**
3. Tap **Import** and select the file
4. Leave "Overwrite existing rows" **unchecked**
5. Confirm — the import inserts 70 bottles (50 in stock + 20 consumed)

> These files include a unique `id` column per bottle. Re-importing the same file does not create duplicates.

## Resetting after discovery

### Full reset (recommended)

Uninstall Cavea. On Windows and Linux, the uninstaller offers to delete your configuration. On Android, uninstalling automatically removes all app data.

Then reinstall the app normally.

### Data-only reset — Local mode, Windows and Linux

If you are using **Local mode** and want to keep your settings (cellar path) but start with an empty cellar:

1. Close Cavea
2. Delete the `cave.db` file from the folder configured in **⚙️ Settings > Cellar location**
3. Relaunch Cavea — the app automatically creates a new empty cellar at the same location

> **Shared mode**: deleting the local `cave.db` does not have the intended effect. On the next launch, Cavea automatically re-downloads the copy from the cloud — the shared cellar is not lost, but you do not start with an empty cellar either. To reset in Shared mode, first switch to Local mode via **⚙️ Settings > Switch to local**, then delete `cave.db`.

> On Android, `cave.db` is in protected app storage — uninstalling is the only accessible option.

## See also

- [01 — First start](01-first-start.md)
- [11 — Import / Export CSV](11-import-export.md)
