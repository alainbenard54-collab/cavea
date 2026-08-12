Cavea est une application de gestion de cave à vin personnelle. Elle fonctionne entièrement en local — vos données restent sur votre machine ou dans votre propre espace cloud (Google Drive ou Dropbox). Aucun compte Cavea, aucune donnée transmise à un tiers.

Cavea is a personal wine cellar management application. It works entirely locally — your data stays on your machine or in your own cloud space (Google Drive or Dropbox). No Cavea account, no data sent to third parties.

---

## ✨ Nouveautés v1.3.0 / What's new in v1.3.0

### 📊 Tableau triable sur l'écran Emplacements
L'écran Emplacements bascule désormais vers un tableau triable en largeur ≥640px (desktop, paysage Android) — comme l'écran Stock. En dessous, la liste en tuiles reste utilisée.

The Locations screen now switches to a sortable table at ≥640px width (desktop, Android landscape) — same as the Stock screen. Below that, the tile list is still used.

### 🔧 Validation des emplacements centralisée
La validation du format d'emplacement (`Niveau1 > Niveau2 > Niveau3`) est désormais unifiée sur tous les points d'entrée — y compris l'import CSV, qui ne la vérifiait pas jusqu'ici. Les lignes d'import invalides sont maintenant signalées explicitement (snackbar + détail) au lieu d'être ignorées silencieusement.

Location format validation (`Level1 > Level2 > Level3`) is now unified across every entry point — including CSV import, which didn't check it before. Invalid import rows are now explicitly flagged (snackbar + detail) instead of being silently dropped.

### Corrections / Bug fixes
- Formats d'emplacement mal formés (espacement incorrect autour de `>`, caractères ambigus) désormais rejetés de façon cohérente partout / Malformed location formats (incorrect spacing around `>`, ambiguous characters) now consistently rejected everywhere
- Améliorations techniques internes : tests automatisés étendus (golden tests), mise à jour Flutter, intégration continue / Internal technical improvements: expanded automated tests (golden tests), Flutter update, continuous integration

---

## Fonctionnalités / Features (cumul depuis v1.0)

- Windows, Linux, Android — mode local et mode partagé / Windows, Linux, Android — local and shared mode
- Mode partagé Google Drive et Dropbox / Google Drive and Dropbox shared mode
- Sélection multiple — Déplacer / Consommer en lot / Multi-select — Bulk Move / Consume
- Navigation par emplacement avec arbre hiérarchique et vue tableau (≥640px) / Location browser with tree view and table view (≥640px)
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
1. Télécharger `Cavea-1.3.0-windows-setup.exe` ci-dessous / Download below
2. Double-cliquer sur le fichier / Double-click the file
3. Si Windows SmartScreen affiche un avertissement → « Informations complémentaires » puis « Exécuter quand même » / If Windows SmartScreen shows a warning → "More info" then "Run anyway"

> ℹ️ L'avertissement SmartScreen est normal pour une application open source non signée par un certificat commercial. Le code source est disponible sur ce dépôt. / The SmartScreen warning is normal for an open source app not signed with a commercial certificate. Full source code is available in this repository.

Pour mettre à jour : téléchargez et exécutez le nouvel installateur — il remplace l'installation existante automatiquement. / To update: download and run the new installer — it replaces the existing installation automatically.

---

### Linux (Debian / Ubuntu)

**Prérequis / Requirements**
- Ubuntu 22.04+ ou Debian 11+ — 64 bits / Ubuntu 22.04+ or Debian 11+ — 64-bit

**Étapes / Steps**
1. Télécharger `cavea_1.3.0_amd64.deb` ci-dessous / Download below
2. Installer / Install:

```bash
sudo dpkg -i cavea_1.3.0_amd64.deb
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

---

## 🧪 Test et découverte / Test and discovery

Les données exemple sont intégrées à l'application — aucun fichier CSV à télécharger. Quand la cave est vide, cliquez sur « Importer les données exemple » pour démarrer immédiatement.

Sample data is built into the application — no CSV file to download. When the cellar is empty, click "Import sample data" to get started immediately.
