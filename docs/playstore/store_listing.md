# Cavea — Fiche Play Store

Référence pour alimenter les formulaires Google Play Console.
Langue principale : **Français**. Traduction disponible : **Anglais**.

---

## Informations communes (toutes langues)

| Champ | Valeur |
|---|---|
| Package name | `com.cavea.cavea` |
| Catégorie | Lifestyle |
| Tags | cave à vin, vin, stock, gestion, cellar |
| Privacy policy (FR) | `https://alainbenard54-collab.github.io/cavea/privacy/fr.html` |
| Privacy policy (EN) | `https://alainbenard54-collab.github.io/cavea/privacy/en.html` |
| Email contact | alain.benard54@gmail.com |
| Site web | `https://alainbenard54-collab.github.io/cavea/fr/` |

---

## Français (langue principale)

### Titre
```
Cavea – Cave à vin personnelle
```
*(30 caractères max — actuel : 30)*

### Description courte
```
Gérez votre cave à vin. Stock, emplacements, maturité, dégustations. Simple.
```
*(80 caractères max — actuel : 77)*

### Description longue
```
Cavea est une application de gestion de cave à vin personnelle, sobre et efficace. Pas de fioritures — juste ce dont vous avez besoin au quotidien.

Suivez votre stock bouteille par bouteille
Chaque ligne de la base = une bouteille physique. Domaine, appellation, millésime, couleur, cru, contenance, emplacement, prix d'achat, fournisseur, producteur — tout est là. Ajout rapide en lot (10 bouteilles de Chambolle-Musigny dans Casier 1 ? 3 clics), ou saisie unitaire complète.

Sachez toujours quoi boire
L'indicateur de maturité calcule en temps réel si chaque bouteille est trop jeune (bleu), à son optimum (vert) ou en dépassement de garde (rouge). Dans la vue stock, triez par urgence pour ne jamais laisser passer un grand vin.

Naviguez dans votre cave par emplacement
L'onglet Emplacements affiche votre cave en arborescence (Cave > Casier 3 > Gauche…). À chaque niveau : nombre de bouteilles, valeur estimée, accès direct à la liste. Déplacez une bouteille en deux taps depuis n'importe quel écran.

Enregistrez vos dégustations
À la consommation : date, note /10, commentaire. L'historique complet reste accessible, triable, recherchable.

Partagez votre cave entre plusieurs appareils
En mode Partagé, cave.db est hébergé sur Google Drive ou Dropbox. Tous vos appareils accèdent aux mêmes données — un seul peut écrire à la fois (verrou automatique). Pas de conflit, pas de merge, pas de surprise.

Vos données restent les vôtres
Aucun serveur Cavea, aucune inscription, aucun abonnement. Les données sont dans un fichier SQLite sur votre stockage cloud ou votre téléphone. Export CSV à tout moment.

Disponible aussi sur Windows et Linux : github.com/alainbenard54-collab/cavea/releases
```
*(4000 caractères max — actuel : ~1230)*

---

## English (traduction)

### Title
```
Cavea – Personal wine cellar
```
*(30 chars max — current: 28)*

### Short description
```
Manage your wine cellar. Stock, locations, maturity, tasting notes. Simple.
```
*(80 chars max — current: 75)*

### Full description
```
Cavea is a personal wine cellar management app — focused and efficient. No frills, just what you need day to day.

Track your stock bottle by bottle
One row = one physical bottle. Domain, appellation, vintage, color, classification, volume, location, purchase price, supplier, producer — all in one place. Quick bulk entry (10 bottles of the same wine across multiple locations in 3 taps), or full individual entry.

Always know what to drink
The maturity indicator calculates in real time whether each bottle is too young (blue), at its peak (green), or past its prime (red). Sort by urgency in the stock view so you never miss a great bottle at its best.

Browse your cellar by location
The Locations tab shows your cellar as a tree (Cellar > Rack 3 > Left…). Each level shows bottle count and estimated value. Move a bottle in two taps from any screen.

Record your tasting notes
When you consume a bottle: date, score /10, tasting notes. Full history remains searchable and sortable.

Share your cellar across devices
In Shared mode, cave.db is hosted on Google Drive or Dropbox. All your devices access the same data — only one can write at a time (automatic lock). No conflict, no merge, no surprises.

Your data stays yours
No Cavea server, no account, no subscription. Data lives in a SQLite file on your cloud storage or your phone. CSV export available at any time.

Also available on Windows and Linux: github.com/alainbenard54-collab/cavea/releases
```
*(4000 chars max — current: ~1130)*

---

## Visuels

### Icône haute résolution
- Fichier : `assets/icons/icon_512_playstore.png`
- Taille : 512×512 px (requis par Play Store)
- Format : PNG sans transparence ✅

### Feature graphic
- Fichier : `assets/icons/feature_graphic_playstore.png`
- Taille : 1024×500 px (requis par Play Store)
- Affiché en haut de la fiche et dans les placements promotionnels

### Screenshots téléphone
- Format : JPG ou PNG 24 bits (pas d'alpha)
- Résolution native Android recommandée (ex. 1080×2400)
- Minimum 2, maximum 8
- Fichiers dans `assets/screenshots/` :
  1. `phone_01_stock.jpg` — Vue stock avec badges maturité colorés
  2. `phone_02_actions.jpg` — BottomSheet actions bouteille (Consommer / Déplacer / Fiche)
  3. `phone_03_emplacements.jpg` — Navigation Emplacements (arborescence)
  4. `phone_04_bulk_add_top.jpg` — Formulaire Ajout en lot — champs communs
  5. `phone_05_bulk_add_bottom.jpg` — Formulaire Ajout en lot — répartition
  6. `phone_06_historique.jpg` — Historique des consommations

---

## Content rating (questionnaire IARC)

Réponses à donner lors du questionnaire :
- Violence : **Non**
- Contenu sexuel : **Non**
- Langage : **Non**
- Substances : **Oui — références à l'alcool** (l'app est explicitement dédiée au vin)
- Localisation / chat / achats intégrés : **Non**

Résultat attendu : **PEGI 12** ou équivalent (standard pour apps à thématique alcool sans promotion active).

---

## Notes de version (What's new)

### v1.1.0
```
Première publication sur le Play Store.

Gestion complète de cave à vin : stock, emplacements, maturité, dégustations, historique. Mode partagé Google Drive / Dropbox. Export CSV. Interface disponible en français et en anglais.
```

```
First Play Store release.

Full wine cellar management: stock, locations, maturity, tastings, history. Google Drive / Dropbox shared mode. CSV export. Available in French and English.
```
