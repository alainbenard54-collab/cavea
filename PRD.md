# 🍷 Projet : Gestion de cave à vin

## 🎯 Objectif
Créer une application simple, locale et efficace pour :
- gérer un stock de bouteilles **unitaire**
- suivre les entrées / sorties
- identifier facilement **quoi boire**
- préparer / déplacer des bouteilles (ex : frigo)
- analyser la consommation (à terme)

---

# 🧱 Modèle de données (simplifié)

## Entité : bouteille

- id (UUID)
- domaine
- appellation
- millesime
- couleur
- cru
- contenance
- emplacement (format : `Niveau1 > Niveau2 > Niveau3`)
- date_entree (YYYY-MM-DD)
- date_sortie (YYYY-MM-DD ou vide)
- prix_achat (format décimal avec point)
- garde_min (années)
- garde_max (années)
- commentaire_entree
- note_degus (optionnel)
- commentaire_degus (optionnel)
- fournisseur_nom (optionnel)
- fournisseur_infos (optionnel)
- producteur (optionnel)

---

## Règles métier clés

- Une ligne = **1 bouteille physique**
- Une bouteille est :
  - en stock → `date_sortie vide`
  - consommée → `date_sortie renseignée`
- L’emplacement est une **hiérarchie texte**
- Les mouvements (ex : cave → frigo) sont des **changements d’emplacement**

---

# 🟢 MVP (Minimum Viable Product)

## 🎯 Objectif
Remplacer immédiatement l’ancien logiciel

---

## 1. Import des données

- import CSV (format clean généré)
- chargement en base locale

---

## 2. Consultation du stock

- liste des bouteilles en stock
- filtres :
  - couleur
  - appellation
  - millésime
- recherche texte (domaine)

---

## 3. Vue "Que boire ?"

Calcul automatique :

- trop jeune → millésime + garde_min > année actuelle
- optimal → entre garde_min et garde_max
- à boire urgent → > garde_max

Affichage visuel :
- 🟦 trop jeune
- 🟩 optimal
- 🟥 à boire

---

## 4. Sortie de bouteille (consommation)

- action : "consommer"
- remplit `date_sortie = aujourd’hui`

---

## 5. Ajout de bouteilles (IMPORTANT)

### Ajout unitaire
- formulaire simple

### Ajout en lot (OBLIGATOIRE)

- saisir une seule fois :
  - domaine, appellation, millésime, etc.
  - quantité (ex : 6)

- système crée automatiquement **N bouteilles**

👉 Critique pour ton usage réel

---

## 6. Duplication rapide

- bouton "dupliquer"
- pré-remplit formulaire

---

## 7. Gestion des emplacements (simple)

- affichage de `emplacement`
- filtre texte (contains)

---

## 8. Mouvements simples (IMPORTANT)

- changer emplacement d’une bouteille
- ex :
  - cave → frigo
  - frigo → cave

👉 Pas une sortie, juste un déplacement

---

## 9. Cas d’usage mobile critique

Depuis mobile :

- voir "à boire"
- sélectionner bouteilles
- action :
  - déplacer vers "frigo"
  - ou consommer

---

# 🟡 V1 (version robuste)

## 🎯 Objectif
Améliorer confort + organisation

---

## 1. Filtres avancés

- multi-critères
- filtres sauvegardés :
  - ex : "blanc à boire"

---

## 2. Navigation par emplacement (hiérarchique)

À partir de : 
Cave > Étagère > Casier


Permettre :
- regroupement
- affichage par niveau
- comptage par zone

---

## 3. Gestion des mouvements (fusion avec édition)

👉 Pas de module séparé

- modifier emplacement = mouvement
- historique non nécessaire (à ce stade)

---

## 4. Historique des consommations

- liste des bouteilles consommées
- tri par date

---

## 5. Édition des bouteilles

- modifier :
  - garde
  - prix
  - emplacement
  - commentaires

---

## 6. Export / sauvegarde

- export CSV
- sauvegarde simple

---

# 🟠 V2 (intelligence métier)

## 🎯 Objectif
Aide à la décision

---

## 1. Analyse de consommation

- nb bouteilles / an
- répartition par type

---

## 2. Recommandation d’achat

Ex :
- consommation : 6 bouteilles/an
- garde : 5 ans

→ stock cible = 30 bouteilles

---

## 3. Plan de consommation

- projection annuelle
- éviter dépassement de garde

---

## 4. Alertes

- vins en fin de garde
- déséquilibre stock

---

## 5. Valorisation cave

- total €
- par filtre

---

# 🔴 Hors périmètre (à éviter)

## Complexité technique

- cloud / hébergement externe
- multi-utilisateur avancé
- authentification complexe

---

## Modélisation excessive

- tables relationnelles complexes
- normalisation complète (domaines, appellations)

---

## UX complexe

- plan visuel de cave (graphique / 3D)
- drag & drop spatial

---

## Fonctionnalités inutiles

- CRM fournisseur
- gestion emailing
- œnologie avancée (robe, nez, bouche)
- IA complexe (ML)

---

# 🧭 Règle de priorisation

Pour chaque fonctionnalité :

> Est-ce que ça m’aide à :
> - choisir une bouteille ?
> - gérer mon stock ?

Si NON → hors scope

---

# 🚀 Ordre de développement

1. Import + modèle
2. Stock + filtres
3. Vue "à boire"
4. Sortie bouteille
5. Ajout en lot
6. Mouvements
7. Mobile usage

Puis V1 → V2

---

# ✅ Résumé des points critiques

- modèle simple et stable
- 1 bouteille = 1 ligne
- ajout en lot obligatoire
- emplacement hiérarchique texte
- mouvements ≠ sortie
- UX mobile prioritaire

---

# 🏗️ Architecture & Contraintes techniques

## 🎯 Objectifs

- Aucune dépendance à un hébergement payant
- Fonctionnement offline possible
- Déploiement simple (utilisateur non expert)
- Multi-device possible (PC + mobile) mais non simultané

---

## 📦 Stockage des données

### Option principale (recommandée)
- Base de données SQLite (`cave.db`)
- Stockée :
  - soit localement (mode offline)
  - soit sur un espace partagé (Google Drive, Dropbox, OneDrive…)

---

### Modes de fonctionnement

#### 1. Mode local (offline)
- base SQLite sur le disque local
- aucune synchronisation

#### 2. Mode synchronisé
- base SQLite stockée sur un espace partagé
- fonctionnement :

1. téléchargement du fichier
2. travail en local
3. upload du fichier

---

## 🔒 Gestion du verrou (mode synchronisé)

- fichier `cave.lock` associé

### Règles :
- si lock présent → lecture seule
- sinon :
  - création du lock
  - modification autorisée
  - suppression du lock à la fin

⚠️ Hypothèse :
- usage mono-utilisateur ou utilisateur discipliné
- pas de gestion multi-utilisateur concurrent avancée

---

## 🔄 Synchronisation

- synchronisation manuelle (bouton)
- pas de synchronisation automatique temps réel

### Stratégie minimale
- remplacement complet du fichier SQLite

### Extension possible
- synchronisation intelligente via champ `updated_at`

---

## 📱 Répartition des fonctionnalités

### 💻 Application PC (complète)

- import CSV
- ajout de bouteilles (y compris en lot)
- édition complète
- gestion des emplacements
- analyses et statistiques (V2)
- gestion avancée du stock

---

### 📱 Application mobile (simplifiée au moins pour l'instant)

- consultation du stock
- filtres simples
- vue "à boire"
- actions rapides :
  - consommer une bouteille
  - déplacer une bouteille (ex : cave → frigo)

❌ Non inclus au MVP mobile :
- ajout de bouteilles
- import
- analyses avancées

---

## ⚙️ Paramétrage utilisateur

L’application doit permettre :

- choix du mode :
  - local uniquement
  - synchronisé

- choix du backend de stockage :
  - chemin local
  - dossier synchronisé (Drive / Dropbox…)

---

## 🚫 Contraintes fortes

- pas d’hébergement cloud obligatoire
- pas de backend serveur requis
- pas de base de données distante obligatoire

---

## 🔮 Évolutivité

L’architecture doit permettre ultérieurement :

- ajout d’un backend (optionnel)
- synchronisation avancée
- application mobile complète

Sans remettre en cause le modèle de données existant
