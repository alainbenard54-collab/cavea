# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project purpose

Flutter application for personal wine cellar management. Single codebase compiled for Windows desktop (primary) and Android (mobile). No backend server, no cloud hosting — data lives in a local SQLite file (`cave.db`), optionally shared via a cloud storage API.

Full specifications are in `PRD.md` (features and priorities) and `ARCHITECTURE.md` (technical decisions). Read those files before proposing any significant change.

---

## Tech stack

| Layer | Choice | Notes |
|---|---|---|
| Framework | Flutter 3 (Dart) | Single codebase for desktop + mobile |
| Database | drift (SQLite) | Type-safe ORM, declarative migrations, reactive streams |
| State management | Riverpod | Integrates naturally with drift streams |
| Navigation | go_router | Declarative, handles desktop and mobile routes |
| UI | Material 3 | NavigationRail (desktop) / BottomNavigationBar (mobile), threshold 600px |

Do not introduce alternative state management (Provider, BLoC, GetX) or navigation solutions without an explicit decision.

---

## Deployment modes — critical for storage decisions

### Mode 1 — PC only (full local)
- `dart:io` direct access to `cave.db`
- No StorageAdapter, no sync, no lock — single copy, always open directly
- No cloud dependency of any kind

### Mode 2 — PC + Android (primary target)
- Both apps share `cave.db` via a **cloud API** (Google Drive or Dropbox)
- Sync is manual and symmetric: lock → download → work locally → upload → unlock
- `StorageAdapter` interface abstracts the cloud backend

### Mode 3 — Mobile only (future, out of MVP)
- Same architecture as Mode 2, only the active views differ

---

## Storage rules — enforce strictly

- Modes 2 and 3 **must** access shared storage via cloud API only — never via `dart:io` on a locally synced folder. This would break Android.
- `StorageAdapter` is the contract between `SyncService` and the cloud backend. Do not bypass this abstraction.
- `DriveStorageAdapter` and `DropboxStorageAdapter` are the concrete implementations — they encapsulate OAuth and API calls. `SyncService` must not know which backend is used.

---

## Data model

Single table `bouteilles`. One row = one physical bottle.

Key fields: `id` (UUID), `domaine`, `appellation`, `millesime`, `couleur`, `cru`, `contenance`, `emplacement`, `date_entree`, `date_sortie`, `prix_achat`, `garde_min`, `garde_max`, `commentaire_entree`, `note_degus`, `commentaire_degus`, `fournisseur_nom`, `fournisseur_infos`, `producteur`, `updated_at`.

**Business rules:**
- `date_sortie` empty → bottle in stock
- `date_sortie` set → bottle consumed / removed
- Moving a bottle = update `emplacement` — it is **not** a removal
- `emplacement` is a free-text hierarchy: `Niveau1 > Niveau2 > Niveau3`
- Maturity computed at runtime: `millesime + garde_min/max` vs `DateTime.now().year`

---

## MVP development order

1. drift model + `cave_clean.csv` import
2. Stock view + filters (colour, appellation, vintage, text search)
3. "What to drink?" view (colour-coded maturity indicators)
4. Consume action (sets `date_sortie = today`)
5. Bulk add (single form → N identical bottles)
6. Change location (movement, not a removal)
7. Sync mechanism (lock / download / upload)
8. Settings (mode selection, shared folder path)

Do not implement V1 or V2 features before the MVP is complete.

---

## Out of scope (do not implement)

- Multi-user or concurrent access management
- Backend server or remote database
- Relational normalisation of domains / appellations
- Visual cave map, drag & drop
- Advanced oenology fields (robe, nose, palate)
- Complex ML / AI features
- iOS (Apple Developer cost)
