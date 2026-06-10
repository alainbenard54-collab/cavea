<!-- Copier ce texte dans le champ "Release notes" de la release GitHub v1.0.0 -->
<!-- Copy this text into the "Release notes" field of the GitHub v1.0.0 release -->

## Cavea v1.0.0 — Windows

**Cavea** est une application de gestion de cave à vin personnelle. Elle fonctionne entièrement en local — vos données restent sur votre machine ou dans votre propre espace cloud (Google Drive ou Dropbox). Aucun compte Cavea, aucune donnée transmise à un tiers.

**Cavea** is a personal wine cellar management application. It works entirely locally — your data stays on your machine or in your own cloud space (Google Drive or Dropbox). No Cavea account, no data sent to third parties.

---

### 📥 Installation — Windows

**Prérequis / Requirements**
- Windows 10 version 1809 (Build 17763) ou Windows 11 — 64 bits
- Windows 10 version 1809 (Build 17763) or Windows 11 — 64-bit

**Étapes / Steps**
1. Télécharger `Cavea-1.0.0-windows-setup.exe` ci-dessous / Download `Cavea-1.0.0-windows-setup.exe` below
2. Double-cliquer sur le fichier / Double-click the file
3. Si Windows SmartScreen affiche un avertissement → cliquer **"Informations complémentaires"** puis **"Exécuter quand même"** / If Windows SmartScreen shows a warning → click **"More info"** then **"Run anyway"**

> ℹ️ L'avertissement SmartScreen est normal pour une application open source non signée par un certificat commercial. Le code source est entièrement disponible sur ce dépôt. / The SmartScreen warning is normal for an open source app not signed by a commercial certificate. The full source code is available in this repository.

---

### ⚙️ Modes de fonctionnement / Operating modes

**Mode Local (PC seul)**
- Cave.db stocké localement, aucune connexion requise
- Idéal pour un usage mono-poste
- Cave.db stored locally, no connection required
- Ideal for single-device use

**Mode Partagé (plusieurs appareils)**
- Cave.db partagé via Google Drive ou Dropbox
- Fonctionne entre PC Windows, Linux et Android
- Verrou automatique pour éviter les conflits d'édition simultanée
- Cave.db shared via Google Drive or Dropbox
- Works across Windows PC, Linux and Android
- Automatic lock to prevent simultaneous edit conflicts

---

### 📖 Documentation

🇫🇷 [Guide utilisateur (français)](https://cavea.abapps.fr/fr/)
🇬🇧 [User guide (English)](https://cavea.abapps.fr/en/)

---

### 🔄 Mises à jour / Updates

Pour mettre à jour, téléchargez et exécutez simplement le nouvel installateur — il remplace l'installation existante automatiquement.

To update, simply download and run the new installer — it replaces the existing installation automatically.

---

### 📋 Changements depuis v0.1.0 / Changes since v0.1.0

Voir [CHANGELOG](../../blob/master/CHANGELOG.md) pour le détail complet.
See [CHANGELOG](../../blob/master/CHANGELOG.md) for full details.

Principales nouveautés V1 / Main V1 features:
- Fiche complète éditable par bouteille / Full editable bottle detail screen
- Fiche lecture seule / Read-only bottle detail view
- Sélection multiple (Déplacer / Consommer en lot) / Multi-select (Bulk Move / Consume)
- Navigation par emplacement avec arbre hiérarchique / Location browser with tree view
- Historique des consommations / Consumption history
- Export CSV configurable / Configurable CSV export
- Support Dropbox en plus de Google Drive / Dropbox support in addition to Google Drive
- Support Linux desktop / Linux desktop support
- Internationalisation français / anglais / French / English internationalisation
- Documentation utilisateur intégrée / Integrated user documentation link
