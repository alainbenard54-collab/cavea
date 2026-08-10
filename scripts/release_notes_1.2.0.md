Cavea est une application de gestion de cave à vin personnelle. Elle fonctionne entièrement en local — vos données restent sur votre machine ou dans votre propre espace cloud (Google Drive ou Dropbox). Aucun compte Cavea, aucune donnée transmise à un tiers.

Cavea is a personal wine cellar management application. It works entirely locally — your data stays on your machine or in your own cloud space (Google Drive or Dropbox). No Cavea account, no data sent to third parties.

---

## ✨ Nouveautés v1.2.0 / What's new in v1.2.0

### 📱 Mode local Android
Cavea fonctionne désormais sur Android sans aucun compte cloud. Les données sont stockées directement sur l'appareil — comme en mode local sur PC.
Cavea now works on Android without any cloud account. Data is stored directly on the device — like local mode on PC.

### 🍾 Données exemple intégrées
Quand la cave est vide, un bouton « Importer les données exemple » apparaît directement dans l'app. 50 bouteilles en stock + 20 consommées, toutes couleurs et stades de maturité — téléchargement automatique, aucun fichier à manipuler.
When the cellar is empty, an "Import sample data" button appears directly in the app. 50 bottles in stock + 20 consumed, all colours and maturity stages — automatic download, no file to handle.

### 🗑️ Réinitialisation de la base
Nouveau bouton dans ↔️ Données → « Zone de danger » pour repartir d'une cave vierge après les tests. Dialogue de confirmation avant suppression.
New button in ↔️ Data → "Danger zone" to start fresh after testing. Confirmation dialog before deletion.

### Corrections / Bug fixes
- Android : indicateur de mode (local / partagé) dans la barre de navigation
- Android : flux « Changer de fournisseur » et « Revenir en local » corrigés
- Toutes les URLs publiques migrées vers cavea.abapps.fr

---

## Fonctionnalités / Features (cumul depuis v1.0)

- Windows, Linux, Android — mode local et mode partagé / Windows, Linux, Android — local and shared mode
- Mode partagé Google Drive et Dropbox / Google Drive and Dropbox shared mode
- Sélection multiple — Déplacer / Consommer en lot / Multi-select — Bulk Move / Consume
- Navigation par emplacement avec arbre hiérarchique / Location browser with tree view
- Historique des consommations + réhabilitation / Consumption history + restore
- Fiche complète éditable par bouteille / Full editable bottle detail screen
- Export CSV configurable (séparateur, périmètre) / Configurable CSV export
- Français / Anglais — détection automatique / French / English — auto-detection

---

## 📥 Installation

### Windows

**Prérequis / Requirements**
- Windows 10 version 1809 (Build 17763) ou Windows 11 — 64 bits
- Windows 10 version 1809 (Build 17763) or Windows 11 — 64-bit

**Étapes / Steps**
1. Télécharger `Cavea-1.2.0-windows-setup.exe` ci-dessous / Download below
2. Double-cliquer sur le fichier / Double-click the file
3. Si Windows SmartScreen affiche un avertissement → « Informations complémentaires » puis « Exécuter quand même » / If Windows SmartScreen shows a warning → "More info" then "Run anyway"

> ℹ️ L'avertissement SmartScreen est normal pour une application open source non signée par un certificat commercial. Le code source est disponible sur ce dépôt. / The SmartScreen warning is normal for an open source app not signed with a commercial certificate. Full source code is available in this repository.

Pour mettre à jour : téléchargez et exécutez le nouvel installateur — il remplace l'installation existante automatiquement. / To update: download and run the new installer — it replaces the existing installation automatically.

---

### Linux (Debian / Ubuntu)

**Prérequis / Requirements**
- Ubuntu 22.04+ ou Debian 11+ — 64 bits / Ubuntu 22.04+ or Debian 11+ — 64-bit

**Étapes / Steps**
1. Télécharger `cavea_1.2.0_amd64.deb` ci-dessous / Download below
2. Installer / Install:

```bash
sudo dpkg -i cavea_1.2.0_amd64.deb
sudo apt-get install -f
```

Puis lancer depuis le menu applications ou / Then launch from the applications menu or:
```bash
cavea
```

---

### Android

**Google Play Store** — en cours de validation / under review
> Le lien Play Store sera ajouté ici dès validation par Google (prévu dans les prochaines semaines). / The Play Store link will be added here once approved by Google (expected within the next few weeks).

**APK direct (installation manuelle) / Direct APK (side-loading)**
Télécharger `app-arm64-v8a-release.apk` (téléphones récents 64 bits) ou `app-armeabi-v7a-release.apk` (appareils plus anciens) ci-dessous.

Download `app-arm64-v8a-release.apk` (recent 64-bit phones) or `app-armeabi-v7a-release.apk` (older devices) below.

> ℹ️ Installation hors Play Store : activer « Sources inconnues » dans Paramètres Android → Sécurité. / Side-loading: enable "Unknown sources" in Android Settings → Security.

---

## 🧪 Test et découverte / Test and discovery

Les données exemple sont désormais **intégrées à l'application** — aucun fichier CSV à télécharger. Quand la cave est vide, cliquez sur « Importer les données exemple » pour démarrer immédiatement.

Sample data is now **built into the application** — no CSV file to download. When the cellar is empty, click "Import sample data" to get started immediately.

Pour réinitialiser la cave après les tests : ↔️ Données → « Zone de danger » → « Réinitialiser la base ».
To reset after testing: ↔️ Data → "Danger zone" → "Reset database".

Pour les instructions détaillées / For detailed instructions:
🇫🇷 [Découverte avec les données d'exemple](https://cavea.abapps.fr/fr/00-decouverte.html)
🇬🇧 [Getting started with sample data](https://cavea.abapps.fr/en/00-discovery.html)

---

## ⚙️ Modes de fonctionnement / Operating modes

**Mode Local (PC + Android)** — Cave.db stocké localement sur l'appareil, aucune connexion requise. / Cave.db stored locally on the device, no connection required.

**Mode Partagé** — Cave.db partagé via Google Drive ou Dropbox entre PC Windows, Linux et Android. Verrou automatique pour éviter les conflits. / Cave.db shared via Google Drive or Dropbox across Windows, Linux and Android. Automatic lock to prevent conflicts.

---

## 📖 Documentation
🇫🇷 [Guide utilisateur (français)](https://cavea.abapps.fr/fr/)
🇬🇧 [User guide (English)](https://cavea.abapps.fr/en/)
