# ⚙️ Settings

Configure the app: cellar location, default values, reference lists, and sync mode.

## Open Settings

Tap the **⚙️ Settings** tab in the navigation. Accessible in Local mode and ☁️ Shared mode (even in 🔒 read-only mode).

## 1. Cellar location (Local mode only)

Shows the folder containing `cave.db`. Tap **Edit** to choose a different folder via the file picker.

> A restart is required for the path change to take effect.

This section does not appear in ☁️ Shared mode.

## 2. Bulk add — default values

Configure the pre-filled values in the **➕ Add** form:

- **Default colour**: select from the reference list. The value will be pre-selected when the form opens if it is in the list.
- **Default volume**: enter the value (e.g. "75 cl"). It will be pre-filled in the form.

## 3. Reference lists

Three configurable lists that feed the dropdowns in the add and edit forms:

### Colours
Default values: Blanc, Blanc effervescent, Blanc liquoreux, Blanc moelleux, Rosé, Rosé effervescent, Rouge.

### Volumes
Default values: 37.5 cl, 50 cl, 75 cl, 1.5 L (magnum).

### Classifications
Default values: 1ER CRU, CRU BOURGEOIS, CRU CLASSE, GRAND CRU, GRAND CRU CLASSE, SECOND VIN.

**For each list**:
- Tap the × on a chip to remove a value
- Type in the "Add" field and confirm to add a new value

> In the **➕ Add** form, the list shown is the union of the reference list and values already in the database. Reference values appear at the top of the list.

## 4. Sync mode

Shows the active cloud provider (☁️ Google Drive or ☁️ Dropbox) when ☁️ Shared mode is enabled.

**Change provider**: clears the stored OAuth tokens and relaunches the setup wizard. Useful to switch from Google Drive to Dropbox (or vice versa).

## 5. About

App version, Apache 2.0 licence, and link to dependency licences.

## See also

- [01 — First start](01-first-start.md)
- [02 — Add bottles](02-add-bottles.md)
- [12 — Shared mode](12-shared-mode.md)
