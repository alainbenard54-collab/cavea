## Context

La vue stock (étape 2) affiche les bouteilles sans notion de maturité. L'utilisateur doit calculer mentalement si un vin est prêt à boire. La vue "Quoi boire ?" répond à ce besoin en calculant la maturité à la volée et en la visualisant avec des couleurs.

Le calcul est purement en mémoire (pas de colonne SQL) : `anneeActuelle - millesime` comparé à `[gardeMin, gardeMax]`. Les données nécessaires (`millesime`, `gardeMin`, `gardeMax`) sont déjà exposées par `watchStockFiltered` dans `BouteilleDao`.

## Goals / Non-Goals

**Goals:**
- Afficher les bouteilles en stock avec un badge de maturité coloré
- Permettre de filtrer par couleur de vin
- Trier par maturité (vins "à boire" en premier, puis "optimaux", puis "à attendre")
- Partager le layout adaptatif existant (NavigationRail / BottomNavigationBar)

**Non-Goals:**
- Action "consommer" depuis cet écran (étape 4 du MVP)
- Calcul de maturité basé sur des règles œnologiques externes
- Affichage de bouteilles sans `gardeMin`/`gardeMax` renseignés (elles apparaissent sans badge)

## Decisions

### 1. Calcul de maturité dans un provider Dart, pas en SQL

**Décision** : `MaturityService` (ou méthode dans un provider) calcule la maturité à partir des objets `Bouteille` déjà en mémoire.

**Rationale** : La logique est simple (`age vs [gardeMin, gardeMax]`), évite une requête SQL custom, reste testable en Dart pur. Pas de valeur à descendre cette logique en base.

**Alternative rejetée** : Colonne calculée SQLite — ajoute une migration, couple la logique métier à la DB.

### 2. Réutilisation de `watchStockFiltered` sans nouveau DAO

**Décision** : La vue utilise `watchStockFiltered(couleur: selectedCouleur)` existant.

**Rationale** : Le DAO expose déjà tous les champs nécessaires. Ajouter une méthode DAO dédiée serait de la duplication.

### 3. Enum `MaturityLevel` pour les 4 états

```dart
enum MaturityLevel { tropJeune, optimal, aBoireUrgent, sansDonnee }
```

| État | Condition | Couleur badge |
|---|---|---|
| `tropJeune` | `age < gardeMin` | Bleu |
| `optimal` | `gardeMin <= age <= gardeMax` | Vert |
| `aBoireUrgent` | `age > gardeMax` | Rouge |
| `sansDonnee` | `gardeMin` ou `gardeMax` null/0 | Gris |

### 4. Tri côté Dart, pas SQL

**Décision** : La liste triée est produite par un `StateNotifierProvider` ou `Provider` qui transforme le stream.

**Ordre** : `aBoireUrgent` → `optimal` → `tropJeune` → `sansDonnee`.

### 5. Structure de fichiers

```
lib/features/quoi_boire/
  quoi_boire_screen.dart       # Scaffold + layout adaptatif
  widgets/
    maturity_badge.dart        # Badge coloré (chip Material 3)
    bouteille_maturity_tile.dart # Ligne liste avec badge
  providers/
    quoi_boire_provider.dart   # Stream filtré + tri maturité
lib/core/maturity/
  maturity_service.dart        # MaturityLevel + calcul (pur Dart)
```

## Risks / Trade-offs

- [Bouteilles sans gardeMin/gardeMax] → Badge gris neutre, pas d'erreur. L'utilisateur voit quand même la bouteille dans la liste.
- [Performance sur grande cave] → Le tri Dart sur des centaines de bouteilles est négligeable. Si la cave dépasse 10 000 bouteilles, on envisagera un tri SQL (noté en backlog).
- [Filtre couleur partagé avec vue stock ?] → Les filtres sont indépendants par vue. Pas de state global partagé pour l'instant.
