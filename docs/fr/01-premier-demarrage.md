# Premier démarrage

Au tout premier lancement, Cavea affiche automatiquement un **assistant de configuration**. Vous n'avez pas à naviguer vers les Paramètres — l'assistant s'ouvre de lui-même tant que l'application n'est pas configurée.

## Étape 1 — Choisir votre mode

Deux modes s'affichent :

- 💻 **Mode Local** — cave gérée sur un seul appareil, fichier `cave.db` sur le disque local, aucun cloud requis
- 🔄 **Mode Partagé** — cave partagée entre plusieurs appareils via ☁️ Google Drive ou ☁️ Dropbox

> Sur Android, seul le 🔄 Mode Partagé est disponible pour l'instant. Le 💻 Mode Local sur Android est prévu dans une future version.

Appuyez sur la carte correspondant à votre choix.

## Étape 2a — Mode Local : choisir le dossier

1. Saisissez le chemin du dossier où sera créé `cave.db`, ou appuyez sur 📁 pour parcourir vos dossiers
2. Appuyez sur **Suivant**
3. Vérifiez le récapitulatif (mode + chemin) et appuyez sur **Démarrer**

L'application s'ouvre directement sur le stock (vide au premier lancement).

> Pour modifier ce chemin plus tard : **⚙️ Paramètres > Emplacement de la cave > Modifier**.

## Étape 2b — Mode Partagé : connexion cloud

1. Choisissez votre fournisseur : **☁️ Google Drive** ou **☁️ Dropbox**
2. Appuyez sur **Se connecter** — votre navigateur s'ouvre pour l'authentification OAuth
3. Une fois connecté, Cavea vérifie si une cave existe déjà dans le cloud :

   **Aucune cave trouvée** → appuyez sur **Créer une nouvelle cave**

   **Cave trouvée** → deux options :
   - **Rejoindre** — télécharge la cave existante et prend le verrou 🔒 en écriture
   - **Écraser** — remplace la cave distante par une cave vide (irréversible, double confirmation demandée)

L'application s'ouvre sur le stock une fois la configuration terminée.

## Importer des données existantes

Si vous avez un fichier CSV de votre cave, consultez le scénario [11 — Import/Export CSV](11-import-export.md) pour l'importer dès la première session.

## Voir aussi

- [02 — Ajouter des bouteilles](02-ajout-bouteilles.md)
- [12 — Mode Partagé](12-mode-partage.md)
- [13 — Paramètres](13-parametres.md)
