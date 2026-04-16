# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project purpose

Wine cellar data migration tool. Reads two raw CSV exports from a wine management app (`stock.csv` for current inventory, `historique.csv` for consumed/sold bottles) and produces a single normalized output file (`cave_clean.csv`).

## Running the script

```bash
python clean_stock_archive.py
```

All paths are relative — run from the project root. Outputs `cave_clean.csv` in the same directory.

## Data architecture

**Inputs** — semicolon-delimited CSVs with many columns exported from a wine app. Both files share the same schema.

**Output** — `cave_clean.csv` with 19 normalized fields (semicolon-delimited):

| Field | Notes |
|---|---|
| `id` | UUID generated at run time (not stable across reruns) |
| `domaine` | Mapped from `Domaine/Château` |
| `emplacement` | Built from `Cave` + `Rangement` → `"Cave > Etagère / Casier"` format |
| `date_entree` / `date_sortie` | Normalized to `YYYY-MM-DD`; `date_sortie` is blank for stock rows |
| `prix_achat` | Comma replaced with dot |
| `note_degus` / `commentaire_degus` / `fournisseur_infos` | Always blank (placeholders for future input) |

**Merging logic:** stock rows → `is_stock=True` (forces `date_sortie=""`) ; historique rows → `is_stock=False` (preserves `date_sortie`).

## Key implementation details

- `COLUMN_MAP` in `clean_stock_archive.py` is the single source of truth for input→output field mapping.
- `build_emplacement()` joins `Cave` and `Rangement` with ` > ` and splits `Etagère / Casier` style rangements on `/`.
- `parse_date()` handles multiple datetime formats and a `"paques YYYY"` edge case (maps to `YYYY-01-01`).
- IDs are not stable — each run regenerates all UUIDs.
