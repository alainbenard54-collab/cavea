## ADDED Requirements

### Requirement: Table bouteilles drift
L'application SHALL définir une table drift `bouteilles` avec tous les champs du modèle de données (voir ARCHITECTURE.md). La table SHALL utiliser `id` (TEXT UUID) comme clé primaire. Tous les champs nullable du modèle SHALL être déclarés nullable dans drift.

#### Scenario: Création de la base au premier lancement
- **WHEN** `cave.db` n'existe pas au chemin configuré
- **THEN** drift crée la base avec la table `bouteilles` via la migration initiale

#### Scenario: Ouverture d'une base existante
- **WHEN** `cave.db` existe et est une base drift valide
- **THEN** drift l'ouvre sans modifier le schéma (aucune migration nécessaire à la version 1)

---

### Requirement: Accès direct dart:io (Mode 1)
En Mode 1, l'application SHALL ouvrir `cave.db` via `NativeDatabase` de drift_flutter, en utilisant le chemin absolu configuré. Aucun StorageAdapter, aucune synchronisation.

#### Scenario: Ouverture Mode 1
- **WHEN** le mode configuré est "local" et le chemin est valide
- **THEN** drift ouvre `NativeDatabase(File(path))` directement

---

### Requirement: BouteilleDao — opérations de base
L'application SHALL fournir un DAO `BouteilleDao` exposant au minimum : insertion d'une bouteille, mise à jour complète, récupération de toutes les bouteilles en stock (`date_sortie` NULL ou vide), récupération par UUID.

#### Scenario: Lecture du stock
- **WHEN** `watchStock()` est appelé
- **THEN** retourne un Stream des bouteilles dont `date_sortie` est NULL ou vide, trié par `domaine` puis `millesime`

#### Scenario: Insertion d'une bouteille
- **WHEN** `insertBouteille(bouteille)` est appelé avec un objet valide
- **THEN** la bouteille est persistée et le stream `watchStock()` émet la nouvelle liste

#### Scenario: Mise à jour d'une bouteille existante
- **WHEN** `updateBouteille(bouteille)` est appelé avec un UUID présent en base
- **THEN** tous les champs sont mis à jour et `updated_at` est rafraîchi

---

### Requirement: Providers Riverpod
L'application SHALL exposer la base drift et le DAO via des providers Riverpod. Le provider de base SHALL être un singleton initialisé une seule fois par session.

#### Scenario: Accès au DAO depuis un widget
- **WHEN** un widget lit `bouteillesDaoProvider`
- **THEN** il obtient une instance valide du DAO connectée à la base ouverte
