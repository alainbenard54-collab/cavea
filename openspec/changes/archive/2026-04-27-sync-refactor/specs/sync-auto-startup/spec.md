## ADDED Requirements

### Requirement: Sync automatique au démarrage en Mode 2
En Mode 2, l'application SHALL appeler `syncOnStartup()` au démarrage, après chargement de la config et avant d'afficher l'écran principal. L'UI SHALL rester bloquée (état `SyncStarting`) pendant toute la durée de l'opération.

#### Scenario: Lock libre au démarrage
- **WHEN** l'app démarre en Mode 2 et qu'aucun verrou n'existe sur Drive
- **THEN** l'app pose le verrou, télécharge `cave.db` depuis Drive (ou uploade la base locale si Drive est vide), passe en mode écriture et affiche l'écran principal

#### Scenario: Drive vide au premier lancement
- **WHEN** l'app démarre en Mode 2, le verrou est libre, et `cave.db` n'existe pas encore sur Drive
- **THEN** l'app pose le verrou, uploade la base locale vers Drive, passe en mode écriture et affiche l'écran principal

#### Scenario: Lock à nous au démarrage (crash recovery)
- **WHEN** l'app démarre en Mode 2 et que le verrou appartient à cet appareil
- **THEN** l'app affiche un dialog "Session précédente interrompue" avec deux boutons : "Envoyer mes données locales" et "Repartir depuis Google Drive (perte de modifications locales possible)"

#### Scenario: Crash recovery — choix upload local
- **WHEN** dans le dialog crash recovery, l'utilisateur choisit "Envoyer mes données locales"
- **THEN** l'app uploade la base locale vers Drive (lock conservé), passe en mode écriture et affiche l'écran principal

#### Scenario: Crash recovery — choix download Drive
- **WHEN** dans le dialog crash recovery, l'utilisateur choisit "Repartir depuis Google Drive (perte de modifications locales possible)"
- **THEN** l'app télécharge `cave.db` depuis Drive (lock conservé), passe en mode écriture et affiche l'écran principal

#### Scenario: Lock tiers au démarrage
- **WHEN** l'app démarre en Mode 2 et que le verrou appartient à un autre appareil
- **THEN** l'app affiche un dialog "Cave utilisée sur un autre appareil" avec deux boutons : "Consulter en lecture seule" et "Annuler"

#### Scenario: Lock tiers — choix lecture seule
- **WHEN** dans le dialog lock tiers, l'utilisateur choisit "Consulter en lecture seule"
- **THEN** l'app télécharge `cave.db` depuis Drive sans poser de verrou, passe en mode lecture seule et affiche l'écran principal

#### Scenario: Lock tiers — choix annuler
- **WHEN** dans le dialog lock tiers, l'utilisateur choisit "Annuler"
- **THEN** l'application se ferme

#### Scenario: Stale lock (> 24h)
- **WHEN** l'app démarre en Mode 2 et qu'un verrou existe depuis plus de 24h
- **THEN** le verrou est ignoré et traité comme "lock libre" (chemin nominal)

---

### Requirement: Bouton Sync en mode écriture
En mode écriture (Mode 2, lock détenu par cet appareil), le bouton "Synchroniser" SHALL uploader `cave.db` vers Drive sans libérer le verrou.

#### Scenario: Upload manuel en mode écriture
- **WHEN** l'utilisateur appuie sur le bouton "Synchroniser" en mode écriture
- **THEN** l'app uploade `cave.db` vers Drive, conserve le verrou, et affiche un snackbar "Cave sauvegardée sur Drive"

#### Scenario: Bouton absent en lecture seule
- **WHEN** l'app est en mode lecture seule
- **THEN** le bouton "Synchroniser" est absent de l'interface

---

### Requirement: Fermeture automatique avec upload + unlock en mode écriture
En mode écriture (Mode 2), la fermeture de l'application (Alt+F4, bouton ×, fermeture taskbar) SHALL déclencher automatiquement upload + unlock avant de laisser l'OS fermer l'app.

#### Scenario: Fermeture normale en mode écriture (Windows)
- **WHEN** l'utilisateur ferme l'app en mode écriture (Alt+F4, bouton ×, taskbar) sur Windows
- **THEN** l'app affiche un dialog "Votre cave va être sauvegardée sur Google Drive avant de fermer." avec une barre de progression, uploade `cave.db`, libère le verrou, puis se ferme automatiquement

#### Scenario: Fermeture en lecture seule
- **WHEN** l'utilisateur ferme l'app en mode lecture seule
- **THEN** l'app se ferme directement sans dialog ni upload

#### Scenario: Fermeture en Mode 1
- **WHEN** l'utilisateur ferme l'app en Mode 1
- **THEN** l'app se ferme directement sans aucune opération Drive

---

### Requirement: Scope Google Drive drive.file + dossier Cavea
L'adaptateur Drive SHALL utiliser le scope `drive.file` (au lieu de `appDataFolder`) et stocker tous les fichiers (`cave.db`, `cave.db.lock`) dans un dossier nommé `Cavea` à la racine du Google Drive de l'utilisateur.

#### Scenario: Dossier Cavea absent à la première connexion
- **WHEN** l'app se connecte à Drive pour la première fois et que le dossier `Cavea` n'existe pas
- **THEN** l'app crée le dossier `Cavea` à la racine du Drive avant toute opération fichier

#### Scenario: Dossier Cavea déjà existant
- **WHEN** l'app se connecte à Drive et que le dossier `Cavea` existe déjà
- **THEN** l'app réutilise le dossier existant (pas de doublon créé)

#### Scenario: Fichiers visibles dans Drive UI
- **WHEN** l'utilisateur ouvre Google Drive dans un navigateur web
- **THEN** le dossier `Cavea` est visible, et `cave.db` et `cave.db.lock` (si présent) sont accessibles et supprimables manuellement
