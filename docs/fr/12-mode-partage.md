# 🔄 Mode Partagé

Comprendre et utiliser le Mode Partagé : signalétique, verrou, sauvegarde et fermeture propre.

## Principe général

En mode partagé ☁️, le fichier `cave.db` est hébergé sur ☁️ Google Drive ou ☁️ Dropbox. Plusieurs appareils peuvent y accéder, mais **un seul peut écrire à la fois** (verrou exclusif).

> **Important** : Cavea travaille toujours sur une **copie locale** de `cave.db`. Toutes vos modifications (ajout, consommation, déplacement…) sont enregistrées localement d'abord. Elles ne sont recopiées vers le partage cloud qu'au moment d'une **sauvegarde** — manuelle ou à la fermeture. Sans sauvegarde explicite, vos modifications restent uniquement sur votre appareil et risquent d'être perdues.

## Signalétique

Une icône permanente dans la navigation indique le mode actif et l'état du verrou.

### Icône de mode (toujours visible)

| Icône | Signification |
|---|---|
| 💻 PC (grise) | Mode Local — données sur cet ordinateur uniquement |
| ☁️ Nuage (bleu) | Mode Partagé — données sur Google Drive ou Dropbox |

### Icône de verrou (Mode Partagé uniquement)

| Icône | Signification |
|---|---|
| 🔓 Cadenas ouvert | Mode écriture (icône verte) — vous avez le verrou |
| 🔒 Cadenas fermé | Mode lecture seule (icône ambre) — un autre appareil a le verrou |
| ↻ Icône tournante | Sauvegarde en cours (icône bleue) |
| ⚠️ Icône d'erreur | Erreur de sauvegarde (icône rouge) |

## Boutons en Mode Partagé

### En mode écriture 🔓

**Sur PC (Windows / Linux)** : un bouton **💾 Sauvegarder** apparaît dans le panneau de navigation. Il déclenche une sauvegarde immédiate vers le cloud sans fermer l'application.

**Sur Android** : deux icônes apparaissent dans la barre de navigation :
- 💾 **Sauvegarder** (icône disquette verte) : sauvegarde immédiate vers le cloud
- **Quitter** (icône de sortie rouge) : sauvegarde + libération du verrou + fermeture

### En mode lecture seule 🔒

Un bouton **🔓 Prendre la main** est affiché. Il permet de prendre le verrou en écriture si l'autre appareil a libéré le verrou. Un dialogue de confirmation s'affiche avant la prise de main effective.

## Cycle de vie du verrou

### Démarrage

1. Cavea crée un fichier "verrou" sur le cloud pour signaler qu'il a la main
2. Cavea télécharge la dernière version de `cave.db` depuis le cloud
3. L'application s'ouvre en mode écriture 🔓

**Si un autre appareil a déjà le verrou** : Cavea ouvre en **mode lecture seule** 🔒. Un dialogue propose de rester en lecture seule ou de quitter.

### Fermeture propre

**Sur PC (Windows / Linux)** :
1. Fermez la fenêtre normalement
2. Cavea sauvegarde `cave.db` vers le cloud et libère le verrou
3. Les autres appareils peuvent alors prendre le verrou

**Sur Android** :
- Utilisez le bouton **Quitter** (icône de sortie rouge) dans la barre de navigation (visible uniquement en mode écriture)
- Ce bouton sauvegarde vers le cloud, libère le verrou, puis ferme l'application

> ⚠️ **Ne pas utiliser le bouton Accueil ou le gestionnaire de tâches pour quitter.** Le verrou ne serait pas libéré (les autres appareils resteraient bloqués en lecture) et **vos modifications depuis la dernière sauvegarde ne seraient pas recopiées sur la cave partagée**. Au prochain démarrage, si le verrou vous appartient encore, un dialogue vous demandera de choisir entre envoyer vos modifications locales vers la cave partagée ou repartir depuis la version partagée.

### Crash recovery

Au prochain démarrage, si le verrou appartient au même appareil :
- Cavea résout la situation automatiquement et propose de ré-envoyer la copie locale ou de récupérer la version du cloud
- Sur PC, un dialogue "Session précédente interrompue" peut apparaître

## Mode lecture seule — ce qui est accessible

| Fonctionnalité | Mode lecture seule 🔒 |
|---|---|
| 🍷 Consulter le stock | ✅ |
| Filtrer / chercher | ✅ |
| ℹ️ Fiche bouteille (lecture) | ✅ |
| 📦 Navigation par emplacement | ✅ |
| **Historique** 🕐 | ✅ |
| ↔️ Export CSV | ✅ |
| ⚙️ Paramètres | ✅ |
| ➕ Ajouter des bouteilles | ❌ |
| 🍸 Consommer / ↕️ Déplacer / ✏️ Modifier | ❌ |
| ↔️ Import CSV | ❌ |

## Changer de fournisseur cloud

Dans **⚙️ Paramètres > Mode de synchronisation**, appuyez sur **Changer de fournisseur**. Cette action efface les tokens enregistrés et relance l'assistant de connexion.

## Voir aussi

- [01 — Premier démarrage](01-premier-demarrage.md) (configuration initiale du Mode Partagé)
- [13 — Paramètres](13-parametres.md)
