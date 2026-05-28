# 🧪 Découverte avec les données d'exemple

Cavea est livré avec deux fichiers CSV d'exemple conçus pour vous permettre d'explorer l'application avec de vraies données, sans avoir à saisir manuellement vos bouteilles.

Ces fichiers sont disponibles en téléchargement sur la [page de la release GitHub](https://github.com/alainbenard54-collab/cavea/releases/latest) :

- `cavea_sample_fr.csv` — colonnes et données en français
- `cavea_sample_en.csv` — colonnes et données en anglais (même contenu)

## Contenu des fichiers

- **50 bouteilles en stock** réparties dans une cave avec 4 casiers : `Cave > Casier 1`, `Cave > Casier 2`, `Cave > Casier 3 > Gauche`, `Cave > Casier 3 > Droite`, `Cave > Casier 4`
- **20 bouteilles consommées** avec notes de dégustation
- Vins représentatifs : Bordeaux, Bourgogne, Rhône, Alsace, Champagne, Provence
- Toutes les couleurs : Rouge, Blanc, Rosé, Blanc effervescent, Blanc liquoreux
- Tous les stades de maturité : trop jeune, optimal, à boire d'urgence, sans données de garde
- Domaines fictifs mais réalistes, millésimes allant de 2012 à 2023

## Importer les données d'exemple

### 1. Télécharger le fichier

Sur la [page de la release GitHub](https://github.com/alainbenard54-collab/cavea/releases/latest), téléchargez `cavea_sample_fr.csv` (ou `cavea_sample_en.csv` si votre interface est en anglais).

### 2. Configurer Cavea

Si vous n'avez pas encore configuré l'application, suivez le scénario [01 — Premier démarrage](01-premier-demarrage.md). Le Mode Local est suffisant pour explorer l'application.

### 3. Lancer l'import

1. Ouvrez l'onglet **↔️ Données**
2. Vérifiez que le séparateur est réglé sur **`;` (point-virgule)**
3. Appuyez sur **Importer** et sélectionnez le fichier
4. Laissez la case "Écraser les lignes existantes" **décochée**
5. Confirmez — l'import insère 70 bouteilles (50 en stock + 20 consommées)

> Ces fichiers contiennent une colonne `id` unique par bouteille. Réimporter le même fichier ne crée pas de doublons.

## Réinitialiser après la découverte

### Réinitialisation complète (recommandée)

Désinstallez Cavea. Sur Windows et Linux, l'assistant de désinstallation propose de supprimer la configuration. Sur Android, la désinstallation supprime automatiquement toutes les données.

Réinstallez ensuite l'application normalement.

### Réinitialisation des données uniquement — Mode Local, Windows et Linux

Si vous utilisez le **Mode Local** et souhaitez conserver vos paramètres (chemin de la cave) mais repartir d'une cave vide :

1. Fermez Cavea
2. Supprimez le fichier `cave.db` depuis le dossier configuré dans **⚙️ Paramètres > Emplacement de la cave**
3. Relancez Cavea — l'application crée automatiquement une nouvelle cave vide au même emplacement

> **Mode Partagé** : supprimer le `cave.db` local n'a pas l'effet attendu. Au prochain démarrage, Cavea retélécharge automatiquement la copie depuis le cloud — la cave partagée n'est pas perdue, mais vous ne repartez pas non plus d'une cave vide. Pour réinitialiser en Mode Partagé, basculez d'abord vers le Mode Local via **⚙️ Paramètres > Revenir en local**, puis supprimez `cave.db`.

> Sur Android, `cave.db` est dans le stockage protégé de l'application — la désinstallation est la seule option accessible.

## Voir aussi

- [01 — Premier démarrage](01-premier-demarrage.md)
- [11 — Import / Export CSV](11-import-export.md)
