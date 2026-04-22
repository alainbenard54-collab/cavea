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
- Maturity levels: `tropJeune` (blue) / `optimal` (green) / `aBoireUrgent` (red) / `sansDonnee` (grey)
- Within each maturity level, urgency sort = `age - gardeMax` descending (higher = more overdue)

**Field protection rules — critical for edit forms:**

These fields must **never** be exposed in a generic edit form. They are only writable via dedicated actions:

| Field | Protected via |
|---|---|
| `id` | Never editable (primary key) |
| `updated_at` | Auto-managed by app |
| `date_sortie` | Only via "Consommer" action |
| `note_degus` | Only via "Consommer" action |
| `commentaire_degus` | Only via "Consommer" action |

All other fields are editable in the full bottle edit form (V1 feature, not MVP).

---

## MVP development order

1. ✅ drift model + `cave_clean.csv` import
2. ✅ Stock view + filters (couleur multi-sélect, appellation, millésime, recherche texte, layout adaptatif, table desktop triable)
3. ✅ Maturity integrated into stock view (colonne GARDE colorée + delta, FilterChips maturité multi-sélect, tri urgence secondaire — **pas d'écran séparé "Quoi boire ?"**)
4. `bottle-actions`: BottomSheet d'actions rapides sur clic bouteille (Déplacer + Consommer + accès fiche complète)
5. Bulk add (single form → N identical bottles)
6. ~~Change location~~ → fusionnée dans `bottle-actions` (étape 4)
7. Sync mechanism (lock / download / upload)
8. Settings (mode selection, shared folder path)

Do not implement V1 or V2 features before the MVP is complete.

---

## bottle-actions — spec décidée (étape 4 MVP)

Clic sur une ligne du stock → `BottomSheet` modal avec :

1. **Déplacer** : saisie libre de l'emplacement avec autocomplétion sur les emplacements existants en base → `UPDATE emplacement` uniquement, pas de `date_sortie`
2. **Consommer** : date de consommation (défaut = aujourd'hui, modifiable via DatePicker pour déclaration tardive), note /10 optionnelle, commentaire de dégustation optionnel → `UPDATE date_sortie + note_degus + commentaire_degus`
3. **Modifier la fiche** : pointe vers un écran d'édition complète — **interface prête en MVP, implémentation V1**. Affiche "Fonctionnalité à venir" en MVP. Champs protégés exclus (voir ci-dessus).
4. **Annuler** : ferme le BottomSheet

---

## V1 features (post-MVP — do not implement before MVP complete)

- **Édition complète d'une bouteille** : formulaire avec tous les champs non protégés modifiables. Accessible depuis le BottomSheet "Modifier la fiche" (l'entrée de navigation est déjà en place en MVP).
- Fiche lecture seule d'une bouteille (détail complet)

---

## Out of scope (do not implement)

- Multi-user or concurrent access management
- Backend server or remote database
- Relational normalisation of domains / appellations
- Visual cave map, drag & drop
- Advanced oenology fields (robe, nose, palate)
- Complex ML / AI features
- iOS (Apple Developer cost)
