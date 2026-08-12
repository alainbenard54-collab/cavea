Cavea est une application de gestion de cave à vin personnelle. Elle fonctionne entièrement en local — vos données restent sur votre machine ou dans votre propre espace cloud (Google Drive ou Dropbox). Aucun compte Cavea, aucune donnée transmise à un tiers.

Cavea is a personal wine cellar management application. It works entirely locally — your data stays on your machine or in your own cloud space (Google Drive or Dropbox). No Cavea account, no data sent to third parties.

---

## 🐛 Correctif v1.3.1 / Fix in v1.3.1

### Mode partagé Google Drive / Dropbox inutilisable sur l'installateur Windows
L'installateur Windows généré automatiquement (depuis v1.0.0) ne contenait pas les identifiants nécessaires au mode partagé — le choix de Google Drive ou Dropbox provoquait une erreur "Fichier de credentials introuvable". Le mode local (Mode 1) n'était pas concerné. Corrigé dans cette version : le mode partagé fonctionne à nouveau normalement sur l'installateur Windows téléchargé depuis GitHub.

The auto-generated Windows installer (since v1.0.0) was missing the credentials needed for shared mode — choosing Google Drive or Dropbox triggered a "Credentials file not found" error. Local mode (Mode 1) was not affected. Fixed in this version: shared mode now works correctly again on the Windows installer downloaded from GitHub.

Aucun changement fonctionnel côté application — seule la chaîne de fabrication de l'installateur est corrigée.

No functional application change — only the installer build pipeline was fixed.

---

## 📥 Installation

### Windows

**Prérequis / Requirements**
- Windows 10 version 1809 (Build 17763) ou Windows 11 — 64 bits
- Windows 10 version 1809 (Build 17763) or Windows 11 — 64-bit

**Étapes / Steps**
1. Télécharger `Cavea-1.3.1-windows-setup.exe` ci-dessous / Download below
2. Double-cliquer sur le fichier / Double-click the file
3. Si Windows SmartScreen affiche un avertissement → « Informations complémentaires » puis « Exécuter quand même » / If Windows SmartScreen shows a warning → "More info" then "Run anyway"

> ℹ️ L'avertissement SmartScreen est normal pour une application open source non signée par un certificat commercial. Le code source est disponible sur ce dépôt. / The SmartScreen warning is normal for an open source app not signed with a commercial certificate. Full source code is available in this repository.

Pour mettre à jour : téléchargez et exécutez le nouvel installateur — il remplace l'installation existante automatiquement. / To update: download and run the new installer — it replaces the existing installation automatically.

---

### Linux (Debian / Ubuntu)

**Prérequis / Requirements**
- Ubuntu 22.04+ ou Debian 11+ — 64 bits / Ubuntu 22.04+ or Debian 11+ — 64-bit

**Étapes / Steps**
1. Télécharger `cavea_1.3.1_amd64.deb` ci-dessous / Download below
2. Installer / Install:

```bash
sudo dpkg -i cavea_1.3.1_amd64.deb
sudo apt-get install -f
```

Puis lancer depuis le menu applications ou / Then launch from the applications menu or:
```bash
cavea
```

---

### Android

**APK direct (installation manuelle) / Direct APK (side-loading)**

Télécharger `app-arm64-v8a-release.apk` (téléphones récents 64 bits) ou `app-armeabi-v7a-release.apk` (appareils plus anciens) ci-dessous.

Download `app-arm64-v8a-release.apk` (recent 64-bit phones) or `app-armeabi-v7a-release.apk` (older devices) below.

> ℹ️ Installation hors Play Store : activer « Sources inconnues » dans Paramètres Android → Sécurité. / Side-loading: enable "Unknown sources" in Android Settings → Security.
