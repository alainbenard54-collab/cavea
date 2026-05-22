# First start

On the very first launch, Cavea automatically shows a **setup wizard**. You don't need to navigate to Settings — the wizard opens by itself as long as the app isn't configured.

## Step 1 — Choose your mode

Two modes are displayed:

- 💻 **Local mode** — cellar managed on a single device, `cave.db` file on the local disk, no cloud required
- 🔄 **Shared mode** — cellar shared between multiple devices via ☁️ Google Drive or ☁️ Dropbox

> On Android, only 🔄 Shared mode is available for now. 💻 Local mode on Android is planned for a future version.

Tap the card matching your choice.

## Step 2a — Local mode: choose the folder

1. Enter the path to the folder where `cave.db` will be created, or tap 📁 to browse your folders
2. Tap **Next**
3. Review the summary (mode + path) and tap **Start**

The app opens directly on the stock view (empty on first launch).

> To change this path later: **⚙️ Settings > Cellar location > Edit**.

## Step 2b — Shared mode: cloud connection

1. Choose your provider: **☁️ Google Drive** or **☁️ Dropbox**
2. Tap **Connect** — your browser opens for OAuth authentication
3. Once connected, Cavea checks if a cellar already exists in the cloud:

   **No cellar found** → tap **Create a new cellar**

   **Cellar found** → two options:
   - **Join** — downloads the existing cellar and acquires the write lock 🔒
   - **Overwrite** — replaces the remote cellar with an empty one (irreversible, double confirmation required)

The app opens on the stock view once setup is complete.

## Import existing data

If you have a CSV file of your cellar, see scenario [11 — Import/Export CSV](11-import-export.md) to import it in your first session.

## See also

- [02 — Add bottles](02-add-bottles.md)
- [12 — Shared mode](12-shared-mode.md)
- [13 — Settings](13-settings.md)
