🇫🇷 [Version française](README.fr.md)

# Cavea — Personal wine cellar manager

A personal Flutter application for managing your wine cellar. Available on Windows, Linux, and Android.

## Philosophy

Cavea is intentionally simple: no photos, no barcodes, no advanced oenology fields, no advanced supplier data, no server to deploy. The focus is on what matters day-to-day — tracking your stock (entries, exits…), knowing where each bottle is, understanding when to drink it, and recording what you thought of it.

One row in the database = one physical bottle.

## Deployment modes

### Local mode (single device)

Your cellar lives in a `cave.db` file on your local disk. No internet connection, no account, no cloud — just your data on your machine.

This mode is available on **Windows** and **Linux**. A fully local Android mode (without cloud) is planned for a future version.

This is the recommended starting point. You can switch to Shared mode later from Settings.

### Shared mode (multiple devices)

The `cave.db` file is hosted on **Google Drive** or **Dropbox**. Any combination of devices can access the same cellar — Windows + Android, two Windows machines, etc.

**How the lock works**: when you open Cavea, it downloads the latest copy of `cave.db` and acquires an exclusive write lock. Other devices can still open the app but will be in **read-only mode** until you close Cavea — which saves the file back and releases the lock.

This is a deliberate design choice: no conflict resolution, no merge, no sync complexity. One device writes at a time.

## Platforms

| Platform | Status |
|---|---|
| Windows desktop | Primary target |
| Android | Primary target |
| Linux desktop | Supported |

iOS is not supported (Apple Developer Program cost).

## Installation

Download the latest release from the [releases page](../../releases):

- **Windows**: `CaveaSetup-x.x.x.exe` — double-click to install
- **Linux**: `cavea-x.x.x.deb` — Debian/Ubuntu package (`sudo dpkg -i cavea-x.x.x.deb`)
- **Android**: `cavea-x.x.x.apk` — enable "Install unknown apps" in your Android settings before installing. Play Store coming soon.

## Tech stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3 (Dart) |
| Database | drift (SQLite ORM, reactive streams) |
| State management | Riverpod |
| Navigation | go_router |
| UI | Material 3 |

## For developers

### Build

**Prerequisites**: [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable), Dart (included with Flutter).

```bash
git clone <repo-url>
cd cavea
flutter pub get
flutter run -d windows   # or -d linux, or connect an Android device
```

### Run tests

```bash
flutter test
```

### OAuth configuration (Shared mode)

To use Shared mode, you need OAuth credentials for your chosen cloud provider.

- **Google Drive**: see [docs/google_drive_setup.md](docs/google_drive_setup.md)
- **Dropbox**: create a Dropbox app at the [Dropbox developer console](https://www.dropbox.com/developers/apps), enable PKCE, add the redirect URI `http://localhost:8080/auth`, and note your App key. Enter it in Settings when prompted.

Credentials are stored locally in the system keychain (Windows Credential Manager / libsecret on Linux / Android Keystore).

## User documentation

See [docs/README.md](docs/README.md) for the complete user guide — 14 scenarios available in French and English, including a [getting started with sample data](docs/en/00-discovery.md) guide.

## License

Apache 2.0 — see [LICENSE](LICENSE).
