# ⚙️ Paramètres

Configurer l'application : emplacement de la cave, valeurs par défaut, listes de référence et mode de synchronisation.

## Accéder aux Paramètres

Appuyez sur l'onglet **⚙️ Paramètres** dans la navigation. Accessible en Mode Local et en ☁️ Mode Partagé (même en mode 🔒 lecture seule).

## 1. Emplacement de la cave (Mode Local uniquement)

Affiche le dossier contenant `cave.db`. Appuyez sur **Modifier** pour choisir un autre dossier via le sélecteur de fichiers.

> Un redémarrage de l'application est nécessaire pour que le changement de chemin soit pris en compte.

Cette section n'apparaît pas en ☁️ Mode Partagé.

## 2. Ajout en lot — valeurs par défaut

Configurez les valeurs pré-remplies dans le formulaire **➕ Ajouter** :

- **Couleur par défaut** : sélectionnez dans la liste de référence. La valeur sera pré-sélectionnée à l'ouverture du formulaire si elle est dans la liste.
- **Contenance par défaut** : saisissez la valeur (ex : "75 cl"). Elle sera pré-remplie dans le formulaire.

## 3. Listes de référence

Trois listes configurables qui alimentent les menus déroulants dans les formulaires d'ajout et d'édition :

### Couleurs
Valeurs par défaut : Blanc, Blanc effervescent, Blanc liquoreux, Blanc moelleux, Rosé, Rosé effervescent, Rouge.

### Contenances
Valeurs par défaut : 37,5 cl, 50 cl, 75 cl, 1,5 L (magnum).

### Crus
Valeurs par défaut : 1ER CRU, CRU BOURGEOIS, CRU CLASSE, GRAND CRU, GRAND CRU CLASSE, SECOND VIN.

**Pour chaque liste** :
- Appuyez sur la croix d'un chip pour supprimer une valeur
- Tapez dans le champ "Ajouter" et validez pour ajouter une nouvelle valeur

> Dans le formulaire **➕ Ajouter**, la liste affichée est l'union de la liste de référence et des valeurs déjà présentes en base. Les valeurs de référence apparaissent en tête de liste.

## 4. Mode de synchronisation

Affiche le fournisseur cloud actif (☁️ Google Drive ou ☁️ Dropbox) quand le ☁️ Mode Partagé est activé.

**Changer de fournisseur** : efface les tokens OAuth et relance l'assistant de configuration. Utile pour passer de Google Drive à Dropbox (ou inversement).

## 5. À propos

Version de l'application, licence Apache 2.0, et lien vers les licences des dépendances.

## Voir aussi

- [01 — Premier démarrage](01-premier-demarrage.md)
- [02 — Ajouter des bouteilles](02-ajout-bouteilles.md)
- [12 — Mode Partagé](12-mode-partage.md)
