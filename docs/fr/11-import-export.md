# ↔️ Import / Export CSV

Importer des données depuis un fichier CSV ou exporter votre cave vers un fichier CSV.

## Prérequis

- L'onglet **↔️ Données** est accessible même en mode 🔒 lecture seule (sauf le bouton Importer)

## Export CSV

### 1. Ouvrir l'onglet Données

Appuyez sur l'onglet **↔️ Données** dans la navigation.

### 2. Choisir le périmètre

- **Stock seul** : uniquement les bouteilles en stock (date de sortie vide)
- **Tout** : stock + bouteilles consommées (historique complet)

### 3. Choisir le séparateur de colonnes

| Séparateur | Recommandé pour |
|---|---|
| `;` (point-virgule) | Excel français / LibreOffice paramétré en français |
| `,` (virgule) | Excel anglais, Numbers (Mac), Google Sheets |
| Tabulation | Imports techniques, outils en ligne de commande |

### 4. Lancer l'export

Appuyez sur **Exporter**. L'application génère un fichier CSV encodé en UTF-8 avec BOM (compatible Excel).

- **Windows** : une boîte de dialogue vous demande où enregistrer le fichier
- **Android** : une boîte de dialogue de sauvegarde s'ouvre, puis l'option de partage (email, cloud, etc.)

Le fichier contient tous les champs, dont `updated_at` (date de dernière modification de chaque ligne).

## Import CSV

### 1. Prérequis de format

Le fichier CSV doit avoir :
- Une ligne d'en-tête avec les noms de colonnes
- Le séparateur configuré dans l'interface (`;`, `,` ou tabulation)
- Encodage UTF-8 (avec ou sans BOM)

Colonnes reconnues : `id`, `Domaine`, `Appellation`, `Millésime`, `Couleur`, `Cru`, `Contenance`, `Emplacement`, `Date entrée`, `Date sortie`, `Prix achat`, `Garde min`, `Garde max`, `Commentaire entrée`, `Note dégustation`, `Commentaire dégustation`, `Fournisseur nom`, `Fournisseur infos`, `Producteur`, `Mis à jour le`.

### 2. Lancer l'import

Dans l'onglet **↔️ Données**, appuyez sur **Importer**. Sélectionnez le fichier CSV.

> En mode 🔒 lecture seule, le bouton Importer est grisé.

### 3. Comportement de l'import

Le comportement dépend de la présence de la colonne `id` dans le fichier.

**Fichier issu d'un export Cavea** (colonne `id` présente) :

Chaque ligne est identifiée par son UUID.

- **Case "Écraser les lignes existantes" décochée** (défaut) : les bouteilles déjà présentes avec le même UUID sont **ignorées**. Réimporter le même fichier ne crée pas de doublons.
- **Case "Écraser les lignes existantes" cochée** : les bouteilles existantes sont **mises à jour**, les nouvelles sont insérées. À utiliser pour intégrer des corrections apportées dans un tableur.

**Fichier externe sans colonne `id`** :

Un nouvel UUID est généré automatiquement pour chaque ligne à chaque import. Importer deux fois le même fichier crée des doublons.

> Si la colonne `updated_at` est présente, elle est préservée (utile pour migrer un historique existant).

À l'issue de l'import, un récapitulatif indique le nombre de lignes insérées, mises à jour, ignorées et en erreur.

## Voir aussi

- [01 — Premier démarrage](01-premier-demarrage.md) (migrer une cave existante)
- [13 — Paramètres](13-parametres.md)
