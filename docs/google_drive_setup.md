# Configuration Google Drive pour Cavea

Ce guide explique comment activer la synchronisation Google Drive dans Cavea selon votre cas d'usage.

---

## Quel mode choisir ?

| Mode | Situation | Google Drive requis ? |
|---|---|---|
| **Mode 1 — Windows seul** | Un seul PC, cave.db local | ❌ Rien à faire |
| **Mode 2 — Partage** | Plusieurs appareils partageant la même cave | ✅ Configuration nécessaire |
| **Mode 3 — Android seul** | Un seul Android, cave.db local | ❌ Rien à faire (futur) |

**Mode 2 couvre toutes les combinaisons de partage :**
- Windows + Android (cas le plus courant)
- Plusieurs PC Windows partageant la même cave
- Plusieurs Android partageant la même cave

La règle est simple : **un seul appareil sans partage = Mode 1 ou 3, aucune clé requise. Dès que vous partagez entre appareils = Mode 2, configuration nécessaire.**

---

## Ce qu'est Google Drive dans ce contexte

Cavea ne stocke pas vos données sur un serveur tiers : votre fichier `cave.db` reste **votre fichier**. Google Drive sert uniquement de « clé USB virtuelle » pour le transférer entre vos appareils.

Concrètement :
- Quand vous cliquez **Synchroniser**, Cavea envoie `cave.db` vers votre espace Drive privé
- Sur l'autre appareil, Cavea télécharge ce même fichier
- Un mécanisme de **verrouillage** empêche deux appareils de modifier la base en même temps
- La configuration (credentials) est à faire une fois par appareil participant au partage

---

## Ce qu'est GCP (Google Cloud Platform)

Pour qu'une application ait le droit d'accéder à Google Drive, Google exige qu'elle soit **enregistrée** — comme un utilisateur crée un compte pour accéder à un service. Cet enregistrement se fait sur la [Google Cloud Console](https://console.cloud.google.com), la plateforme de développement de Google. C'est **gratuit** pour un usage personnel.

L'enregistrement génère des **identifiants** (un code d'application) que Cavea utilisera pour prouver à Google qu'il s'agit bien de votre application personnelle.

---

## Étape A — Créer votre projet GCP (une seule fois)

> Durée estimée : 15–20 minutes. À faire une seule fois, quelle que soit la combinaison d'appareils.

**A-1.** Ouvrez [console.cloud.google.com](https://console.cloud.google.com) et connectez-vous avec votre compte Google (le même que celui que vous utiliserez pour Drive).

**A-2.** Cliquez sur le sélecteur de projet en haut à gauche → **Nouveau projet**.
- Nom : `Cavea` (ou ce que vous voulez)
- Organisation : laissez vide
- Cliquez **Créer**

**A-3.** Dans le menu de gauche : **APIs & Services → Bibliothèque**.
- Cherchez `Google Drive API`
- Cliquez sur le résultat → **Activer**

**A-4.** Dans le menu de gauche : **APIs & Services → Écran de consentement OAuth**.
- Type d'utilisateur : **Externe** → Créer
- Remplissez :
  - Nom de l'application : `Cavea`
  - E-mail d'assistance : votre adresse
  - E-mail du développeur (en bas) : votre adresse
- Cliquez **Enregistrer et continuer** jusqu'à la fin (les autres champs sont optionnels)
- Sur la page **Utilisateurs de test** : ajoutez votre propre adresse e-mail Google

**A-5.** Dans le menu de gauche : **APIs & Services → Identifiants** → **Créer des identifiants**.

→ Continuez selon votre mode ci-dessous.

---

## Mode 2 — PC Windows + Android

### Partie B — Identifiants Desktop (pour le PC)

**B-1.** Dans **Créer des identifiants** → **ID client OAuth 2.0**
- Type d'application : **Application de bureau**
- Nom : `Cavea Desktop`
- Cliquez **Créer**

**B-2.** Une fenêtre affiche votre **ID client** et votre **Secret client**.
- Téléchargez le fichier JSON (bouton de téléchargement) **ou** notez les deux valeurs

**B-3.** Créez le fichier `google_desktop_secrets.json` avec ce contenu :

```json
{
  "client_id": "VOTRE_ID_CLIENT.apps.googleusercontent.com",
  "client_secret": "VOTRE_SECRET_CLIENT"
}
```

**B-4.** Placez ce fichier **à côté de l'exécutable Cavea** :

```
C:\...\cavea\
├── cavea.exe
└── google_desktop_secrets.json   ← ici
```

> ⚠️ Ne partagez jamais ce fichier. Ne le committez pas dans Git (il est déjà dans `.gitignore`).

---

### Partie C — Identifiants Android (pour le smartphone)

> Cette partie nécessite Android Studio ou le SDK Android installé pour obtenir l'empreinte SHA-1 de votre application.

**C-1.** Dans **Créer des identifiants** → **ID client OAuth 2.0**
- Type d'application : **Android**
- Nom : `Cavea Android`
- Nom du package : `com.example.cavea` (vérifiez dans `android/app/build.gradle` la ligne `applicationId`)

**C-2.** Empreinte SHA-1 : dans un terminal PowerShell, exécutez :

```powershell
# Si vous avez Android Studio installé :
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

Repérez la ligne `SHA1:` et copiez la valeur (format `AA:BB:CC:...`).

**C-3.** Collez le SHA-1 dans le formulaire GCP → **Créer**

**C-4.** Dans le menu de gauche : **APIs & Services → Identifiants**, cliquez sur les trois points à droite de votre client Android → **Télécharger le fichier de configuration**

Cela télécharge `google-services.json`.

**C-5.** Placez ce fichier dans :

```
android/
└── app/
    └── google-services.json   ← ici
```

**C-6.** Ouvrez `android/settings.gradle.kts` et ajoutez le plugin google-services dans le bloc `plugins {}` existant :

```kotlin
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false   // ← ajouter cette ligne
}
```

**C-7.** Ouvrez `android/app/build.gradle.kts` et ajoutez `id("com.google.gms.google-services")` dans le bloc `plugins {}` existant :

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")   // ← ajouter cette ligne
}
```

---

## Mode 3 — Android seul (futur)

Mode 3 = un seul Android avec `cave.db` stocké localement sur l'appareil. **Aucune configuration Google Drive n'est requise** — même principe que Mode 1 sur Windows. Ce mode n'est pas encore disponible dans la version actuelle de Cavea.

---

## Résumé des fichiers à créer/placer

| Fichier | Emplacement | Mode concerné |
|---|---|---|
| `google_desktop_secrets.json` | À côté de `cavea.exe` | Mode 2 PC |
| `google-services.json` | `android/app/` | Mode 2 ou 3 Android |

Les templates et instructions sont dans `assets/google_desktop_secrets.json.template`.
