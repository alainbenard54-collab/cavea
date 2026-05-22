# 🔄 Shared mode

Understanding and using Shared mode: indicators, lock, save, and clean exit.

## General principle

In shared mode ☁️, the `cave.db` file is hosted on ☁️ Google Drive or ☁️ Dropbox. Multiple devices can access it, but **only one can write at a time** (exclusive lock).

> **Important**: Cavea always works on a **local copy** of `cave.db`. All your changes (adding, consuming, moving…) are saved locally first. They are only uploaded to the shared cloud storage when you **save** — either manually or on exit. Without an explicit save, your changes remain on your device only and may be lost.

## Indicators

A permanent icon in the navigation shows the active mode and lock status.

### Mode icon (always visible)

| Icon | Meaning |
|---|---|
| 💻 PC (grey) | Local mode — data on this device only |
| ☁️ Cloud (blue) | Shared mode — data on Google Drive or Dropbox |

### Lock icon (Shared mode only)

| Icon | Meaning |
|---|---|
| 🔓 Open padlock | Write mode (green icon) — you hold the lock |
| 🔒 Closed padlock | Read-only mode (amber icon) — another device holds the lock |
| ↻ Spinning icon | Save in progress (blue icon) |
| ⚠️ Error icon | Save error (red icon) |

## Buttons in Shared mode

### In write mode 🔓

**On PC (Windows / Linux)**: a **💾 Save** button appears in the navigation panel. It triggers an immediate upload to the cloud without closing the app.

**On Android**: two icons appear in the navigation bar:
- 💾 **Save** (green floppy disk icon): immediate upload to the cloud
- **Quit** (red exit icon): save + lock release + close app

### In read-only mode 🔒

A **🔓 Take over** button is shown. It lets you acquire the write lock if the other device has released it. A confirmation dialog appears before the lock is acquired.

## Lock lifecycle

### Startup

1. Cavea creates a "lock" file on the cloud to signal it has the write token
2. Cavea downloads the latest version of `cave.db` from the cloud
3. The app opens in write mode 🔓

**If another device already holds the lock**: Cavea opens in **read-only mode** 🔒. A dialog offers to stay in read-only mode or quit.

### Clean exit

**On PC (Windows / Linux)**:
1. Close the app window normally
2. Cavea saves `cave.db` to the cloud and releases the lock
3. Other devices can then acquire the lock

**On Android**:
- Use the **Quit** button (red exit icon) in the navigation bar (only visible in write mode)
- This button saves to the cloud, releases the lock, then closes the app

> ⚠️ **Do not use the Home button or task switcher to exit.** The lock will not be released (other devices remain blocked in read-only) and **any changes since the last save will not be uploaded to the shared cellar**. On the next startup, if the lock still belongs to you, a dialog will ask you to choose between uploading your local changes to the shared cellar or reverting to the shared version.

### Crash recovery

On the next startup, if the lock belongs to the same device:
- Cavea resolves the situation automatically and offers to re-upload your local copy or download the cloud version
- On PC, a "Previous session interrupted" dialog may appear

## Read-only mode — what is accessible

| Feature | Read-only mode 🔒 |
|---|---|
| 🍷 Browse stock | ✅ |
| Filter / search | ✅ |
| ℹ️ Bottle details (read) | ✅ |
| 📦 Browse by location | ✅ |
| **History** 🕐 | ✅ |
| ↔️ CSV export | ✅ |
| ⚙️ Settings | ✅ |
| ➕ Add bottles | ❌ |
| 🍸 Consume / ↕️ Move / ✏️ Edit | ❌ |
| ↔️ CSV import | ❌ |

## Switch cloud provider

In **⚙️ Settings > Sync mode**, tap **Change provider**. This clears the stored tokens and relaunches the setup wizard.

## See also

- [01 — First start](01-first-start.md) (initial Shared mode setup)
- [13 — Settings](13-settings.md)
