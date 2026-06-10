Cavea est une application de gestion de cave à vin personnelle. Elle fonctionne entièrement en local — vos données restent sur votre machine ou dans votre propre espace cloud (Google Drive ou Dropbox). Aucun compte Cavea, aucune donnée transmise à un tiers.

Cavea is a personal wine cellar management application. It works entirely locally — your data stays on your machine or in your own cloud space (Google Drive or Dropbox). No Cavea account, no data sent to third parties.

---

## ✨ Fonctionnalités / Features

- Sélection multiple — Déplacer / Consommer en lot / Multi-select — Bulk Move / Consume
- Navigation par emplacement avec arbre hiérarchique / Location browser with tree view
- Historique des consommations + réhabilitation / Consumption history + restore
- Fiche complète éditable par bouteille / Full editable bottle detail screen
- Export CSV configurable (séparateur, périmètre) / Configurable CSV export (separator, scope)
- Support Google Drive et Dropbox / Google Drive and Dropbox support
- Support Linux desktop / Linux desktop support
- Français / Anglais — détection automatique / French / English — automatic detection

---

## 📥 Installation

### Windows

**Prérequis / Requirements**
- Windows 10 version 1809 (Build 17763) ou Windows 11 — 64 bits
- Windows 10 version 1809 (Build 17763) or Windows 11 — 64-bit

**Étapes / Steps**
1. Télécharger `Cavea-1.1.0-windows-setup.exe` ci-dessous / Download below
2. Double-cliquer sur le fichier / Double-click the file
3. Si Windows SmartScreen affiche un avertissement → "Informations complémentaires" puis "Exécuter quand même" / If Windows SmartScreen shows a warning → "More info" then "Run anyway"

> ℹ️ L'avertissement SmartScreen est normal pour une application open source non signée par un certificat commercial. Le code source est disponible sur ce dépôt. / The SmartScreen warning is normal for an open source app not signed with a commercial certificate. Full source code is available in this repository.

Pour mettre à jour : téléchargez et exécutez le nouvel installateur — il remplace l'installation existante automatiquement. / To update: download and run the new installer — it replaces the existing installation automatically.

---

### Linux (Debian / Ubuntu)

**Prérequis / Requirements**
- Ubuntu 22.04+ ou Debian 11+ — 64 bits / Ubuntu 22.04+ or Debian 11+ — 64-bit

**Étapes / Steps**
1. Télécharger `cavea_1.1.0_amd64.deb` ci-dessous / Download `cavea_1.1.0_amd64.deb` below
2. Installer / Install:

```bash
sudo dpkg -i cavea_1.1.0_amd64.deb
sudo apt-get install -f
```

Puis lancer depuis le menu applications ou / Then launch from the applications menu or:
```bash
cavea
```

---

### Android

Télécharger `app-arm64-v8a-release.apk` (téléphones récents 64 bits) ou `app-armeabi-v7a-release.apk` (appareils plus anciens) ci-dessous.

Download `app-arm64-v8a-release.apk` (recent 64-bit phones) or `app-armeabi-v7a-release.apk` (older devices) below.

> ℹ️ Installation hors Play Store : activer "Sources inconnues" dans Paramètres Android → Sécurité. / Side-loading: enable "Unknown sources" in Android Settings → Security.

**Play Store** — bientôt disponible / coming soon

---

---

## 🧪 Test et découverte / Test and discovery

Deux fichiers CSV d'exemple sont joints à cette release : `cavea_sample_fr.csv` et `cavea_sample_en.csv`.
Ils contiennent 50 bouteilles en stock et 20 consommées, couvrant toutes les couleurs et tous les stades de maturité.

Two sample CSV files are attached to this release: `cavea_sample_fr.csv` and `cavea_sample_en.csv`.
They contain 50 bottles in stock and 20 consumed, covering all colours and maturity stages.

**Import / Import** : ↔️ Données → Importer → sélectionner le fichier, séparateur `;` / ↔️ Data → Import → select file, separator `;`

Pour la réinitialisation et les détails d'utilisation / For reset instructions and full usage details:
🇫🇷 [Découverte avec les données d'exemple](https://cavea.abapps.fr/fr/00-decouverte.html)
🇬🇧 [Getting started with sample data](https://cavea.abapps.fr/en/00-discovery.html)

---

## ⚙️ Modes de fonctionnement / Operating modes

**Mode Local** — Cave.db stocké localement, aucune connexion requise. Idéal pour un usage mono-poste. / Cave.db stored locally, no connection required. Ideal for single-device use.

**Mode Partagé** — Cave.db partagé via Google Drive ou Dropbox entre PC Windows, Linux et Android. Verrou automatique pour éviter les conflits d'édition simultanée. / Cave.db shared via Google Drive or Dropbox across Windows, Linux and Android. Automatic lock to prevent simultaneous edit conflicts.

---

## 📖 Documentation
🇫🇷 [Guide utilisateur (français)](https://cavea.abapps.fr/fr/)
🇬🇧 [User guide (English)](https://cavea.abapps.fr/en/)
